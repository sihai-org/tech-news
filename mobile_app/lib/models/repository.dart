import 'package:json_annotation/json_annotation.dart';

part 'repository.g.dart';

@JsonSerializable()
class Repository {
  final String id;
  @JsonKey(name: 'collection_id')
  final String collectionId;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'html_url')
  final String htmlUrl;
  final String? description;
  final String? language;
  final int stars;
  final int forks;
  @JsonKey(name: 'open_issues')
  final int openIssues;
  @JsonKey(name: 'stars_per_day')
  final double? starsPerDay;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'pushed_at')
  final DateTime pushedAt;
  @JsonKey(name: 'discovered_at')
  final DateTime discoveredAt;

  const Repository({
    required this.id,
    required this.collectionId,
    required this.fullName,
    required this.htmlUrl,
    this.description,
    this.language,
    required this.stars,
    required this.forks,
    required this.openIssues,
    this.starsPerDay,
    required this.createdAt,
    required this.pushedAt,
    required this.discoveredAt,
  });

  factory Repository.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);
  Map<String, dynamic> toJson() => _$RepositoryToJson(this);

  // Convenience getters
  String get ownerName => fullName.split('/')[0];
  String get repoName => fullName.split('/')[1];
  String get languageDisplay => language ?? 'Unknown';
  String get starsDisplay => stars >= 1000 
      ? '${(stars / 1000).toStringAsFixed(1)}k'
      : stars.toString();
  String get forksDisplay => forks >= 1000 
      ? '${(forks / 1000).toStringAsFixed(1)}k'
      : forks.toString();
  
  // Growth rate display
  String get growthRateDisplay {
    if (starsPerDay == null) return '';
    if (starsPerDay! >= 1) {
      return '+${starsPerDay!.toStringAsFixed(1)} stars/day';
    } else {
      return '+${(starsPerDay! * 7).toStringAsFixed(1)} stars/week';
    }
  }
}