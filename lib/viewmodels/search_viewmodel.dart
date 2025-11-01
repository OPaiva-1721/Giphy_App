import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/gif_model.dart';
import '../models/search_history_model.dart';
import '../services/giphy_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// ViewModel para busca de GIFs
class SearchViewModel extends ChangeNotifier {
  final GiphyService _giphyService = GiphyService();
  final StorageService _storageService = StorageService();

  // State
  List<GifModel> _searchResults = [];
  List<SearchHistoryModel> _searchHistory = [];
  List<String> _suggestions = [];
  List<String> _trendingSearches = [];
  String _currentQuery = '';
  bool _loading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  String? _errorMessage;

  Timer? _debounceTimer;

  // Getters
  List<GifModel> get searchResults => _searchResults;
  List<SearchHistoryModel> get searchHistory => _searchHistory;
  List<String> get suggestions => _suggestions;
  List<String> get trendingSearches => _trendingSearches;
  String get currentQuery => _currentQuery;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Inicializa
  Future<void> initialize() async {
    await _storageService.init();
    _searchHistory = _storageService.getSearchHistory();
    await loadTrendingSearches();
    notifyListeners();
  }

  /// Busca GIFs
  Future<void> search(String query, {bool resetOffset = true}) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    if (resetOffset) {
      _currentOffset = 0;
      _searchResults = [];
      _hasMore = true;
    }

    _currentQuery = query;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _giphyService.searchGifs(
        query: query.trim(),
        limit: 50,
        offset: _currentOffset,
      );

      if (resetOffset) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      _hasMore = results.length >= 50;
      _currentOffset += results.length;

      // Adiciona ao histórico
      if (resetOffset) {
        await _addToHistory(query, results.length);
      }
    } catch (e) {
      debugPrint('[SearchViewModel] Error searching: $e');
      _errorMessage =
          'Erro ao buscar GIFs. Verifique sua conexão e tente novamente.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Busca mais resultados (paginação)
  Future<void> loadMore() async {
    if (!_hasMore || _loading || _currentQuery.isEmpty) return;
    await search(_currentQuery, resetOffset: false);
  }

  /// Busca com debounce
  void searchWithDebounce(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      search(query);
    });
  }

  /// Busca sugestões de autocomplete
  Future<void> loadSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      _suggestions = await _giphyService.getAutocompleteSuggestions(query);
      notifyListeners();
    } catch (e) {
      debugPrint('[SearchViewModel] Error loading suggestions: $e');
    }
  }

  /// Carrega buscas em alta
  Future<void> loadTrendingSearches() async {
    try {
      _trendingSearches = await _giphyService.getTrendingSearches();
      notifyListeners();
    } catch (e) {
      debugPrint('[SearchViewModel] Error loading trending searches: $e');
    }
  }

  /// Adiciona ao histórico
  Future<void> _addToHistory(String query, int resultCount) async {
    // Remove entrada antiga do mesmo query
    _searchHistory.removeWhere(
      (h) => h.query.toLowerCase() == query.toLowerCase(),
    );

    // Adiciona nova entrada
    final history = SearchHistoryModel(
      id: const Uuid().v4(),
      query: query,
      searchedAt: DateTime.now(),
      resultCount: resultCount,
    );

    _searchHistory.insert(0, history);

    // Mantém apenas os últimos 50
    if (_searchHistory.length > 50) {
      _searchHistory = _searchHistory.sublist(0, 50);
    }

    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  /// Remove item do histórico
  Future<void> removeFromHistory(String id) async {
    _searchHistory.removeWhere((h) => h.id == id);
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  /// Limpa histórico
  Future<void> clearHistory() async {
    _searchHistory = [];
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  /// Limpa busca atual
  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _currentOffset = 0;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
