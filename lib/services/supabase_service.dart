import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:q_link/core/models/patient_profile.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  Future<void> initialize() async {}

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error signing in: $e');
      return null;
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

  Future<List<PatientProfile>> fetchPatientProfiles() async {
    try {
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

  Future<void> updatePatientProfile(String id, PatientProfile profile) async {
    try {
      await client.from('patient_profiles').update(profile.toMap()).eq('id', id);
    } catch (e) {
      print('Error updating patient profile: $e');
      rethrow;
    }
  }
}