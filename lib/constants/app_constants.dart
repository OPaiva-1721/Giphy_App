/// Constantes globais do aplicativo
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/remote_config_service.dart';

class AppConstants {
  // API
  /// Obtém a API Key do Giphy
  /// Prioridade: 1) Remote Config 2) .env 3) Hardcoded
  static String get giphyApiKey {
    final remoteConfigService = RemoteConfigService();
    if (remoteConfigService.isAvailable) {
      return remoteConfigService.getGiphyApiKey();
    }
    
    // Fallback para métodos tradicionais
    return dotenv.env['GIPHY_API_KEY'] ??
        const String.fromEnvironment(
          'GIPHY_API_KEY',
          defaultValue: 'YOUR_API_KEY_HERE',
        );
  }
  static const String giphyBaseUrl = 'api.giphy.com';

  // Timings
  static const Duration autoShuffleInterval = Duration(seconds: 7);
  static const Duration cacheExpiration = Duration(days: 7);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Limits
  static const int maxFavorites = 1000;
  static const int maxCollections = 50;
  static const int maxCommentsPerGif = 100;
  static const int searchResultsLimit = 50;
  static const int trendingLimit = 25;

  // Cache
  static const int maxCachedImages = 100;
  static const int maxCacheSize = 500 * 1024 * 1024; // 500MB

  // Gamification
  static const int pointsPerView = 1;
  static const int pointsPerFavorite = 5;
  static const int pointsPerShare = 10;
  static const int pointsPerComment = 15;
  static const int pointsPerCollection = 20;
  static const int pointsPerDailyLogin = 25;

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserStats = 'user_stats';
  static const String keyFavorites = 'favorites';
  static const String keyCollections = 'collections';
  static const String keyHistory = 'history';
  static const String keySearchHistory = 'search_history';
  static const String keyAutoShuffle = 'auto_shuffle';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyQuality = 'gif_quality';
  static const String keyDataSaver = 'data_saver';
  static const String keyLanguage = 'language';
  static const String keyRating = 'content_rating';

  // URLs
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
  static const String supportEmail = 'support@yourapp.com';

  // Social
  static const String twitterHandle = '@yourapp';
  static const String instagramHandle = '@yourapp';

  // Features Flags
  static const bool enableFirebase = true;
  static const bool enableAnalytics = true;
  static const bool enableAds = false;
  static const bool enablePremium = true;
  static const bool enableSocialFeatures = true;
  static const bool enableEditor = true;
}
