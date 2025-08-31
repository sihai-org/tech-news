import '../models/models.dart';
import 'http_client.dart';

class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  final HttpClient _httpClient = HttpClient();

  /// Get paginated list of analyses
  Future<ServiceResult<PaginatedResponse<Analysis>>> getAnalyses({
    int page = 1,
    int perPage = 20,
    String? language,
    String? collectionType,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }
      if (collectionType != null && collectionType.isNotEmpty) {
        queryParams['collection_type'] = collectionType;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analyses',
        queryParameters: queryParams,
      );

      final paginatedResponse = PaginatedResponse<Analysis>.fromJson(
        response,
        (json) => Analysis.fromJson(json as Map<String, dynamic>),
      );

      return ServiceResult.success(paginatedResponse);
    } catch (e) {
      if (e is ApiError) {
        return ServiceResult.failure(e);
      }
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch analyses: $e'),
      );
    }
  }

  /// Get a single analysis by ID
  Future<ServiceResult<Analysis>> getAnalysisById(String id) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analyses/$id',
      );

      final analysis = Analysis.fromJson(response);
      return ServiceResult.success(analysis);
    } catch (e) {
      if (e is ApiError) {
        return ServiceResult.failure(e);
      }
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
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analyses/languages',
      );

      final languages = (response['languages'] as List)
          .map((lang) => lang.toString())
          .toList();

      return ServiceResult.success(languages);
    } catch (e) {
      if (e is ApiError) {
        return ServiceResult.failure(e);
      }
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch available languages: $e'),
      );
    }
  }

  /// Get analysis statistics
  Future<ServiceResult<Map<String, dynamic>>> getStatistics() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/analyses/stats',
      );

      return ServiceResult.success(response);
    } catch (e) {
      if (e is ApiError) {
        return ServiceResult.failure(e);
      }
      return ServiceResult.failure(
        ApiError(message: 'Failed to fetch statistics: $e'),
      );
    }
  }
}