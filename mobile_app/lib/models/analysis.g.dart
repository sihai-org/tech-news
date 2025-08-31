// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analysis _$AnalysisFromJson(Map<String, dynamic> json) => Analysis(
      id: json['id'] as String,
      repositoryFullName: json['repository_full_name'] as String,
      repositoryUrl: json['repository_url'] as String,
      repositoryLanguage: json['repository_language'] as String?,
      repositoryStars: (json['repository_stars'] as num).toInt(),
      repositoryDescription: json['repository_description'] as String?,
      title: json['title'] as String,
      analysisContent: json['analysis_content'] as String,
      markdownContent: json['markdown_content'] as String,
      collectionName: json['collection_name'] as String?,
      collectionType: json['collection_type'] as String?,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AnalysisToJson(Analysis instance) => <String, dynamic>{
      'id': instance.id,
      'repository_full_name': instance.repositoryFullName,
      'repository_url': instance.repositoryUrl,
      'repository_language': instance.repositoryLanguage,
      'repository_stars': instance.repositoryStars,
      'repository_description': instance.repositoryDescription,
      'title': instance.title,
      'analysis_content': instance.analysisContent,
      'markdown_content': instance.markdownContent,
      'collection_name': instance.collectionName,
      'collection_type': instance.collectionType,
      'analyzed_at': instance.analyzedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

AnalysisList _$AnalysisListFromJson(Map<String, dynamic> json) => AnalysisList(
      data: (json['data'] as List<dynamic>)
          .map((e) => Analysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      currentPage: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$AnalysisListToJson(AnalysisList instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.currentPage,
      'per_page': instance.perPage,
      'total_pages': instance.totalPages,
    };
