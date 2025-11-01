import 'package:flutter/foundation.dart';
import '../models/collection_model.dart';
import '../models/favorite_model.dart';
import '../models/gif_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// ViewModel para coleções
class CollectionViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<CollectionModel> _collections = [];
  List<FavoriteModel> _favorites = [];
  CollectionModel? _selectedCollection;

  // Getters
  List<CollectionModel> get collections => _collections;
  List<FavoriteModel> get favorites => _favorites;
  CollectionModel? get selectedCollection => _selectedCollection;

  /// Favoritos da coleção selecionada
  List<FavoriteModel> get selectedCollectionFavorites {
    if (_selectedCollection == null) return [];

    return _favorites
        .where((f) => f.collectionIds.contains(_selectedCollection!.id))
        .toList();
  }

  /// Inicializa
  Future<void> initialize() async {
    await _storageService.init();
    _collections = _storageService.getCollections();
    _favorites = _storageService.getFavorites();
    notifyListeners();
  }

  /// Atualiza dados das coleções
  Future<void> refresh() async {
    await _storageService.init();
    final collections = _storageService.getCollections();
    final favorites = _storageService.getFavorites();
    
    _collections = collections;
    _favorites = favorites;
    
    debugPrint('[CollectionViewModel] Dados recarregados - Coleções: ${_collections.length}, Favoritos: ${_favorites.length}');
    notifyListeners();
  }

  /// Seleciona coleção
  void selectCollection(CollectionModel? collection) {
    _selectedCollection = collection;
    notifyListeners();
  }

  /// Cria coleção
  Future<CollectionModel> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    final collection = CollectionModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: color,
      icon: icon,
    );

    await _storageService.init();

    _collections.add(collection);
    final saved = await _storageService.saveCollections(_collections);
    if (!saved) {
      debugPrint('[CollectionViewModel] Erro ao salvar coleção');
    }
    notifyListeners();

    return collection;
  }

  /// Atualiza coleção
  Future<void> updateCollection(CollectionModel updatedCollection) async {
    final index = _collections.indexWhere((c) => c.id == updatedCollection.id);

    if (index != -1) {
      _collections[index] = updatedCollection.copyWith(
        updatedAt: DateTime.now(),
      );
      await _storageService.init();
      final saved = await _storageService.saveCollections(_collections);
      if (!saved) {
        debugPrint('[CollectionViewModel] Erro ao atualizar coleção');
      }

      if (_selectedCollection?.id == updatedCollection.id) {
        _selectedCollection = _collections[index];
      }

      notifyListeners();
    }
  }

  /// Deleta coleção
  Future<void> deleteCollection(String collectionId) async {
    await _storageService.init();

    _collections.removeWhere((c) => c.id == collectionId);
    final saved = await _storageService.saveCollections(_collections);
    if (!saved) {
      debugPrint('[CollectionViewModel] Erro ao deletar coleção');
    }

    // Remove a coleção dos favoritos
    for (var favorite in _favorites) {
      if (favorite.collectionIds.contains(collectionId)) {
        final updatedFavorite = favorite.copyWith(
          collectionIds: favorite.collectionIds
              .where((id) => id != collectionId)
              .toList(),
        );
        final index = _favorites.indexOf(favorite);
        _favorites[index] = updatedFavorite;
      }
    }
    await _storageService.saveFavorites(_favorites);

    if (_selectedCollection?.id == collectionId) {
      _selectedCollection = null;
    }

    notifyListeners();
  }

  /// Adiciona GIF à coleção
  Future<void> addGifToCollection(String collectionId, GifModel gif) async {
    // Encontra ou cria favorito
    var favorite = _favorites.firstWhere(
      (f) => f.gif.id == gif.id,
      orElse: () => FavoriteModel(
        id: const Uuid().v4(),
        gif: gif,
        addedAt: DateTime.now(),
      ),
    );

    // Adiciona coleção ao favorito se ainda não estiver
    if (!favorite.collectionIds.contains(collectionId)) {
      final updatedFavorite = favorite.copyWith(
        collectionIds: [...favorite.collectionIds, collectionId],
      );

      final index = _favorites.indexOf(favorite);
      if (index != -1) {
        _favorites[index] = updatedFavorite;
      } else {
        _favorites.add(updatedFavorite);
      }

      await _storageService.init();
      final saved = await _storageService.saveFavorites(_favorites);
      if (!saved) {
        debugPrint('[CollectionViewModel] Erro ao adicionar GIF à coleção');
        // Reverte mudanças se não salvou
        if (index != -1) {
          _favorites[index] = favorite;
        } else {
          _favorites.removeLast();
        }
        return;
      }

      debugPrint('[CollectionViewModel] GIF adicionado à coleção. Total favoritos: ${_favorites.length}');

      // Atualiza contador da coleção
      await _updateCollectionGifCount(collectionId);

      notifyListeners();
    }
  }

  /// Remove GIF da coleção
  Future<void> removeGifFromCollection(
    String collectionId,
    String gifId,
  ) async {
    final favorite = _favorites.firstWhere(
      (f) => f.gif.id == gifId,
      orElse: () => throw Exception('Favorito não encontrado'),
    );

    final updatedFavorite = favorite.copyWith(
      collectionIds: favorite.collectionIds
          .where((id) => id != collectionId)
          .toList(),
    );

    final index = _favorites.indexOf(favorite);
    _favorites[index] = updatedFavorite;

    // Remove o favorito completamente se não estiver em nenhuma coleção
    if (updatedFavorite.collectionIds.isEmpty) {
      _favorites.removeAt(index);
    }

    await _storageService.init();
    final saved = await _storageService.saveFavorites(_favorites);
    if (!saved) {
      debugPrint('[CollectionViewModel] Erro ao remover GIF da coleção');
    }

    // Atualiza contador da coleção
    await _updateCollectionGifCount(collectionId);

    notifyListeners();
  }

  /// Atualiza contador de GIFs da coleção
  Future<void> _updateCollectionGifCount(String collectionId) async {
    final collection = _collections.firstWhere((c) => c.id == collectionId);
    final gifCount = _favorites
        .where((f) => f.collectionIds.contains(collectionId))
        .length;

    final updatedCollection = collection.copyWith(
      gifCount: gifCount,
      updatedAt: DateTime.now(),
    );

    await updateCollection(updatedCollection);
  }

  /// Verifica se um GIF está em uma coleção
  bool isGifInCollection(String collectionId, String gifId) {
    return _favorites.any(
      (f) => f.gif.id == gifId && f.collectionIds.contains(collectionId),
    );
  }

  /// Retorna coleções de um GIF
  List<CollectionModel> getCollectionsForGif(String gifId) {
    final favorite = _favorites.firstWhere(
      (f) => f.gif.id == gifId,
      orElse: () => FavoriteModel(
        id: '',
        gif: GifModel(id: gifId),
        addedAt: DateTime.now(),
      ),
    );

    return _collections
        .where((c) => favorite.collectionIds.contains(c.id))
        .toList();
  }
}
