import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  Future<void> initialize() async {}

  // 1. Sign In authentication logic
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        final profileResponse = await client
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .maybeSingle();
        
        return profileResponse;
      }
      return null;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // 2. User Registration (Auth + Profiles Table)
  Future<bool> signUpUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        await client.from('profiles').insert({
          'id': authResponse.user!.id, 
          'full_name': fullName,
          'email': email,
          'role': role,
          'status': true, 
          'job_title': 'New Member', 
          'registration_date': DateTime.now().toIso8601String().split('T')[0],
          'avatar_url': 'assets/images/mypic.png', 
        });

        return true; 
      }
      return false;
    } catch (e) {
      debugPrint('Error signing up: $e');
      
      // If user already exists, attempt to sign in immediately (useful for demo/testing)
      if (e.toString().contains('user_already_exists') || 
          e.toString().contains('User already registered')) {
        try {
          final signInRes = await signIn(email, password);
          if (signInRes != null) return true;
        } catch (signInErr) {
          debugPrint('Silent sign in failed: $signInErr');
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // 3. Fetching profiles belonging to the currently authenticated guardian
  Future<List<PatientProfile>> fetchPatientProfiles() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await client
          .from('patient_profiles')
          .select()
          .eq('guardian_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => PatientProfile.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching patient profiles: $e');
      return [];
    }
  }

  // Fetch the single patient profile for the currently authenticated wearer
  Future<PatientProfile?> fetchWearerPatientProfile() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('patient_profiles')
          .select()
          .eq('guardian_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return PatientProfile.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching wearer patient profile: $e');
      return null;
    }
  }

  Future<void> createPatientProfile(PatientProfile profile) async {
    try {
      await client.from('patient_profiles').insert(profile.toMap());
    } catch (e) {
      debugPrint('Error creating patient profile: $e');
      rethrow;
    }
  }

  /// Uploads raw image bytes to Supabase Storage and returns the public URL.
  /// This avoids XFile path issues on Flutter Web where blob URLs can't be re-read.
  String? lastUploadError;

  Future<String?> uploadProfileAvatarBytes(Uint8List bytes, String profileId) async {
    lastUploadError = null;
    if (bytes.isEmpty) {
      lastUploadError = 'Image bytes are empty';
      return null;
    }

    try {
      debugPrint('[AvatarUpload] Uploading ${bytes.length} bytes for profile $profileId');

      final storagePath =
          'profiles/$profileId-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await client.storage.from('avatars').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl = client.storage.from('avatars').getPublicUrl(storagePath);
      debugPrint('[AvatarUpload] Success! URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      lastUploadError = e.toString();
      debugPrint('[AvatarUpload] FAILED: $e');
      return null;
    }
  }

  /// Uploads current user's avatar and updates `profiles.avatar_url`.
  Future<String?> uploadAndSaveUserAvatar(Uint8List bytes, String userId) async {
    lastUploadError = null;
    if (bytes.isEmpty) {
      lastUploadError = 'Image bytes are empty';
      return null;
    }

    try {
      final storagePath =
          '$userId/users/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
      await client.storage.from('avatars').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl = client.storage.from('avatars').getPublicUrl(storagePath);
      await client
          .from('profiles')
          .update({'avatar_url': publicUrl}).eq('id', userId);
      return publicUrl;
    } catch (e) {
      lastUploadError = e.toString();
      debugPrint('[UserAvatarUpload] FAILED: $e');
      return null;
    }
  }

  Future<void> updatePatientProfile(String id, PatientProfile profile) async {
    try {
      await client.from('patient_profiles').update(profile.toMap()).eq('id', id);
    } catch (e) {
      debugPrint('Error updating patient profile: $e');
      rethrow;
    }
  }

  // Fetch all devices whose profile_id is in the current guardian's patient profiles
  Future<List<Map<String, dynamic>>> fetchDevicesForGuardian() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      // First get the guardian's profile IDs
      final profiles = await client
          .from('patient_profiles')
          .select('id')
          .eq('guardian_id', userId);

      final profileIds = (profiles as List).map((p) => p['id'] as String).toList();
      if (profileIds.isEmpty) return [];

      final response = await client
          .from('devices')
          .select()
          .inFilter('profile_id', profileIds)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching devices for guardian: $e');
      return [];
    }
  }

  // Fetch the current logged-in user's profile from the profiles table
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;
    return getUserProfile(userId);
  }

  Future<List<Map<String, dynamic>>> fetchVaultDocuments(String profileId) async {
    try {
      final response = await client
          .from('app_vault')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching vault documents: $e');
      return [];
    }
  }

  Future<void> createVaultDocument({
    required String profileId,
    required String guardianId,
    required String title,
    required String fileUrl,
    required String fileType,
    required int fileSizeKb,
  }) async {
    await client.from('app_vault').insert({
      'id': const Uuid().v4(),
      'profile_id': profileId,
      'guardian_id': guardianId,
      'title': title,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size_kb': fileSizeKb,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteVaultDocument({
    required String documentId,
    String? storagePath,
  }) async {
    await client.from('app_vault').delete().eq('id', documentId);
    if (storagePath != null &&
        storagePath.isNotEmpty &&
        !storagePath.startsWith('http')) {
      try {
        await client.storage.from('vault-docs').remove([storagePath]);
      } catch (e) {
        debugPrint('Error deleting file from storage: $e');
      }
    }
  }

  Future<String> uploadVaultDocumentBytes({
    required Uint8List bytes,
    required String guardianId,
    required String profileId,
    required String fileName,
    required String contentType,
  }) async {
    final safeFileName = fileName.replaceAll(' ', '_');
    final storagePath =
        '$guardianId/$profileId/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';
    await client.storage.from('vault-docs').uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(
        upsert: false,
        contentType: contentType,
      ),
    );
    return storagePath;
  }

  Future<String> createVaultDocumentSignedUrl(String storagePath) async {
    return client.storage.from('vault-docs').createSignedUrl(storagePath, 60 * 60);
  }

  Future<Map<String, dynamic>?> fetchPatientProfileById(String profileId) async {
    try {
      final row = await client
          .from('patient_profiles')
          .select()
          .eq('id', profileId)
          .maybeSingle();
      if (row == null) return null;
      return Map<String, dynamic>.from(row);
    } catch (e) {
      debugPrint('Error fetching patient profile by id: $e');
      return null;
    }
  }

  /// Internal form sent to RPC; also produced by normalizing HTTPS public QR payloads.
  static const String qrPayloadPrefix = 'qlink://qr/';

  /// Project origin, e.g. `https://xxxx.supabase.co` (derived from REST URL).
  String get projectHttpOrigin {
    final u = Uri.parse(client.rest.url);
    return '${u.scheme}://${u.authority}';
  }

  /// Camera-friendly barcode: HTTPS opens in Safari/Chrome without `qlink://` handling.
  /// Tokens are UUIDs (`[0-9a-f-]`); omit `encodeURIComponent` so cheap scanners don't break on `%`.
  String buildPublicEmergencyQrPayload(String token) {
    return '$projectHttpOrigin/functions/v1/public-emergency?t=$token';
  }

  Future<String?> ensurePublicQrToken(String profileId) async {
    try {
      final row = await client
          .from('patient_profiles')
          .select('public_qr_token')
          .eq('id', profileId)
          .maybeSingle();
      final existing = row?['public_qr_token']?.toString();
      if (existing != null && existing.isNotEmpty) return existing;
      final fresh = const Uuid().v4();
      await client.from('patient_profiles').update({
        'public_qr_token': fresh,
      }).eq('id', profileId);
      return fresh;
    } catch (e) {
      debugPrint('ensurePublicQrToken: $e');
      return null;
    }
  }

  /// Server records [notifications] row (`qr_scan`) and returns a safe profile JSON slice.
  Future<Map<String, dynamic>?> recordQrScanAndFetchEmergency(String rawPayload) async {
    try {
      final res = await client.rpc(
        'record_qr_scan_and_fetch_emergency',
        params: {'p_qr_payload': rawPayload.trim()},
      );
      if (res == null) return null;
      if (res is Map<String, dynamic>) return res;
      if (res is Map) return Map<String, dynamic>.from(res);
      return null;
    } catch (e) {
      debugPrint('record_qr_scan_and_fetch_emergency: $e');
      return null;
    }
  }

  Future<void> sendWearerLinkRequestByEmail(String wearerEmail) async {
    final guardianId = client.auth.currentUser?.id;
    if (guardianId == null) throw Exception('Not authenticated');

    final normalizedEmail = wearerEmail.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('Wearer email is required');
    }

    final wearerProfile = await client
        .from('profiles')
        .select('id, email, role')
        .ilike('email', normalizedEmail)
        .maybeSingle();

    if (wearerProfile == null) {
      throw Exception('No account found with this email');
    }

    final wearerId = (wearerProfile['id'] ?? '').toString();
    final wearerRole = (wearerProfile['role'] ?? '').toString().toLowerCase();
    if (wearerId.isEmpty) throw Exception('Invalid wearer account');
    if (wearerId == guardianId) throw Exception('You cannot link your own account');
    if (wearerRole != 'wearer') {
      throw Exception('This email belongs to a non-wearer account');
    }

    final alreadyPending = await client
        .from('wearer_link_requests')
        .select('id')
        .eq('guardian_id', guardianId)
        .eq('wearer_id', wearerId)
        .eq('status', 'pending')
        .maybeSingle();

    if (alreadyPending != null) {
      throw Exception('A pending request already exists for this wearer');
    }

    final requestId = const Uuid().v4();
    await client.from('wearer_link_requests').insert({
      'id': requestId,
      'guardian_id': guardianId,
      'wearer_id': wearerId,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    final guardianProfile = await client
        .from('profiles')
        .select('full_name, email')
        .eq('id', guardianId)
        .maybeSingle();
    final guardianName = (guardianProfile?['full_name'] ?? 'Guardian').toString();

    await client.from('notifications').insert({
      'id': const Uuid().v4(),
      'guardian_id': wearerId,
      'profile_id': wearerId,
      'title': 'Link Request',
      'body': '$guardianName invited you to join their safety circle.',
      'type': 'wearer_link_request',
      'is_read': false,
    });
  }

  Future<List<Map<String, dynamic>>> fetchPendingWearerLinkRequests() async {
    final wearerId = client.auth.currentUser?.id;
    if (wearerId == null) return [];

    final rows = await client
        .from('wearer_link_requests')
        .select('id, guardian_id, wearer_id, status, created_at')
        .eq('wearer_id', wearerId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    final requests = List<Map<String, dynamic>>.from(rows as List);
    if (requests.isEmpty) return [];

    final guardianIds = requests.map((e) => e['guardian_id'].toString()).toSet().toList();
    final guardians = await client
        .from('profiles')
        .select('id, full_name, email, avatar_url')
        .inFilter('id', guardianIds);
    final guardianMap = {
      for (final g in List<Map<String, dynamic>>.from(guardians as List))
        g['id'].toString(): g
    };

    return requests.map((req) {
      final guardian = guardianMap[req['guardian_id'].toString()];
      return {
        ...req,
        'guardian_name': guardian?['full_name'] ?? 'Guardian',
        'guardian_email': guardian?['email'] ?? '',
        'guardian_avatar_url': guardian?['avatar_url'] ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAcceptedWearerGuardians() async {
    final wearerId = client.auth.currentUser?.id;
    if (wearerId == null) return [];

    final rows = await client
        .from('wearer_link_requests')
        .select('guardian_id, responded_at')
        .eq('wearer_id', wearerId)
        .eq('status', 'accepted')
        .order('responded_at', ascending: false);

    final accepted = List<Map<String, dynamic>>.from(rows as List);
    if (accepted.isEmpty) return [];

    final guardianIds = accepted
        .map((e) => (e['guardian_id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (guardianIds.isEmpty) return [];

    final guardians = await client
        .from('profiles')
        .select('id, full_name, email, avatar_url')
        .inFilter('id', guardianIds);
    final guardianMap = {
      for (final g in List<Map<String, dynamic>>.from(guardians as List))
        g['id'].toString(): g
    };

    return accepted.map((row) {
      final guardian = guardianMap[(row['guardian_id'] ?? '').toString()];
      return {
        'guardian_id': row['guardian_id'],
        'responded_at': row['responded_at'],
        'guardian_name': guardian?['full_name'] ?? 'Guardian',
        'guardian_email': guardian?['email'] ?? '',
        'guardian_avatar_url': guardian?['avatar_url'] ?? '',
      };
    }).toList();
  }

  Future<void> respondToWearerLinkRequest({
    required String requestId,
    required bool accept,
  }) async {
    final wearerId = client.auth.currentUser?.id;
    if (wearerId == null) throw Exception('Not authenticated');

    final request = await client
        .from('wearer_link_requests')
        .select('id, guardian_id, wearer_id, status')
        .eq('id', requestId)
        .eq('wearer_id', wearerId)
        .maybeSingle();

    if (request == null) throw Exception('Request not found');
    if ((request['status'] ?? '') != 'pending') {
      throw Exception('Request already processed');
    }

    final guardianId = request['guardian_id'].toString();
    final wearerProfile = await client
        .from('profiles')
        .select('full_name, email, avatar_url')
        .eq('id', wearerId)
        .maybeSingle();

    final wearerName = (wearerProfile?['full_name'] ?? '').toString().trim().isEmpty
        ? (wearerProfile?['email'] ?? 'Wearer').toString()
        : (wearerProfile?['full_name'] ?? 'Wearer').toString();
    final wearerAvatar = (wearerProfile?['avatar_url'] ?? '').toString();

    if (accept) {
      final existing = await client
          .from('patient_profiles')
          .select('id')
          .eq('guardian_id', guardianId)
          .eq('profile_name', wearerName)
          .eq('relationship_to_guardian', 'Wearer')
          .maybeSingle();

      if (existing == null) {
        await client.from('patient_profiles').insert({
          'id': const Uuid().v4(),
          'guardian_id': guardianId,
          'profile_name': wearerName,
          'relationship_to_guardian': 'Wearer',
          'birth_year': 0,
          'blood_type': '',
          'allergies_en': '',
          'medical_notes_en': '',
          'safety_notes_en': '',
          'emergency_contacts': {},
          'avatar_url': wearerAvatar,
          'status': true,
          'seo_slug':
              '${wearerName.toLowerCase().replaceAll(' ', '-')}-${const Uuid().v4().substring(0, 6)}',
        });
      }
    }

    await client
        .from('wearer_link_requests')
        .update({
          'status': accept ? 'accepted' : 'rejected',
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('wearer_id', wearerId);

    await client.from('notifications').insert({
      'id': const Uuid().v4(),
      'guardian_id': guardianId,
      'profile_id': guardianId,
      'title': 'Wearer Link ${accept ? 'Accepted' : 'Declined'}',
      'body': accept
          ? '$wearerName accepted your link request.'
          : '$wearerName declined your link request.',
      'type': 'wearer_link_response',
      'is_read': false,
    });
  }

  /// Returns latest location per profile from `app_locations` if table exists.
  Future<Map<String, Map<String, double>>> fetchLatestProfileLocations() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return {};

      final rows = await client
          .from('app_locations')
          .select('profile_id, latitude, longitude, recorded_at')
          .eq('guardian_id', userId)
          .order('recorded_at', ascending: false);

      final result = <String, Map<String, double>>{};
      for (final row in List<Map<String, dynamic>>.from(rows as List)) {
        final profileId = (row['profile_id'] ?? '').toString();
        if (profileId.isEmpty || result.containsKey(profileId)) continue;
        final lat = (row['latitude'] as num?)?.toDouble();
        final lng = (row['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;
        result[profileId] = {'lat': lat, 'lng': lng};
      }
      return result;
    } catch (e) {
      debugPrint('app_locations unavailable or failed: $e');
      return {};
    }
  }

  Future<void> deleteNotificationById(String notificationId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null || notificationId.isEmpty) return;
    await client.from('notifications').delete().eq('id', notificationId).eq('guardian_id', userId);
  }

  Future<void> deleteAllNotificationsForCurrentUser() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    await client.from('notifications').delete().eq('guardian_id', userId);
  }
}