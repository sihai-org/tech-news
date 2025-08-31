import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'services/services.dart';
import 'screens/home_screen.dart';
import 'providers/analysis_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file (if exists)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not found. Using embedded configuration or defaults.');
  }
  
  // Initialize services
  try {
    await SupabaseClientService.initialize();
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed: $e');
  }
  
  await CacheService().initialize();
  
  runApp(const GitHubRadarApp());
}

class GitHubRadarApp extends StatelessWidget {
  const GitHubRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: Consumer<AnalysisProvider>(
        builder: (context, analysisProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // TODO: Make this configurable
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
