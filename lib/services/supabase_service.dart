import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:q_link/core/models/patient_profile.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  Future<void> initialize() async {}

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
}