import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:github_radar_news/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    setUpAll(() async {
      // Initialize dotenv for testing
      await dotenv.load(fileName: ".env");
    });

    test('App configuration constants are correct', () {
      expect(AppConfig.appName, equals('GitHub Radar News'));
      expect(AppConfig.appVersion, isA<String>());
      expect(AppConfig.appVersion.isNotEmpty, isTrue);
      expect(AppConfig.analysesTable, equals('github_radar_analyses'));
    });

    test('Supabase configuration is loaded', () {
      // These should not throw and should return some value
      expect(() => AppConfig.supabaseUrl, returnsNormally);
      expect(() => AppConfig.supabaseAnonKey, returnsNormally);
      
      // Should not be empty (assuming .env file exists)
      if (dotenv.isEveryDefined(['SUPABASE_URL', 'SUPABASE_ANON_KEY'])) {
        expect(AppConfig.supabaseUrl.isNotEmpty, isTrue);
        expect(AppConfig.supabaseAnonKey.isNotEmpty, isTrue);
      }
    });

    test('Supabase configuration validation works correctly', () {
      final isConfigured = AppConfig.isSupabaseConfigured;
      
      // Should return a boolean
      expect(isConfigured, isA<bool>());
      
      // Check if URLs are not default values
      expect(AppConfig.supabaseUrl, isNot(equals('YOUR_SUPABASE_URL_HERE')));
      expect(AppConfig.supabaseAnonKey, isNot(equals('YOUR_SUPABASE_ANON_KEY_HERE')));
    });
  });
}