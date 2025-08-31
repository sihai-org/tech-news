// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repository _$RepositoryFromJson(Map<String, dynamic> json) => Repository(
      id: json['id'] as String,
      collectionId: json['collection_id'] as String,
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      description: json['description'] as String?,
      language: json['language'] as String?,
      stars: (json['stars'] as num).toInt(),
      forks: (json['forks'] as num).toInt(),
      openIssues: (json['open_issues'] as num).toInt(),
      starsPerDay: (json['stars_per_day'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      pushedAt: DateTime.parse(json['pushed_at'] as String),
      discoveredAt: DateTime.parse(json['discovered_at'] as String),
    );

Map<String, dynamic> _$RepositoryToJson(Repository instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collection_id': instance.collectionId,
      'full_name': instance.fullName,
      'html_url': instance.htmlUrl,
      'description': instance.description,
      'language': instance.language,
      'stars': instance.stars,
      'forks': instance.forks,
      'open_issues': instance.openIssues,
      'stars_per_day': instance.starsPerDay,
      'created_at': instance.createdAt.toIso8601String(),
      'pushed_at': instance.pushedAt.toIso8601String(),
      'discovered_at': instance.discoveredAt.toIso8601String(),
    };
