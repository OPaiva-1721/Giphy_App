import 'package:flutter/foundation.dart';

/// Serviço de analytics
/// Nota: Implementação básica. Para produção, integrar com Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _enabled = true;

  /// Ativa/desativa analytics
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Registra evento
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_enabled) return;
    
    try {
      debugPrint('[Analytics] Event: $name ${parameters != null ? '- $parameters' : ''}');
      // TODO: Integrar com Firebase Analytics
      // await FirebaseAnalytics.instance.logEvent(
      //   name: name,
      //   parameters: parameters,
      // );
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }

  /// Registra visualização de tela
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
  }

  /// Registra visualização de GIF
  Future<void> logGifView(String gifId) async {
    await logEvent('gif_view', {'gif_id': gifId});
  }

  /// Registra busca
  Future<void> logSearch(String query, int results) async {
    await logEvent('search', {
      'search_query': query,
      'results_count': results,
    });
  }

  /// Registra favorito
  Future<void> logFavorite(String gifId) async {
    await logEvent('favorite_added', {'gif_id': gifId});
  }

  /// Registra remoção de favorito
  Future<void> logUnfavorite(String gifId) async {
    await logEvent('favorite_removed', {'gif_id': gifId});
  }

  /// Registra compartilhamento
  Future<void> logShare(String gifId, String method) async {
    await logEvent('share', {
      'gif_id': gifId,
      'share_method': method,
    });
  }

  /// Registra download
  Future<void> logDownload(String gifId) async {
    await logEvent('download', {'gif_id': gifId});
  }

  /// Registra criação de coleção
  Future<void> logCollectionCreated(String collectionId) async {
    await logEvent('collection_created', {'collection_id': collectionId});
  }

  /// Registra conquista desbloqueada
  Future<void> logAchievementUnlocked(String achievementId) async {
    await logEvent('achievement_unlocked', {'achievement_id': achievementId});
  }

  /// Registra level up
  Future<void> logLevelUp(int newLevel) async {
    await logEvent('level_up', {'new_level': newLevel});
  }

  /// Registra erro
  Future<void> logError(String error, {String? stackTrace}) async {
    await logEvent('error', {
      'error_message': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  /// Define propriedade do usuário
  Future<void> setUserProperty(String name, String value) async {
    if (!_enabled) return;
    
    try {
      debugPrint('[Analytics] User Property: $name = $value');
      // TODO: Integrar com Firebase Analytics
      // await FirebaseAnalytics.instance.setUserProperty(
      //   name: name,
      //   value: value,
      // );
    } catch (e) {
      debugPrint('[Analytics] Error setting user property: $e');
    }
  }

  /// Define ID do usuário
  Future<void> setUserId(String? userId) async {
    if (!_enabled) return;
    
    try {
      debugPrint('[Analytics] User ID: $userId');
      // TODO: Integrar com Firebase Analytics
      // await FirebaseAnalytics.instance.setUserId(id: userId);
    } catch (e) {
      debugPrint('[Analytics] Error setting user ID: $e');
    }
  }
}

