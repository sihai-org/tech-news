import 'package:flutter_test/flutter_test.dart';
import 'package:github_radar_news/models/analysis.dart';

void main() {
  group('Analysis Model Tests', () {
    test('Analysis.fromJson creates valid instance', () {
      final json = {
        'id': 'test-id',
        'repository_full_name': 'test/repo',
        'repository_url': 'https://github.com/test/repo',
        'repository_language': 'Dart',
        'repository_stars': 100,
        'repository_description': 'Test repository',
        'title': 'Test Analysis',
        'analysis_content': 'This is a test analysis content.',
        'markdown_content': '# Test Analysis\n\nThis is a test.',
        'collection_name': 'test_collection',
        'collection_type': 'trending',
        'analyzed_at': '2024-01-01T00:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final analysis = Analysis.fromJson(json);

      expect(analysis.id, equals('test-id'));
      expect(analysis.repositoryFullName, equals('test/repo'));
      expect(analysis.repositoryUrl, equals('https://github.com/test/repo'));
      expect(analysis.repositoryLanguage, equals('Dart'));
      expect(analysis.repositoryStars, equals(100));
      expect(analysis.title, equals('Test Analysis'));
    });

    test('Analysis convenience getters work correctly', () {
      final json = {
        'id': 'test-id',
        'repository_full_name': 'flutter/flutter',
        'repository_url': 'https://github.com/flutter/flutter',
        'repository_language': 'Dart',
        'repository_stars': 1500,
        'repository_description': 'Flutter SDK',
        'title': 'Flutter Analysis',
        'analysis_content': 'This is a long analysis content with more than thirty words to test the summary functionality and see how it truncates the content properly. We need to add even more words here to ensure it exceeds the thirty word limit for summary truncation testing purposes. Let me add some more content to make sure this is definitely longer than thirty words and will trigger the summary truncation logic correctly.',
        'markdown_content': '# Flutter Analysis',
        'collection_type': 'trending',
        'analyzed_at': '2024-01-01T00:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final analysis = Analysis.fromJson(json);

      expect(analysis.ownerName, equals('flutter'));
      expect(analysis.repoName, equals('flutter'));
      expect(analysis.languageDisplay, equals('Dart'));
      expect(analysis.starsDisplay, equals('1.5k'));
      expect(analysis.collectionTypeDisplay, equals('Trending'));
      expect(analysis.summary.length, lessThan(analysis.analysisContent.length));
      expect(analysis.summary.endsWith('...'), isTrue);
    });

    test('Analysis handles null values correctly', () {
      final json = {
        'id': 'test-id',
        'repository_full_name': 'test/repo',
        'repository_url': 'https://github.com/test/repo',
        'repository_stars': 50,
        'title': 'Test Analysis',
        'analysis_content': 'Short content',
        'markdown_content': '# Test',
        'analyzed_at': '2024-01-01T00:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final analysis = Analysis.fromJson(json);

      expect(analysis.repositoryLanguage, isNull);
      expect(analysis.repositoryDescription, isNull);
      expect(analysis.collectionName, isNull);
      expect(analysis.collectionType, isNull);
      expect(analysis.languageDisplay, equals('Unknown'));
      expect(analysis.collectionTypeDisplay, equals('Analysis'));
      expect(analysis.starsDisplay, equals('50'));
      expect(analysis.summary, equals('Short content'));
    });

    test('Analysis.toJson works correctly', () {
      final analysis = Analysis(
        id: 'test-id',
        repositoryFullName: 'test/repo',
        repositoryUrl: 'https://github.com/test/repo',
        repositoryStars: 100,
        title: 'Test Analysis',
        analysisContent: 'Test content',
        markdownContent: '# Test',
        analyzedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final json = analysis.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['repository_full_name'], equals('test/repo'));
      expect(json['repository_stars'], equals(100));
      expect(json['analyzed_at'], isA<String>());
      expect(json['created_at'], isA<String>());
    });
  });
}