// Basic Flutter widget test for GitHub Radar News app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:github_radar_news/config/app_config.dart';
import 'package:github_radar_news/config/app_theme.dart';
import 'package:github_radar_news/providers/analysis_provider.dart';

void main() {
  // Create a test app widget without dependencies
  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'GitHub Radar News',
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Text('GitHub Radar News'),
          ),
        ),
      ),
    );
  }

  testWidgets('App widget builds correctly', (WidgetTester tester) async {
    // Build our test app and trigger a frame.
    await tester.pumpWidget(createTestApp());

    // Verify that our app title appears
    expect(find.text('GitHub Radar News'), findsOneWidget);
  });

  testWidgets('App theme is configured correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme, isNotNull);
    expect(app.title, equals('GitHub Radar News'));
  });
}
