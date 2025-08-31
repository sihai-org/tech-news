import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!AppConfig.isSupabaseConfigured) {
      debugPrint('Warning: Supabase configuration not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
      
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      await client
          .from(AppConfig.analysesTable)
          .select('id')
          .limit(1);
      return true;
    } catch (e) {
      debugPrint('Supabase connection test failed: $e');
      return false;
    }
  }

  // Get current connection status
  bool get isConnected => client.auth.currentSession != null;
}