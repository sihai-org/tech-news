import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import 'supabase_client.dart';
import 'service_result.dart';

class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  final SupabaseClientService _supabaseClient = SupabaseClientService();
  
  SupabaseClient get _client => _supabaseClient.client;

  /// Get paginated list of analyses
  Future<ServiceResult<PaginatedResponse<Analysis>>> getAnalyses({
    int page = 1,
    int perPage = 20,
    String? language,
    String? collectionType,
    String? searchQuery,
  }) async {
    try {
      // Calculate offset for pagination
      final offset = (page - 1) * perPage;
      
      // Build the query
      PostgrestFilterBuilder query = _client
          .from(AppConfig.analysesTable)
          .select('*');

      // Apply filters
      if (language != null && language.isNotEmpty) {
        query = query.eq('repository_language', language);
      }
      if (collectionType != null && collectionType.isNotEmpty) {
        query = query.eq('collection_type', collectionType);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,analysis_content.ilike.%$searchQuery%,repository_full_name.ilike.%$searchQuery%');
      }

      // Execute query with pagination and ordering
      final response = await query
          .order('analyzed_at', ascending: false)
          .range(offset, offset + perPage - 1);

      // Build count query with same filters
      PostgrestFilterBuilder countQuery = _client
          .from(AppConfig.analysesTable)
          .select('id');

      // Apply same filters for count
      if (language != null && language.isNotEmpty) {
        countQuery = countQuery.eq('repository_language', language);
      }
      if (collectionType != null && collectionType.isNotEmpty) {
        countQuery = countQuery.eq('collection_type', collectionType);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.or('title.ilike.%$searchQuery%,analysis_content.ilike.%$searchQuery%,repository_full_name.ilike.%$searchQuery%');
      }

      final countResult = await countQuery;
      final total = (countResult as List<dynamic>).length;
      final totalPages = (total / perPage).ceil();

      // Convert response to Analysis objects
      final analyses = <Analysis>[];
      for (final item in (response as List<dynamic>)) {
        try {
          final itemMap = item as Map<String, dynamic>;
          
          // Handle potential DateTime format issues from Supabase
          if (itemMap['analyzed_at'] != null && itemMap['analyzed_at'] is! String) {
            itemMap['analyzed_at'] = itemMap['analyzed_at'].toString();
          }
          if (itemMap['created_at'] != null && itemMap['created_at'] is! String) {
            itemMap['created_at'] = itemMap['created_at'].toString();
          }
          
          final analysis = Analysis.fromJson(itemMap);
          analyses.add(analysis);
        } catch (e) {
          debugPrint('Failed to parse analysis item: $e');
          debugPrint('Item data: $item');
          debugPrint('Item type: ${item.runtimeType}');
          // Skip this item and continue with others
        }
      }

      final paginatedResponse = PaginatedResponse<Analysis>(
        data: analyses,
        total: total,
        currentPage: page,
        perPage: perPage,
        totalPages: totalPages,
      );

      return ServiceResult.success(paginatedResponse);
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch analyses: $e'),
      );
    }
  }

  /// Get a single analysis by ID
  Future<ServiceResult<Analysis>> getAnalysisById(String id) async {
    try {
      final response = await _client
          .from(AppConfig.analysesTable)
          .select('*')
          .eq('id', id)
          .single();

      final responseMap = response;
      
      // Handle potential DateTime format issues from Supabase
      if (responseMap['analyzed_at'] != null && responseMap['analyzed_at'] is! String) {
        responseMap['analyzed_at'] = responseMap['analyzed_at'].toString();
      }
      if (responseMap['created_at'] != null && responseMap['created_at'] is! String) {
        responseMap['created_at'] = responseMap['created_at'].toString();
      }

      final analysis = Analysis.fromJson(responseMap);
      return ServiceResult.success(analysis);
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch analysis: $e'),
      );
    }
  }

  /// Get latest analyses (simplified version of getAnalyses)
  Future<ServiceResult<List<Analysis>>> getLatestAnalyses({
    int limit = 10,
    String? language,
  }) async {
    try {
      final result = await getAnalyses(
        page: 1,
        perPage: limit,
        language: language,
      );

      if (result.isSuccess) {
        return ServiceResult.success(result.data!.data);
      } else {
        return ServiceResult.failure(result.error!);
      }
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch latest analyses: $e'),
      );
    }
  }

  /// Get analyses by collection type
  Future<ServiceResult<List<Analysis>>> getAnalysesByType(
    String collectionType, {
    int limit = 20,
    String? language,
  }) async {
    try {
      final result = await getAnalyses(
        page: 1,
        perPage: limit,
        collectionType: collectionType,
        language: language,
      );

      if (result.isSuccess) {
        return ServiceResult.success(result.data!.data);
      } else {
        return ServiceResult.failure(result.error!);
      }
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch analyses by type: $e'),
      );
    }
  }

  /// Search analyses by query
  Future<ServiceResult<List<Analysis>>> searchAnalyses(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await getAnalyses(
        page: page,
        perPage: perPage,
        searchQuery: query,
      );

      if (result.isSuccess) {
        return ServiceResult.success(result.data!.data);
      } else {
        return ServiceResult.failure(result.error!);
      }
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to search analyses: $e'),
      );
    }
  }

  /// Get available languages from analyses
  Future<ServiceResult<List<String>>> getAvailableLanguages() async {
    try {
      final response = await _client
          .from(AppConfig.analysesTable)
          .select('repository_language')
          .not('repository_language', 'is', null);

      // Extract unique languages
      final Set<String> languagesSet = {};
      for (final record in response) {
        final language = record['repository_language'] as String?;
        if (language != null && language.isNotEmpty) {
          languagesSet.add(language);
        }
      }

      final languages = languagesSet.toList()..sort();
      return ServiceResult.success(languages);
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch available languages: $e'),
      );
    }
  }

  /// Get analysis statistics
  Future<ServiceResult<Map<String, dynamic>>> getStatistics() async {
    try {
      // Get total count
      final totalCountResponse = await _client
          .from(AppConfig.analysesTable)
          .select('id');

      final totalCount = totalCountResponse.length;

      // Get count by collection type
      final trendingCountResponse = await _client
          .from(AppConfig.analysesTable)
          .select('id')
          .eq('collection_type', 'trending');

      final fastGrowingCountResponse = await _client
          .from(AppConfig.analysesTable)
          .select('id')
          .eq('collection_type', 'fastest_growing');

      final newlyPublishedCountResponse = await _client
          .from(AppConfig.analysesTable)
          .select('id')
          .eq('collection_type', 'newly_published');

      // Get latest analysis date
      final latestAnalysisResponse = await _client
          .from(AppConfig.analysesTable)
          .select('analyzed_at')
          .order('analyzed_at', ascending: false)
          .limit(1);

      String? latestAnalysisDate;
      final latestAnalysisList = latestAnalysisResponse;
      if (latestAnalysisList.isNotEmpty) {
        latestAnalysisDate = latestAnalysisList[0]['analyzed_at'];
      }

      final statistics = {
        'total_analyses': totalCount,
        'trending_count': trendingCountResponse.length,
        'fast_growing_count': fastGrowingCountResponse.length,
        'newly_published_count': newlyPublishedCountResponse.length,
        'latest_analysis_date': latestAnalysisDate,
      };

      return ServiceResult.success(statistics);
    } catch (e) {
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch statistics: $e'),
      );
    }
  }
}