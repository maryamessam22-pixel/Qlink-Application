import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // Example of a connection helper
  Future<void> initialize() async {
    // Initialization logic if needed (usually handled in main)
  }

  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  
  Session? get currentSession => client.auth.currentSession;
}
