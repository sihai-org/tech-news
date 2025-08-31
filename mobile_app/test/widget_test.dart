// Basic Flutter widget test for GitHub Radar News app

import 'package:flutter_test/flutter_test.dart';

import 'package:github_radar_news/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GitHubRadarApp());

    // Verify that our app title appears
    expect(find.text('GitHub Radar News'), findsOneWidget);
  });
}
