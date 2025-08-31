import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration - Priority: compile-time constants > .env file > defaults
  static String get supabaseUrl => 
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '') != '' 
          ? const String.fromEnvironment('SUPABASE_URL')
          : dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL_HERE';
          
  static String get supabaseAnonKey => 
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '') != ''
          ? const String.fromEnvironment('SUPABASE_ANON_KEY') 
          : dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY_HERE';
  
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