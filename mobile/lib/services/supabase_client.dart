import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  bool _isInitialized = false;
  
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('Supabase client is not initialized. Please check your configuration.');
    }
    return Supabase.instance.client;
  }

  bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    final instance = SupabaseClientService._instance;
    
    if (!AppConfig.isSupabaseConfigured) {
      debugPrint('Warning: Supabase configuration not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY.');
      debugPrint('Current config: URL=${AppConfig.supabaseUrl}, Key=${AppConfig.supabaseAnonKey.substring(0, 10)}...');
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
      
      instance._isInitialized = true;
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