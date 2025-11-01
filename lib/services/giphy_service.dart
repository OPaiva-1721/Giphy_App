import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/gif_model.dart';
import '../constants/app_constants.dart';

/// Serviço para interação com a API do Giphy
class GiphyService {
  final String _apiKey = AppConstants.giphyApiKey;
  final String _baseUrl = AppConstants.giphyBaseUrl;

  /// Busca GIF aleatório
  Future<GifModel?> getRandomGif({
    String? tag,
    String rating = 'g',
    String? randomId,
  }) async {
    try {
      final params = <String, String>{
        'api_key': _apiKey,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
        'rating': rating,
        if (randomId != null) 'random_id': randomId,
      };

      final uri = Uri.https(_baseUrl, '/v1/gifs/random', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;

        if (data != null && data.isNotEmpty) {
          return GifModel.fromJson(data);
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('[GiphyService] API Key inválida ou ausente');
        throw Exception(
          'Chave de API inválida. Verifique sua GIPHY_API_KEY no arquivo .env',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[GiphyService] Erro no servidor: ${response.statusCode}');
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        debugPrint('[GiphyService] Random GIF error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[GiphyService] Error getting random GIF: $e');
      final errorString = e.toString();
      if (errorString.contains('HandshakeException') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorString.contains('TlsException')) {
        throw Exception(
          'Erro de certificado SSL. Isso pode ocorrer em emuladores. Tente em um dispositivo real ou verifique sua configuração de rede.',
        );
      }
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
    return null;
  }

  /// Busca GIFs em alta (trending)
  Future<List<GifModel>> getTrendingGifs({
    String rating = 'g',
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final params = {
        'api_key': _apiKey,
        'rating': rating,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.https(_baseUrl, '/v1/gifs/trending', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list =
            (json['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return list.map((item) => GifModel.fromJson(item)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('[GiphyService] API Key inválida ou ausente');
        throw Exception(
          'Chave de API inválida. Verifique sua GIPHY_API_KEY no arquivo .env',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[GiphyService] Erro no servidor: ${response.statusCode}');
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        debugPrint('[GiphyService] Trending error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[GiphyService] Error getting trending: $e');
      final errorString = e.toString();
      if (errorString.contains('HandshakeException') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorString.contains('TlsException')) {
        throw Exception(
          'Erro de certificado SSL. Isso pode ocorrer em emuladores. Tente em um dispositivo real ou verifique sua configuração de rede.',
        );
      }
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
    return [];
  }

  /// Busca um GIF aleatório dos trending
  Future<GifModel?> getTrendingGif({String rating = 'g'}) async {
    final gifs = await getTrendingGifs(rating: rating, limit: 25);
    if (gifs.isNotEmpty) {
      return gifs[DateTime.now().millisecondsSinceEpoch % gifs.length];
    }
    return null;
  }

  /// Busca GIFs por query
  Future<List<GifModel>> searchGifs({
    required String query,
    String rating = 'g',
    String lang = 'pt',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = {
        'api_key': _apiKey,
        'q': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
        'rating': rating,
        'lang': lang,
      };

      final uri = Uri.https(_baseUrl, '/v1/gifs/search', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list =
            (json['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return list.map((item) => GifModel.fromJson(item)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('[GiphyService] API Key inválida ou ausente');
        throw Exception(
          'Chave de API inválida. Verifique sua GIPHY_API_KEY no arquivo .env',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[GiphyService] Erro no servidor: ${response.statusCode}');
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        debugPrint('[GiphyService] Search error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[GiphyService] Error searching GIFs: $e');
      final errorString = e.toString();
      if (errorString.contains('HandshakeException') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorString.contains('TlsException')) {
        throw Exception(
          'Erro de certificado SSL. Isso pode ocorrer em emuladores. Tente em um dispositivo real ou verifique sua configuração de rede.',
        );
      }
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
    return [];
  }

  /// Busca um GIF aleatório dos resultados de busca
  Future<GifModel?> searchGif({
    required String query,
    String rating = 'g',
    String lang = 'pt',
  }) async {
    final gifs = await searchGifs(
      query: query,
      rating: rating,
      lang: lang,
      limit: 25,
    );

    if (gifs.isNotEmpty) {
      return gifs[DateTime.now().millisecondsSinceEpoch % gifs.length];
    }
    return null;
  }

  /// Busca GIFs por categoria
  Future<List<GifModel>> getGifsByCategory(
    String category, {
    String rating = 'g',
    int limit = 50,
  }) async {
    return searchGifs(query: category, rating: rating, limit: limit);
  }

  /// Busca GIFs por IDs
  Future<List<GifModel>> getGifsByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];

      final params = {'api_key': _apiKey, 'ids': ids.join(',')};

      final uri = Uri.https(_baseUrl, '/v1/gifs', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list =
            (json['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return list.map((item) => GifModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('[GiphyService] Error getting GIFs by IDs: $e');
    }
    return [];
  }

  /// Busca GIF por ID
  Future<GifModel?> getGifById(String id) async {
    try {
      final params = {'api_key': _apiKey};
      final uri = Uri.https(_baseUrl, '/v1/gifs/$id', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;

        if (data != null) {
          return GifModel.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('[GiphyService] Error getting GIF by ID: $e');
    }
    return null;
  }

  /// Busca sugestões de autocomplete
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final params = {'api_key': _apiKey, 'q': query, 'limit': '10'};

      final uri = Uri.https(_baseUrl, '/v1/gifs/search/tags', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list =
            (json['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return list.map((item) => item['name'] as String).toList();
      }
    } catch (e) {
      debugPrint('[GiphyService] Error getting autocomplete: $e');
    }
    return [];
  }

  /// Busca categorias trending
  Future<List<String>> getTrendingSearches() async {
    try {
      final params = {'api_key': _apiKey};
      final uri = Uri.https(_baseUrl, '/v1/trending/searches', params);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (json['data'] as List?)?.cast<String>() ?? [];
        return list;
      }
    } catch (e) {
      debugPrint('[GiphyService] Error getting trending searches: $e');
    }
    return [];
  }

  /// Envia ping de analytics
  Future<void> pingAnalytics(String? url, {String? randomId}) async {
    if (url == null || url.isEmpty) return;

    try {
      var uri = Uri.parse(url);
      if (randomId != null) {
        final params = Map<String, String>.from(uri.queryParameters);
        params['random_id'] = randomId;
        uri = uri.replace(queryParameters: params);
      }
      await http.get(uri);
    } catch (e) {
      debugPrint('[GiphyService] Analytics ping error: $e');
    }
  }
}
