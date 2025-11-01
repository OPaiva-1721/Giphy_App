import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_stats_model.dart';
import '../models/favorite_model.dart';
import '../models/collection_model.dart';
import '../models/search_history_model.dart';
import '../constants/app_constants.dart';

/// Serviço de armazenamento local
class StorageService {
  static SharedPreferences? _prefs;

  /// Inicializa o SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageService não foi inicializado. Chame init() primeiro.',
      );
    }
    return _prefs!;
  }

  // ========== Theme ==========

  Future<bool> saveThemeMode(String mode) async {
    try {
      return await prefs.setString(AppConstants.keyThemeMode, mode);
    } catch (e) {
      debugPrint('[StorageService] Error saving theme mode: $e');
      return false;
    }
  }

  String? getThemeMode() {
    try {
      return prefs.getString(AppConstants.keyThemeMode);
    } catch (e) {
      debugPrint('[StorageService] Error getting theme mode: $e');
      return null;
    }
  }

  // ========== User Stats ==========

  Future<bool> saveUserStats(UserStatsModel stats) async {
    try {
      final json = jsonEncode(stats.toJson());
      return await prefs.setString(AppConstants.keyUserStats, json);
    } catch (e) {
      debugPrint('[StorageService] Error saving user stats: $e');
      return false;
    }
  }

  UserStatsModel? getUserStats() {
    try {
      final json = prefs.getString(AppConstants.keyUserStats);
      if (json != null) {
        return UserStatsModel.fromJson(jsonDecode(json));
      }
    } catch (e) {
      debugPrint('[StorageService] Error getting user stats: $e');
    }
    return null;
  }

  // ========== Favorites ==========

  Future<bool> saveFavorites(List<FavoriteModel> favorites) async {
    try {
      final json = jsonEncode(favorites.map((f) => f.toJson()).toList());
      return await prefs.setString(AppConstants.keyFavorites, json);
    } catch (e) {
      debugPrint('[StorageService] Error saving favorites: $e');
      return false;
    }
  }

  /// Converte recursivamente Map<dynamic, dynamic> para Map<String, dynamic>
  Map<String, dynamic> _convertMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), _convertValue(val)),
      );
    }
    throw Exception('Valor não é um Map');
  }

  /// Converte valores recursivamente
  dynamic _convertValue(dynamic value) {
    if (value is Map) {
      // Converte recursivamente todos os Maps
      return _convertMap(value);
    } else if (value is List) {
      // Converte cada item da lista recursivamente
      return value.map((item) => _convertValue(item)).toList();
    }
    return value;
  }

  List<FavoriteModel> getFavorites() {
    try {
      final json = prefs.getString(AppConstants.keyFavorites);
      if (json != null && json.isNotEmpty) {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded
              .map((item) {
                try {
                  if (item is Map) {
                    // Converte recursivamente Map<dynamic, dynamic> para Map<String, dynamic>
                    final itemMap = _convertMap(item);
                    return FavoriteModel.fromJson(itemMap);
                  }
                } catch (e) {
                  debugPrint(
                    '[StorageService] Error parsing favorite item: $e',
                  );
                  debugPrint('[StorageService] Item: $item');
                  return null;
                }
                return null;
              })
              .whereType<FavoriteModel>()
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Error getting favorites: $e');
      // Não limpa automaticamente - pode ser um problema temporário
      // prefs.remove(AppConstants.keyFavorites);
    }
    return [];
  }

  // ========== Collections ==========

  Future<bool> saveCollections(List<CollectionModel> collections) async {
    try {
      final json = jsonEncode(collections.map((c) => c.toJson()).toList());
      return await prefs.setString(AppConstants.keyCollections, json);
    } catch (e) {
      debugPrint('[StorageService] Error saving collections: $e');
      return false;
    }
  }

  List<CollectionModel> getCollections() {
    try {
      final json = prefs.getString(AppConstants.keyCollections);
      if (json != null && json.isNotEmpty) {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded
              .map((item) {
                try {
                  if (item is Map) {
                    // Converte Map<dynamic, dynamic> para Map<String, dynamic>
                    final itemMap = _convertMap(item);
                    return CollectionModel.fromJson(itemMap);
                  }
                } catch (e) {
                  debugPrint(
                    '[StorageService] Error parsing collection item: $e',
                  );
                  return null;
                }
                return null;
              })
              .whereType<CollectionModel>()
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Error getting collections: $e');
      // Não limpa automaticamente - pode ser um problema temporário
      // prefs.remove(AppConstants.keyCollections);
    }
    return [];
  }

  // ========== Search History ==========

  Future<bool> saveSearchHistory(List<SearchHistoryModel> history) async {
    try {
      final json = jsonEncode(history.map((h) => h.toJson()).toList());
      return await prefs.setString(AppConstants.keySearchHistory, json);
    } catch (e) {
      debugPrint('[StorageService] Error saving search history: $e');
      return false;
    }
  }

  List<SearchHistoryModel> getSearchHistory() {
    try {
      final json = prefs.getString(AppConstants.keySearchHistory);
      if (json != null) {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded
              .map((item) {
                if (item is Map) {
                  return SearchHistoryModel.fromJson(
                    Map<String, dynamic>.from(item),
                  );
                }
                return null;
              })
              .whereType<SearchHistoryModel>()
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Error getting search history: $e');
      // Limpa dados corrompidos
      prefs.remove(AppConstants.keySearchHistory);
    }
    return [];
  }

  // ========== Settings ==========

  Future<bool> saveAutoShuffle(bool value) async {
    try {
      return await prefs.setBool(AppConstants.keyAutoShuffle, value);
    } catch (e) {
      debugPrint('[StorageService] Error saving auto shuffle: $e');
      return false;
    }
  }

  bool getAutoShuffle() {
    try {
      return prefs.getBool(AppConstants.keyAutoShuffle) ?? true;
    } catch (e) {
      debugPrint('[StorageService] Error getting auto shuffle: $e');
      return true;
    }
  }

  Future<bool> saveNotificationsEnabled(bool value) async {
    try {
      return await prefs.setBool(AppConstants.keyNotifications, value);
    } catch (e) {
      debugPrint('[StorageService] Error saving notifications: $e');
      return false;
    }
  }

  bool getNotificationsEnabled() {
    try {
      return prefs.getBool(AppConstants.keyNotifications) ?? true;
    } catch (e) {
      debugPrint('[StorageService] Error getting notifications: $e');
      return true;
    }
  }

  Future<bool> saveQuality(String quality) async {
    try {
      return await prefs.setString(AppConstants.keyQuality, quality);
    } catch (e) {
      debugPrint('[StorageService] Error saving quality: $e');
      return false;
    }
  }

  String getQuality() {
    try {
      return prefs.getString(AppConstants.keyQuality) ?? 'medium';
    } catch (e) {
      debugPrint('[StorageService] Error getting quality: $e');
      return 'medium';
    }
  }

  Future<bool> saveDataSaver(bool value) async {
    try {
      return await prefs.setBool(AppConstants.keyDataSaver, value);
    } catch (e) {
      debugPrint('[StorageService] Error saving data saver: $e');
      return false;
    }
  }

  bool getDataSaver() {
    try {
      return prefs.getBool(AppConstants.keyDataSaver) ?? false;
    } catch (e) {
      debugPrint('[StorageService] Error getting data saver: $e');
      return false;
    }
  }

  Future<bool> saveLanguage(String lang) async {
    try {
      return await prefs.setString(AppConstants.keyLanguage, lang);
    } catch (e) {
      debugPrint('[StorageService] Error saving language: $e');
      return false;
    }
  }

  String getLanguage() {
    try {
      return prefs.getString(AppConstants.keyLanguage) ?? 'pt';
    } catch (e) {
      debugPrint('[StorageService] Error getting language: $e');
      return 'pt';
    }
  }

  Future<bool> saveRating(String rating) async {
    try {
      return await prefs.setString(AppConstants.keyRating, rating);
    } catch (e) {
      debugPrint('[StorageService] Error saving rating: $e');
      return false;
    }
  }

  String getRating() {
    try {
      return prefs.getString(AppConstants.keyRating) ?? 'g';
    } catch (e) {
      debugPrint('[StorageService] Error getting rating: $e');
      return 'g';
    }
  }

  // ========== Generic Methods ==========

  Future<bool> saveString(String key, String value) async {
    try {
      return await prefs.setString(key, value);
    } catch (e) {
      debugPrint('[StorageService] Error saving string: $e');
      return false;
    }
  }

  String? getString(String key) {
    try {
      return prefs.getString(key);
    } catch (e) {
      debugPrint('[StorageService] Error getting string: $e');
      return null;
    }
  }

  Future<bool> saveBool(String key, bool value) async {
    try {
      return await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('[StorageService] Error saving bool: $e');
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return prefs.getBool(key);
    } catch (e) {
      debugPrint('[StorageService] Error getting bool: $e');
      return null;
    }
  }

  Future<bool> saveInt(String key, int value) async {
    try {
      return await prefs.setInt(key, value);
    } catch (e) {
      debugPrint('[StorageService] Error saving int: $e');
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return prefs.getInt(key);
    } catch (e) {
      debugPrint('[StorageService] Error getting int: $e');
      return null;
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await prefs.remove(key);
    } catch (e) {
      debugPrint('[StorageService] Error removing key: $e');
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await prefs.clear();
    } catch (e) {
      debugPrint('[StorageService] Error clearing storage: $e');
      return false;
    }
  }
}
