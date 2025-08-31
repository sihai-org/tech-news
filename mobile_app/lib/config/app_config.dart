class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL', 
    defaultValue: 'YOUR_SUPABASE_URL_HERE', // 替换为你的 Supabase URL
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY', 
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE', // 替换为你的 Supabase Anon Key
  );
  
  // App Configuration
  static const String appName = 'GitHub Radar News';
  static const String appVersion = '1.2.0';
  
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
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE';
}