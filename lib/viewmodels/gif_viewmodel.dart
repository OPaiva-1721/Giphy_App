import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/gif_model.dart';
import '../models/user_stats_model.dart';
import '../models/favorite_model.dart';
import '../models/collection_model.dart';
import '../services/giphy_service.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';
import '../services/analytics_service.dart';
import '../services/download_service.dart';
import '../services/share_service.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

/// ViewModel principal para GIFs
class GifViewModel extends ChangeNotifier {
  final GiphyService _giphyService = GiphyService();
  final StorageService _storageService = StorageService();
  final GamificationService _gamificationService = GamificationService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final DownloadService _downloadService = DownloadService();
  final ShareService _shareService = ShareService();

  // State
  GifModel? _currentGif;
  List<GifModel> _gifs = [];
  UserStatsModel _userStats = UserStatsModel.empty();
  List<FavoriteModel> _favorites = [];
  List<CollectionModel> _collections = [];
  String? _randomId;

  // UI State
  bool _loading = false;
  bool _autoShuffle = true;
  bool _playing = true;
  String _rating = 'g';
  String _lang = 'pt';
  int _currentIndex = 0;
  String? _errorMessage;

  // Timer for auto-shuffle
  Timer? _timer;

  // Getters
  GifModel? get currentGif => _currentGif;
  List<GifModel> get gifs => _gifs;
  UserStatsModel get userStats => _userStats;
  List<FavoriteModel> get favorites => _favorites;
  List<CollectionModel> get collections => _collections;
  bool get loading => _loading;
  bool get autoShuffle => _autoShuffle;
  bool get playing => _playing;
  String get rating => _rating;
  String get lang => _lang;
  int get currentIndex => _currentIndex;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool get isCurrentGifFavorite {
    if (_currentGif?.id == null) return false;
    return _favorites.any((f) => f.gif.id == _currentGif!.id);
  }

  /// Inicializa o ViewModel
  Future<void> initialize() async {
    await _storageService.init();
    await _loadData();

    if (_autoShuffle) {
      _startAutoShuffle();
    }
  }

  /// Carrega dados salvos
  Future<void> _loadData() async {
    _userStats = _storageService.getUserStats() ?? UserStatsModel.empty();
    _favorites = _storageService.getFavorites();
    _collections = _storageService.getCollections();
    _autoShuffle = _storageService.getAutoShuffle();
    _rating = _storageService.getRating();
    _lang = _storageService.getLanguage();

    notifyListeners();
  }

  /// Atualiza favoritos e coleções do storage
  Future<void> refreshFavorites() async {
    await _storageService.init();
    final favorites = _storageService.getFavorites();
    final collections = _storageService.getCollections();
    
    _favorites = favorites;
    _collections = collections;
    
    debugPrint('[GifViewModel] Favoritos recarregados: ${_favorites.length}');
    notifyListeners();
  }

  /// Define loading
  void _setLoading(bool value) {
    _loading = value;
    if (value) {
      _errorMessage = null; // Limpa erro ao iniciar novo carregamento
    }
    notifyListeners();
  }

  /// Define erro
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========== GIF Fetching ==========

