import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'build_config.dart';

class AppConfig {
  // Supabase Configuration - Priority: build-time config > .env file > defaults
  static String get supabaseUrl {
    // Check if build-time configuration is valid
    if (BuildConfig.hasValidConfig) {
      debugPrint('Using build-time Supabase URL');
      return BuildConfig.supabaseUrl;
    }
    
    // Fall back to .env file
    final envUrl = dotenv.env['SUPABASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      debugPrint('Using .env Supabase URL');
      return envUrl;
    }
    
    debugPrint('Using default Supabase URL - this will likely fail');
    return 'YOUR_SUPABASE_URL_HERE';
  }
          
  static String get supabaseAnonKey {
    // Check if build-time configuration is valid
    if (BuildConfig.hasValidConfig) {
      debugPrint('Using build-time Supabase ANON Key');
      return BuildConfig.supabaseAnonKey;
    }
    
    // Fall back to .env file
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      debugPrint('Using .env Supabase ANON Key');
      return envKey;
    }
    
    debugPrint('Using default Supabase ANON Key - this will likely fail');
    return 'YOUR_SUPABASE_ANON_KEY_HERE';
  }
  
  // App Configuration - Priority: compile-time constants > .env file > defaults
  static String get appName => 
      const String.fromEnvironment('APP_NAME', defaultValue: '') != ''
          ? const String.fromEnvironment('APP_NAME')
          : dotenv.env['APP_NAME'] ?? 'GitHub Radar News';
          
  static String get appVersion => 
      const String.fromEnvironment('APP_VERSION', defaultValue: '') != ''
          ? const String.fromEnvironment('APP_VERSION')
          : dotenv.env['APP_VERSION'] ?? '1.2.1';
  
  // Cache Configuration
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Database Table Names
  static const String analysesTable = 'github_radar_analyses';
  static const String collectionsTable = 'github_radar_collections';
  static const String repositoriesTable = 'github_radar_repositories';
  
  // Supabase Configuration Validation
  static bool get isSupabaseConfigured => 
      supabaseUrl != 'YOUR_SUPABASE_URL_HERE' && 
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}