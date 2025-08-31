import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/models.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Cache keys
  static const String _analysesKey = 'cached_analyses';
  static const String _languagesKey = 'cached_languages';
  static const String _statsKey = 'cached_stats';
  static const String _lastUpdateKey = 'last_update';

  /// Check if cache is valid (not expired)
  bool _isCacheValid(String key) {
    final lastUpdate = _prefs?.getInt('${key}_$_lastUpdateKey') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (now - lastUpdate) < AppConfig.cacheMaxAge;
  }

  /// Set cache timestamp
  void _setCacheTimestamp(String key) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _prefs?.setInt('${key}_$_lastUpdateKey', now);
  }

  // Cache analyses
  Future<void> cacheAnalyses(List<Analysis> analyses) async {
    await initialize();
    final jsonString = jsonEncode(analyses.map((a) => a.toJson()).toList());
    await _prefs?.setString(_analysesKey, jsonString);
    _setCacheTimestamp(_analysesKey);
  }

  Future<List<Analysis>?> getCachedAnalyses() async {
    await initialize();
    
    if (!_isCacheValid(_analysesKey)) {
      return null;
    }

    final jsonString = _prefs?.getString(_analysesKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Analysis.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Clear corrupted cache
      await clearAnalysesCache();
      return null;
    }
  }

  Future<void> clearAnalysesCache() async {
    await initialize();
    await _prefs?.remove(_analysesKey);
    await _prefs?.remove('${_analysesKey}_$_lastUpdateKey');
  }

  // Cache languages
  Future<void> cacheLanguages(List<String> languages) async {
    await initialize();
    await _prefs?.setStringList(_languagesKey, languages);
    _setCacheTimestamp(_languagesKey);
  }

  Future<List<String>?> getCachedLanguages() async {
    await initialize();
    
    if (!_isCacheValid(_languagesKey)) {
      return null;
    }

    return _prefs?.getStringList(_languagesKey);
  }

  Future<void> clearLanguagesCache() async {
    await initialize();
    await _prefs?.remove(_languagesKey);
    await _prefs?.remove('${_languagesKey}_$_lastUpdateKey');
  }

  // Cache statistics
  Future<void> cacheStats(Map<String, dynamic> stats) async {
    await initialize();
    final jsonString = jsonEncode(stats);
    await _prefs?.setString(_statsKey, jsonString);
    _setCacheTimestamp(_statsKey);
  }

  Future<Map<String, dynamic>?> getCachedStats() async {
    await initialize();
    
    if (!_isCacheValid(_statsKey)) {
      return null;
    }

    final jsonString = _prefs?.getString(_statsKey);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Clear corrupted cache
      await clearStatsCache();
      return null;
    }
  }

  Future<void> clearStatsCache() async {
    await initialize();
    await _prefs?.remove(_statsKey);
    await _prefs?.remove('${_statsKey}_$_lastUpdateKey');
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await initialize();
    await clearAnalysesCache();
    await clearLanguagesCache();
    await clearStatsCache();
  }

  // App preferences
  Future<void> setThemeMode(String themeMode) async {
    await initialize();
    await _prefs?.setString('theme_mode', themeMode);
  }

  Future<String> getThemeMode() async {
    await initialize();
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  Future<void> setLanguageFilter(String? language) async {
    await initialize();
    if (language != null) {
      await _prefs?.setString('language_filter', language);
    } else {
      await _prefs?.remove('language_filter');
    }
  }

  Future<String?> getLanguageFilter() async {
    await initialize();
    return _prefs?.getString('language_filter');
  }

  // First launch flag
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await initialize();
    await _prefs?.setBool('is_first_launch', isFirstLaunch);
  }

  Future<bool> isFirstLaunch() async {
    await initialize();
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  // Get cache info
  Map<String, bool> getCacheStatus() {
    return {
      'analyses': _isCacheValid(_analysesKey),
      'languages': _isCacheValid(_languagesKey),
      'stats': _isCacheValid(_statsKey),
    };
  }
}