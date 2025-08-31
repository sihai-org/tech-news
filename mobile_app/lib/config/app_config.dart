class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000'; // 后端API地址，需要根据实际情况修改
  static const String apiVersion = 'v1';
  
  // Supabase Configuration (如果直接连接Supabase)
  static const String supabaseUrl = ''; // 从环境变量获取
  static const String supabaseAnonKey = ''; // 从环境变量获取
  
  // App Configuration
  static const String appName = 'GitHub Radar News';
  static const String appVersion = '1.0.0';
  
  // Cache Configuration
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // API Endpoints
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  static String get analysesEndpoint => '$apiBaseUrl/analyses';
  static String get collectionsEndpoint => '$apiBaseUrl/collections';
  static String get repositoriesEndpoint => '$apiBaseUrl/repositories';
}