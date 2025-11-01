import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

/// Serviço de cache de imagens/GIFs
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Directory? _cacheDir;

  /// Inicializa o diretório de cache
  Future<void> init() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory('${tempDir.path}/gif_cache');
      
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
      
      await _cleanExpiredCache();
    } catch (e) {
      debugPrint('[CacheService] Error initializing cache: $e');
    }
  }

  /// Retorna o diretório de cache
  Directory? get cacheDir => _cacheDir;

  /// Gera nome de arquivo para cache
  String _getCacheFileName(String url) {
    final hash = url.hashCode.abs().toString();
    return '$hash.gif';
  }

  /// Verifica se um item está no cache
  Future<bool> isCached(String url) async {
    try {
      if (_cacheDir == null) await init();
      
      final fileName = _getCacheFileName(url);
      final file = File('${_cacheDir!.path}/$fileName');
      
      return await file.exists();
    } catch (e) {
      debugPrint('[CacheService] Error checking cache: $e');
      return false;
    }
  }

  /// Retorna arquivo do cache
  Future<File?> getCachedFile(String url) async {
    try {
      if (_cacheDir == null) await init();
      
      final fileName = _getCacheFileName(url);
      final file = File('${_cacheDir!.path}/$fileName');
      
      if (await file.exists()) {
        // Atualiza data de modificação
        await file.setLastModified(DateTime.now());
        return file;
      }
    } catch (e) {
      debugPrint('[CacheService] Error getting cached file: $e');
    }
    return null;
  }

  /// Salva arquivo no cache
  Future<File?> cacheFile(String url, List<int> bytes) async {
    try {
      if (_cacheDir == null) await init();
      
      final fileName = _getCacheFileName(url);
      final file = File('${_cacheDir!.path}/$fileName');
      
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('[CacheService] Error caching file: $e');
    }
    return null;
  }

  /// Remove item do cache
  Future<bool> removeCached(String url) async {
    try {
      if (_cacheDir == null) await init();
      
      final fileName = _getCacheFileName(url);
      final file = File('${_cacheDir!.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('[CacheService] Error removing cached file: $e');
    }
    return false;
  }

  /// Retorna tamanho do cache em bytes
  Future<int> getCacheSize() async {
    try {
      if (_cacheDir == null) await init();
      
      int totalSize = 0;
      
      if (_cacheDir != null && await _cacheDir!.exists()) {
        final files = _cacheDir!.listSync();
        
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('[CacheService] Error getting cache size: $e');
      return 0;
    }
  }

  /// Retorna número de itens no cache
  Future<int> getCacheCount() async {
    try {
      if (_cacheDir == null) await init();
      
      if (_cacheDir != null && await _cacheDir!.exists()) {
        final files = _cacheDir!.listSync();
        return files.whereType<File>().length;
      }
    } catch (e) {
      debugPrint('[CacheService] Error getting cache count: $e');
    }
    return 0;
  }

  /// Limpa cache expirado
  Future<void> _cleanExpiredCache() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) return;
      
      final now = DateTime.now();
      final files = _cacheDir!.listSync();
      
      for (final file in files) {
        if (file is File) {
          final lastModified = await file.lastModified();
          final difference = now.difference(lastModified);
          
          if (difference > AppConstants.cacheExpiration) {
            await file.delete();
            debugPrint('[CacheService] Deleted expired cache: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('[CacheService] Error cleaning expired cache: $e');
    }
  }

  /// Limpa todo o cache
  Future<bool> clearCache() async {
    try {
      if (_cacheDir == null) await init();
      
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create();
        debugPrint('[CacheService] Cache cleared successfully');
        return true;
      }
    } catch (e) {
      debugPrint('[CacheService] Error clearing cache: $e');
    }
    return false;
  }

  /// Limpa cache até o tamanho especificado
  Future<void> trimCache(int targetSize) async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) return;
      
      int currentSize = await getCacheSize();
      
      if (currentSize <= targetSize) return;
      
      // Ordena arquivos por data de modificação (mais antigos primeiro)
      final files = _cacheDir!.listSync()
          .whereType<File>()
          .toList();
      
      files.sort((a, b) {
        return a.lastModifiedSync().compareTo(b.lastModifiedSync());
      });
      
      // Remove arquivos até atingir o tamanho alvo
      for (final file in files) {
        if (currentSize <= targetSize) break;
        
        final fileSize = await file.length();
        await file.delete();
        currentSize -= fileSize;
        
        debugPrint('[CacheService] Trimmed cache file: ${file.path}');
      }
    } catch (e) {
      debugPrint('[CacheService] Error trimming cache: $e');
    }
  }

  /// Mantém o cache dentro do limite
  Future<void> enforceMaxCacheSize() async {
    final currentSize = await getCacheSize();
    
    if (currentSize > AppConstants.maxCacheSize) {
      await trimCache((AppConstants.maxCacheSize * 0.8).toInt());
    }
  }
}