  /// Busca GIF aleatório
  Future<void> fetchRandomGif() async {
    if (_loading) return;

    _setLoading(true);
    try {
      final gif = await _giphyService.getRandomGif(
        rating: _rating,
        randomId: _randomId,
      );

      if (gif != null) {
        _currentGif = gif;
        _updateGifsViewed();
        _addPoints('view_gif');
        _pingAnalytics();

        if (gif.id != null) {
          await _analyticsService.logGifView(gif.id!);
        }
      } else {
        _setError('Não foi possível carregar o GIF. Tente novamente.');
      }
    } catch (e) {
      debugPrint('[GifViewModel] Error fetching random GIF: $e');
      _setError('Erro ao buscar GIF. Verifique sua conexão e tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca GIF em alta
  Future<void> fetchTrendingGif() async {
    if (_loading) return;

    _setLoading(true);
    try {
      final gif = await _giphyService.getTrendingGif(rating: _rating);

      if (gif != null) {
        _currentGif = gif;
        _updateGifsViewed();
        _addPoints('view_gif');
        _pingAnalytics();

        if (gif.id != null) {
          await _analyticsService.logGifView(gif.id!);
        }
      } else {
        _setError('Não foi possível carregar o GIF. Tente novamente.');
      }
    } catch (e) {
      debugPrint('[GifViewModel] Error fetching trending GIF: $e');
      _setError('Erro ao buscar GIF. Verifique sua conexão e tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca múltiplos GIFs trending
  Future<void> fetchTrendingGifs({int limit = 25}) async {
    if (_loading) return;

    _setLoading(true);
    // Limpa GIFs anteriores para mostrar loading imediatamente
    _gifs = [];
    notifyListeners();

    try {
      _gifs = await _giphyService.getTrendingGifs(
        rating: _rating,
        limit: limit,
      );

      if (_gifs.isNotEmpty) {
        _currentGif = _gifs[0];
        _currentIndex = 0;
      } else {
        _setError('Nenhum GIF encontrado. Tente novamente mais tarde.');
      }
    } catch (e) {
      debugPrint('[GifViewModel] Error fetching trending GIFs: $e');
      _setError(
        'Erro ao carregar GIFs. Verifique sua conexão e tente novamente.',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Busca GIF por query
  Future<void> searchGif(String query) async {
    if (_loading || query.trim().isEmpty) return;

    _setLoading(true);
    try {
      final gif = await _giphyService.searchGif(
        query: query.trim(),
        rating: _rating,
        lang: _lang,
      );

      if (gif != null) {
        _currentGif = gif;
        _updateGifsViewed();
        _addPoints('view_gif');
        _pingAnalytics();

        await _analyticsService.logSearch(query, 1);
      } else {
        _setError('Nenhum GIF encontrado para "$query". Tente outra busca.');
      }
    } catch (e) {
      debugPrint('[GifViewModel] Error searching GIF: $e');
      _setError('Erro ao buscar GIF. Verifique sua conexão e tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca múltiplos GIFs por query
  Future<void> searchGifs(String query, {int limit = 50}) async {
    if (_loading || query.trim().isEmpty) return;

    _setLoading(true);
    // Limpa GIFs anteriores para mostrar loading imediatamente
    _gifs = [];
    notifyListeners();

    try {
      _gifs = await _giphyService.searchGifs(
        query: query.trim(),
        rating: _rating,
        lang: _lang,
        limit: limit,
      );

      if (_gifs.isNotEmpty) {
        _currentGif = _gifs[0];
        _currentIndex = 0;
      } else {
        _setError('Nenhum GIF encontrado para "$query".');
      }

      await _analyticsService.logSearch(query, _gifs.length);
    } catch (e) {
      debugPrint('[GifViewModel] Error searching GIFs: $e');
      _setError(
        'Erro ao buscar GIFs. Verifique sua conexão e tente novamente.',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Busca por categoria
  Future<void> fetchByCategory(String category) async {
    await searchGifs(category);
  }

  /// Navega para próximo GIF
  void nextGif() {
    if (_gifs.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _gifs.length;
    _currentGif = _gifs[_currentIndex];
    _updateGifsViewed();
    _addPoints('view_gif');
    notifyListeners();
  }

  /// Navega para GIF anterior
  void previousGif() {
    if (_gifs.isEmpty) return;

    _currentIndex = (_currentIndex - 1 + _gifs.length) % _gifs.length;
    _currentGif = _gifs[_currentIndex];
    notifyListeners();
  }

  /// Define GIF atual por índice
  void setCurrentGif(int index) {
    if (index >= 0 && index < _gifs.length) {
      _currentIndex = index;
      _currentGif = _gifs[index];
      _updateGifsViewed();
      notifyListeners();
    }
  }

  void _pingAnalytics() {
    if (_currentGif?.analyticsOnLoad != null) {
      _giphyService.pingAnalytics(
        _currentGif!.analyticsOnLoad,
        randomId: _randomId,
      );
    }
  }

  // ========== Favorites ==========

  /// Adiciona/remove favorito
  Future<void> toggleFavorite() async {
    if (_currentGif?.id == null) return;

    final isFavorite = isCurrentGifFavorite;

    if (isFavorite) {
      await removeFavorite(_currentGif!);
    } else {
      await addFavorite(_currentGif!);
    }
  }

  /// Adiciona favorito
  Future<void> addFavorite(GifModel gif) async {
    if (gif.id == null) return;

    // Verifica se já está nos favoritos
    if (_favorites.any((f) => f.gif.id == gif.id)) {
      debugPrint('[GifViewModel] GIF já está nos favoritos');
      return;
    }

    await _storageService.init();

    final favorite = FavoriteModel(
      id: const Uuid().v4(),
      gif: gif,
      addedAt: DateTime.now(),
    );

    _favorites.add(favorite);
    final saved = await _storageService.saveFavorites(_favorites);
    if (!saved) {
      debugPrint('[GifViewModel] Erro ao salvar favorito');
      _favorites.removeLast(); // Reverte se não salvou
      return;
    }

    debugPrint('[GifViewModel] Favorito salvo com sucesso. Total: ${_favorites.length}');

    _userStats = _userStats.copyWith(
      gifsFavorited: _userStats.gifsFavorited + 1,
    );
    await _storageService.saveUserStats(_userStats);

    _addPoints('favorite');
    await _analyticsService.logFavorite(gif.id!);

    notifyListeners();
  }

  /// Remove favorito
  Future<void> removeFavorite(GifModel gif) async {
    await _storageService.init();

    _favorites.removeWhere((f) => f.gif.id == gif.id);
    final saved = await _storageService.saveFavorites(_favorites);
    if (!saved) {
      debugPrint('[GifViewModel] Erro ao remover favorito');
    }

    if (_userStats.gifsFavorited > 0) {
      _userStats = _userStats.copyWith(
        gifsFavorited: _userStats.gifsFavorited - 1,
      );
      await _storageService.saveUserStats(_userStats);
    }

    if (gif.id != null) {
      await _analyticsService.logUnfavorite(gif.id!);
    }

    notifyListeners();
  }

  // ========== Collections ==========

  /// Cria nova coleção
  Future<void> createCollection(String name, {String? description}) async {
    await _storageService.init();

    final collection = CollectionModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _collections.add(collection);
    final saved = await _storageService.saveCollections(_collections);
    if (!saved) {
      debugPrint('[GifViewModel] Erro ao salvar coleção');
    }

    _userStats = _userStats.copyWith(
      collectionsCreated: _userStats.collectionsCreated + 1,
    );
    await _storageService.saveUserStats(_userStats);

    _addPoints('create_collection');
    await _analyticsService.logCollectionCreated(collection.id);

    notifyListeners();
  }

  /// Deleta coleção
  Future<void> deleteCollection(String collectionId) async {
    _collections.removeWhere((c) => c.id == collectionId);
    await _storageService.saveCollections(_collections);
    notifyListeners();
  }

  // ========== Sharing ==========

  /// Compartilha GIF atual
  Future<bool> shareCurrentGif() async {
    if (_currentGif == null) {
      _setError('Nenhum GIF selecionado para compartilhar.');
      return false;
    }

    try {
      final success = await _shareService.shareGif(_currentGif!);

      if (success) {
        _userStats = _userStats.copyWith(gifsShared: _userStats.gifsShared + 1);
        await _storageService.saveUserStats(_userStats);
        _addPoints('share');

        if (_currentGif!.id != null) {
          await _analyticsService.logShare(_currentGif!.id!, 'native');
        }
      } else {
        _setError('Erro ao compartilhar GIF.');
      }

      return success;
    } catch (e) {
      debugPrint('[GifViewModel] Error sharing GIF: $e');
      _setError('Erro ao compartilhar GIF. Tente novamente.');
      return false;
    }
  }

  // ========== Download ==========

  /// Baixa GIF atual
  Future<void> downloadCurrentGif() async {
    if (_currentGif == null) {
      _setError('Nenhum GIF selecionado para baixar.');
      return;
    }

    try {
      await _downloadService.downloadGif(_currentGif!);

      if (_currentGif!.id != null) {
        await _analyticsService.logDownload(_currentGif!.id!);
      }
    } catch (e) {
      debugPrint('[GifViewModel] Error downloading GIF: $e');
      _setError(
        'Erro ao baixar GIF. Verifique as permissões e tente novamente.',
      );
    }
  }

  // ========== Auto Shuffle ==========

  /// Alterna auto-shuffle
  Future<void> toggleAutoShuffle() async {
    _autoShuffle = !_autoShuffle;
    await _storageService.saveAutoShuffle(_autoShuffle);

    if (_autoShuffle) {
      _startAutoShuffle();
    } else {
      _stopAutoShuffle();
    }

    notifyListeners();
  }

  void _startAutoShuffle() {
    _stopAutoShuffle();
    _timer = Timer.periodic(AppConstants.autoShuffleInterval, (_) {
      if (!_loading) {
        fetchRandomGif();
      }
    });
  }

  void _stopAutoShuffle() {
    _timer?.cancel();
    _timer = null;
  }

  /// Alterna play/pause
  void togglePlaying() {
    _playing = !_playing;
    notifyListeners();
  }

  // ========== Gamification ==========

  void _updateGifsViewed() {
    _userStats = _userStats.copyWith(gifsViewed: _userStats.gifsViewed + 1);
    _storageService.saveUserStats(_userStats);
  }

  void _addPoints(String action) {
    final points = _gamificationService.getPointsForAction(action);
    final newTotal = _userStats.totalPoints + points;

    _userStats = _userStats.copyWith(totalPoints: newTotal);
    _storageService.saveUserStats(_userStats);
  }

  // ========== Settings ==========

  /// Define classificação de conteúdo
  Future<void> setRating(String rating) async {
    _rating = rating;
    await _storageService.saveRating(rating);
    notifyListeners();
  }

  /// Define idioma
  Future<void> setLanguage(String lang) async {
    _lang = lang;
    await _storageService.saveLanguage(lang);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoShuffle();
    super.dispose();
  }
}
