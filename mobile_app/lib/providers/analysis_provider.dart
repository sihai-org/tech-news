import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class AnalysisProvider extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();
  final CacheService _cacheService = CacheService();

  // State
  List<Analysis> _analyses = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  ApiError? _error;
  String? _selectedLanguage;
  String? _selectedCollectionType;
  List<String> _availableLanguages = [];
  
  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;

  // Getters
  List<Analysis> get analyses => _analyses;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  ApiError? get error => _error;
  String? get selectedLanguage => _selectedLanguage;
  String? get selectedCollectionType => _selectedCollectionType;
  List<String> get availableLanguages => _availableLanguages;
  bool get hasNextPage => _hasNextPage;
  int get currentPage => _currentPage;

  // Initialize and load data
  Future<void> initialize() async {
    await loadAnalyses(useCache: true);
    await loadAvailableLanguages();
  }

  // Load analyses with caching support
  Future<void> loadAnalyses({
    bool refresh = false,
    bool useCache = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    
    if (refresh) {
      _analyses.clear();
      _currentPage = 1;
      _hasNextPage = true;
    }
    
    notifyListeners();

    try {
      // Try cache first if requested and not refreshing
      if (useCache && !refresh && _analyses.isEmpty) {
        final cachedAnalyses = await _cacheService.getCachedAnalyses();
        if (cachedAnalyses != null && cachedAnalyses.isNotEmpty) {
          _analyses = cachedAnalyses;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Fetch from API
      final result = await _analysisService.getAnalyses(
        page: _currentPage,
        language: _selectedLanguage,
        collectionType: _selectedCollectionType,
      );

      if (result.isSuccess) {
        final response = result.data!;
        
        if (_currentPage == 1) {
          _analyses = response.data;
          // Cache the first page
          await _cacheService.cacheAnalyses(_analyses);
        } else {
          _analyses.addAll(response.data);
        }
        
        _hasNextPage = response.hasNextPage;
        _currentPage = response.currentPage;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = ApiError(message: 'Failed to load analyses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more analyses (pagination)
  Future<void> loadMoreAnalyses() async {
    if (_isLoadingMore || !_hasNextPage || _isLoading) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _analysisService.getAnalyses(
        page: _currentPage + 1,
        language: _selectedLanguage,
        collectionType: _selectedCollectionType,
      );

      if (result.isSuccess) {
        final response = result.data!;
        _analyses.addAll(response.data);
        _hasNextPage = response.hasNextPage;
        _currentPage = response.currentPage;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = ApiError(message: 'Failed to load more analyses: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load available languages
  Future<void> loadAvailableLanguages() async {
    try {
      // Try cache first
      final cachedLanguages = await _cacheService.getCachedLanguages();
      if (cachedLanguages != null) {
        _availableLanguages = cachedLanguages;
        notifyListeners();
        return;
      }

      // Fetch from API
      final result = await _analysisService.getAvailableLanguages();
      if (result.isSuccess) {
        _availableLanguages = result.data!;
        await _cacheService.cacheLanguages(_availableLanguages);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load available languages: $e');
    }
  }

  // Filter by language
  Future<void> setLanguageFilter(String? language) async {
    if (_selectedLanguage == language) return;
    
    _selectedLanguage = language;
    await _cacheService.setLanguageFilter(language);
    _currentPage = 1;
    _hasNextPage = true;
    await loadAnalyses(refresh: true);
  }

  // Filter by collection type
  Future<void> setCollectionTypeFilter(String? collectionType) async {
    if (_selectedCollectionType == collectionType) return;
    
    _selectedCollectionType = collectionType;
    _currentPage = 1;
    _hasNextPage = true;
    await loadAnalyses(refresh: true);
  }

  // Search analyses
  Future<void> searchAnalyses(String query) async {
    if (query.isEmpty) {
      await loadAnalyses(refresh: true);
      return;
    }

    _isLoading = true;
    _error = null;
    _analyses.clear();
    notifyListeners();

    try {
      final result = await _analysisService.searchAnalyses(query);
      if (result.isSuccess) {
        _analyses = result.data!;
        _hasNextPage = false; // Search doesn't support pagination yet
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = ApiError(message: 'Failed to search analyses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get analysis by ID
  Future<Analysis?> getAnalysisById(String id) async {
    // First check if it's already in our list
    try {
      return _analyses.firstWhere((analysis) => analysis.id == id);
    } catch (e) {
      // Not found in list, fetch from API
      final result = await _analysisService.getAnalysisById(id);
      if (result.isSuccess) {
        return result.data;
      } else {
        _error = result.error;
        notifyListeners();
        return null;
      }
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data
  void clear() {
    _analyses.clear();
    _availableLanguages.clear();
    _selectedLanguage = null;
    _selectedCollectionType = null;
    _currentPage = 1;
    _hasNextPage = true;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    notifyListeners();
  }
}