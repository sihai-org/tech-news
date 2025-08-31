import 'package:json_annotation/json_annotation.dart';

part 'analysis.g.dart';

@JsonSerializable()
class Analysis {
  final String id;
  @JsonKey(name: 'repository_full_name')
  final String repositoryFullName;
  @JsonKey(name: 'repository_url')
  final String repositoryUrl;
  @JsonKey(name: 'repository_language')
  final String? repositoryLanguage;
  @JsonKey(name: 'repository_stars')
  final int repositoryStars;
  @JsonKey(name: 'repository_description')
  final String? repositoryDescription;
  final String title;
  @JsonKey(name: 'analysis_content')
  final String analysisContent;
  @JsonKey(name: 'markdown_content')
  final String markdownContent;
  @JsonKey(name: 'collection_name')
  final String? collectionName;
  @JsonKey(name: 'collection_type')
  final String? collectionType;
  @JsonKey(name: 'analyzed_at')
  final DateTime analyzedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Analysis({
    required this.id,
    required this.repositoryFullName,
    required this.repositoryUrl,
    this.repositoryLanguage,
    required this.repositoryStars,
    this.repositoryDescription,
    required this.title,
    required this.analysisContent,
    required this.markdownContent,
    this.collectionName,
    this.collectionType,
    required this.analyzedAt,
    required this.createdAt,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) => _$AnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$AnalysisToJson(this);

  // Convenience getters
  String get ownerName => repositoryFullName.split('/')[0];
  String get repoName => repositoryFullName.split('/')[1];
  String get languageDisplay => repositoryLanguage ?? 'Unknown';
  String get starsDisplay => repositoryStars >= 1000 
      ? '${(repositoryStars / 1000).toStringAsFixed(1)}k'
      : repositoryStars.toString();
  
  // Get collection type display name
  String get collectionTypeDisplay {
    switch (collectionType) {
      case 'trending':
        return 'Trending';
      case 'fastest_growing':
        return 'Fast Growing';
      case 'newly_published':
        return 'New Projects';
      default:
        return 'Analysis';
    }
  }
  
  // Get a short summary from analysis content
  String get summary {
    final words = analysisContent.split(' ');
    if (words.length <= 30) return analysisContent;
    return '${words.take(30).join(' ')}...';
  }
}

@JsonSerializable()
class AnalysisList {
  final List<Analysis> data;
  final int total;
  @JsonKey(name: 'page')
  final int currentPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  const AnalysisList({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.totalPages,
  });

  factory AnalysisList.fromJson(Map<String, dynamic> json) => _$AnalysisListFromJson(json);
  Map<String, dynamic> toJson() => _$AnalysisListToJson(this);
  
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;
}