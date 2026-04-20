import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:q_link/core/models/patient_profile.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  Future<void> initialize() async {}

  // 1. EL LOGIN SHA8AL ZAY EL FOL
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
      print('Error signing in: $e');
      rethrow;
    }
  }

  // 2. EL SIGN UP SHA8AL ZAY EL FOL (Auth + Profiles Table)
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
      print('Error signing up: $e');
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
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // 3. HNA EL TRICKA: BY-GEEB EL DATA KOLAHA LEL DEMO (Karma w Mohamed Saber)
  Future<List<PatientProfile>> fetchPatientProfiles() async {
    try {
      // Shilt el filter bta3 el (guardian_id) 3shan n-geeb kol el data elly fel table t-zhar 3altol
      final response = await client
          .from('patient_profiles')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((data) => PatientProfile.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching patient profiles: $e');
      return [];
    }
  }

  Future<void> createPatientProfile(PatientProfile profile) async {
    try {
      await client.from('patient_profiles').insert(profile.toMap());
    } catch (e) {
      print('Error creating patient profile: $e');
      rethrow;
    }
  }

  /// Uploads a local image file to Supabase Storage and returns the public URL.
  /// Returns null if upload fails or if running on web with a non-http path.
  Future<String?> uploadProfileAvatar(String localPath, String profileId) async {
    if (localPath.isEmpty ||
        localPath.startsWith('assets') ||
        localPath.startsWith('http')) {
      return null;
    }

    if (kIsWeb) return null;

    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final ext = localPath.split('.').last.toLowerCase();
      final storagePath = 'profiles/$profileId.$ext';

      await client.storage.from('avatars').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return client.storage.from('avatars').getPublicUrl(storagePath);
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  Future<void> updatePatientProfile(String id, PatientProfile profile) async {
    try {
      await client.from('patient_profiles').update(profile.toMap()).eq('id', id);
    } catch (e) {
      print('Error updating patient profile: $e');
      rethrow;
    }
  }
}