import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/gif_model.dart';

/// Serviço de compartilhamento
class ShareService {
  /// Compartilha um GIF
  Future<bool> shareGif(GifModel gif, {String? customText}) async {
    try {
      if (gif.url == null) {
        debugPrint('[ShareService] Cannot share: GIF URL is null');
        return false;
      }

      final text = customText ?? _buildShareText(gif);
      
      final result = await Share.share(
        text,
        subject: gif.title ?? 'Confira este GIF!',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('[ShareService] Error sharing GIF: $e');
      return false;
    }
  }

  /// Compartilha URL do GIF
  Future<bool> shareGifUrl(String url, {String? title}) async {
    try {
      final text = title != null ? '$title\n$url' : url;
      
      final result = await Share.share(text);
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('[ShareService] Error sharing URL: $e');
      return false;
    }
  }

  /// Compartilha texto
  Future<bool> shareText(String text) async {
    try {
      final result = await Share.share(text);
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('[ShareService] Error sharing text: $e');
      return false;
    }
  }

  /// Constrói texto de compartilhamento
  String _buildShareText(GifModel gif) {
    final buffer = StringBuffer();
    
    if (gif.title != null && gif.title!.isNotEmpty) {
      buffer.writeln(gif.title);
    }
    
    if (gif.url != null) {
      buffer.writeln(gif.url);
    }
    
    buffer.writeln('\nCompartilhado via Giphy Ultimate 🎬');
    
    return buffer.toString();
  }

  /// Compartilha múltiplos GIFs
  Future<bool> shareMultipleGifs(List<GifModel> gifs) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Confira estes GIFs incríveis! 🎬\n');
      
      for (int i = 0; i < gifs.length; i++) {
        final gif = gifs[i];
        if (gif.title != null) {
          buffer.writeln('${i + 1}. ${gif.title}');
        }
        if (gif.url != null) {
          buffer.writeln('   ${gif.url}');
        }
        buffer.writeln();
      }
      
      buffer.writeln('Compartilhado via Giphy Ultimate');
      
      final result = await Share.share(buffer.toString());
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('[ShareService] Error sharing multiple GIFs: $e');
      return false;
    }
  }

  /// Compartilha coleção
  Future<bool> shareCollection(
    String collectionName,
    List<GifModel> gifs,
  ) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('📁 Coleção: $collectionName\n');
      buffer.writeln('${gifs.length} GIFs incríveis!\n');
      
      for (int i = 0; i < gifs.length && i < 10; i++) {
        final gif = gifs[i];
        if (gif.url != null) {
          buffer.writeln('${i + 1}. ${gif.url}');
        }
      }
      
      if (gifs.length > 10) {
        buffer.writeln('\n... e mais ${gifs.length - 10} GIFs!');
      }
      
      buffer.writeln('\nCompartilhado via Giphy Ultimate 🎬');
      
      final result = await Share.share(buffer.toString());
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('[ShareService] Error sharing collection: $e');
      return false;
    }
  }
}

