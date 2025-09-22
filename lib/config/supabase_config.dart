import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase 프로젝트 설정
  static const String supabaseUrl = 'https://bnciolfmdjjwtxyehqkq.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuY2lvbGZtZGpqd3R4eWVocWtxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MDM3NjgsImV4cCI6MjA3NDA3OTc2OH0.5jQdGSUMceheiTyN_CoRZk6ElAHDUAN0TikUQaVTViE';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
