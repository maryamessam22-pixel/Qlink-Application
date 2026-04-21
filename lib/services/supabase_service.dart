import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:q_link/core/models/patient_profile.dart';

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

  // 3. Fetching all profiles for demo purposes
  Future<List<PatientProfile>> fetchPatientProfiles() async {
    try {
      // Note: Filter on guardian_id is removed to display all profiles in the table for demo visibility
      final response = await client
          .from('patient_profiles')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((data) => PatientProfile.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching patient profiles: $e');
      return [];
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

      final storagePath = 'profiles/$profileId.jpg';

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

  Future<void> updatePatientProfile(String id, PatientProfile profile) async {
    try {
      await client.from('patient_profiles').update(profile.toMap()).eq('id', id);
    } catch (e) {
      debugPrint('Error updating patient profile: $e');
      rethrow;
    }
  }
}