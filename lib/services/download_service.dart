import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/gif_model.dart';

/// Status do download
enum DownloadStatus {
  idle,
  downloading,
  completed,
  failed,
}

/// Informações do download
class DownloadInfo {
  final String id;
  final GifModel gif;
  final DownloadStatus status;
  final double progress;
  final String? filePath;
  final String? error;

  const DownloadInfo({
    required this.id,
    required this.gif,
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.filePath,
    this.error,
  });

  DownloadInfo copyWith({
    String? id,
    GifModel? gif,
    DownloadStatus? status,
    double? progress,
    String? filePath,
    String? error,
  }) {
    return DownloadInfo(
      id: id ?? this.id,
      gif: gif ?? this.gif,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
    );
  }
}

/// Serviço de download de GIFs
class DownloadService {
  final Map<String, DownloadInfo> _downloads = {};
  final List<Function(DownloadInfo)> _listeners = [];

  /// Adiciona listener para mudanças nos downloads
  void addListener(Function(DownloadInfo) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function(DownloadInfo) listener) {
    _listeners.remove(listener);
  }

  /// Notifica listeners
  void _notifyListeners(DownloadInfo info) {
    for (final listener in _listeners) {
      listener(info);
    }
  }

  /// Retorna diretório de downloads
  Future<Directory> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    
    return downloadDir;
  }

  /// Faz download de um GIF
  Future<DownloadInfo> downloadGif(GifModel gif) async {
    if (gif.url == null || gif.id == null) {
      final info = DownloadInfo(
        id: gif.id ?? 'unknown',
        gif: gif,
        status: DownloadStatus.failed,
        error: 'URL ou ID do GIF inválido',
      );
      return info;
    }

    final downloadId = gif.id!;
    
    // Verifica se já está baixando
    if (_downloads.containsKey(downloadId)) {
      return _downloads[downloadId]!;
    }

    // Cria info inicial
    var info = DownloadInfo(
      id: downloadId,
      gif: gif,
      status: DownloadStatus.downloading,
    );
    _downloads[downloadId] = info;
    _notifyListeners(info);

    try {
      // Faz o download
      final response = await http.get(Uri.parse(gif.url!));
      
      if (response.statusCode == 200) {
        // Salva o arquivo
        final downloadDir = await _getDownloadDirectory();
        final fileName = '${gif.id}_${DateTime.now().millisecondsSinceEpoch}.gif';
        final file = File('${downloadDir.path}/$fileName');
        
        await file.writeAsBytes(response.bodyBytes);
        
        // Atualiza status
        info = info.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          filePath: file.path,
        );
        
        debugPrint('[DownloadService] GIF downloaded: ${file.path}');
      } else {
        info = info.copyWith(
          status: DownloadStatus.failed,
          error: 'Erro HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[DownloadService] Error downloading GIF: $e');
      info = info.copyWith(
        status: DownloadStatus.failed,
        error: e.toString(),
      );
    }

    _downloads[downloadId] = info;
    _notifyListeners(info);
    return info;
  }

  /// Retorna informações de um download
  DownloadInfo? getDownloadInfo(String id) {
    return _downloads[id];
  }

  /// Retorna todos os downloads
  List<DownloadInfo> getAllDownloads() {
    return _downloads.values.toList();
  }

  /// Remove um download da lista
  void removeDownload(String id) {
    _downloads.remove(id);
  }

  /// Limpa downloads completados
  void clearCompleted() {
    _downloads.removeWhere((key, value) => value.status == DownloadStatus.completed);
  }

  /// Retorna lista de arquivos baixados
  Future<List<File>> getDownloadedFiles() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      
      if (await downloadDir.exists()) {
        return downloadDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.gif'))
            .toList();
      }
    } catch (e) {
      debugPrint('[DownloadService] Error getting downloaded files: $e');
    }
    return [];
  }

  /// Deleta um arquivo baixado
  Future<bool> deleteDownloadedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('[DownloadService] Error deleting file: $e');
    }
    return false;
  }

  /// Limpa todos os arquivos baixados
  Future<bool> clearAllDownloads() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      
      if (await downloadDir.exists()) {
        await downloadDir.delete(recursive: true);
        await downloadDir.create();
        _downloads.clear();
        return true;
      }
    } catch (e) {
      debugPrint('[DownloadService] Error clearing downloads: $e');
    }
    return false;
  }

  /// Retorna tamanho total dos downloads
  Future<int> getTotalDownloadSize() async {
    try {
      final files = await getDownloadedFiles();
      int totalSize = 0;
      
      for (final file in files) {
        totalSize += await file.length();
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('[DownloadService] Error getting download size: $e');
      return 0;
    }
  }
}

