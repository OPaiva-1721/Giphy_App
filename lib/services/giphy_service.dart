import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/gif_model.dart';
import '../constants/app_constants.dart';

/// Serviço para interação com a API do Giphy
class GiphyService {
  final String _baseUrl = AppConstants.giphyBaseUrl;
  final Connectivity _connectivity = Connectivity();

  /// Obtém a API key dinamicamente (atualizada do Remote Config)
  String get _apiKey => AppConstants.giphyApiKey;

  /// Verifica o tipo de conexão atual
  Future<String> _getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // connectivity_plus 5.0+ retorna List<ConnectivityResult>
      // mas pode variar conforme a versão
      final List<ConnectivityResult> results =
          result is List<ConnectivityResult>
          ? result as List<ConnectivityResult>
          : [result as ConnectivityResult];
      // Prioriza WiFi sobre dados móveis
      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'Dados Móveis';
      }
      return 'Desconhecido';
    } catch (e) {
      return 'Desconhecido';
    }
  }

  /// Mensagem de erro SSL específica baseada no tipo de conexão
  Future<String> _getSslErrorMessage() async {
    final connectionType = await _getConnectionType();

    if (connectionType == 'WiFi') {
      return 'Erro de conexão no WiFi. Tente usar dados móveis ou outro WiFi.';
    } else {
      return 'Erro de conexão SSL. Verifique sua internet e tente novamente.';
    }
  }

  /// Valida se a API key está configurada
  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      debugPrint('[GiphyService] ⚠️ API Key está vazia!');
      debugPrint(
        '[GiphyService] Configure o Remote Config no Firebase Console ou o arquivo .env',
      );
      throw Exception(
        'Chave de API não configurada. Configure o Firebase Remote Config com a chave "giphy_api_key" ou adicione GIPHY_API_KEY no arquivo .env',
      );
    }
  }

  /// Busca GIF aleatório
  Future<GifModel?> getRandomGif({
    String? tag,
    String rating = 'g',
    String? randomId,
  }) async {
    _validateApiKey();
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
        debugPrint(
          '[GiphyService] API Key inválida ou ausente (HTTP ${response.statusCode})',
        );
        throw Exception(
          'Chave de API inválida. Configure o Firebase Remote Config com a chave "giphy_api_key" ou adicione GIPHY_API_KEY no arquivo .env',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[GiphyService] Erro no servidor: ${response.statusCode}');
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        debugPrint('[GiphyService] Random GIF error: ${response.statusCode}');
      }
    } catch (e) {
      final errorString = e.toString();

      // Erros de DNS/hostname lookup
      if (errorString.contains('Failed host lookup') ||
          errorString.contains('No address associated with hostname') ||
          errorString.contains('SocketException') ||
          e is SocketException) {
        throw Exception(
          'Erro de conexão. Verifique sua internet e tente novamente.',
        );
      }

      // Erros de certificado SSL
      if (errorString.contains('HandshakeException') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorString.contains('TlsException') ||
          errorString.contains('CertificateException') ||
          errorString.contains('SSL')) {
        final errorMessage = await _getSslErrorMessage();
        throw Exception(errorMessage);
      }

      // Erros de timeout
      if (errorString.contains('TimeoutException') ||
          errorString.contains('timed out')) {
        throw Exception('Tempo de conexão esgotado. Tente novamente.');
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
    _validateApiKey();
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
        debugPrint(
          '[GiphyService] API Key inválida ou ausente (HTTP ${response.statusCode})',
        );
        throw Exception(
          'Chave de API inválida. Configure o Firebase Remote Config com a chave "giphy_api_key" ou adicione GIPHY_API_KEY no arquivo .env',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[GiphyService] Erro no servidor: ${response.statusCode}');
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        debugPrint('[GiphyService] Trending error: ${response.statusCode}');
      }
    } catch (e) {
      final errorString = e.toString();

      // Erros de DNS/hostname lookup
      if (errorString.contains('Failed host lookup') ||
          errorString.contains('No address associated with hostname') ||
          errorString.contains('SocketException') ||
          e is SocketException) {
        throw Exception(
          'Erro de conexão. Verifique sua internet e tente novamente.',
        );
      }

      // Erros de certificado SSL
      if (errorString.contains('HandshakeException') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorString.contains('TlsException') ||
          errorString.contains('CertificateException') ||
          errorString.contains('SSL')) {
        final errorMessage = await _getSslErrorMessage();
        throw Exception(errorMessage);
      }

      // Erros de timeout
      if (errorString.contains('TimeoutException') ||
          errorString.contains('timed out')) {
        throw Exception('Tempo de conexão esgotado. Tente novamente.');
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
    _validateApiKey();
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
        debugPrint(
          '[GiphyService] API Key inválida ou ausente (HTTP ${response.statusCode})',
        );
        throw Exception(
          'Chave de API inválida. Configure o Firebase Remote Config com a chave "giphy_api_key" ou adicione GIPHY_API_KEY no arquivo .env',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('[GiphyService] Erro no servidor: ${response.statusCode}');
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        debugPrint('[GiphyService] Search error: ${response.statusCode}');
      }
    } catch (e) {
      final errorString = e.toString();

      // Erros de DNS/hostname lookup
      if (errorString.contains('Failed host lookup') ||
          errorString.contains('No address associated with hostname') ||
          errorString.contains('SocketException') ||
          e is SocketException) {
        throw Exception(
          'Erro de conexão. Verifique sua internet e tente novamente.',
        );
      }

      // Erros de certificado SSL
      if (errorString.contains('HandshakeException') ||
          errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorString.contains('TlsException') ||
          errorString.contains('CertificateException') ||
          errorString.contains('SSL')) {
        final errorMessage = await _getSslErrorMessage();
        throw Exception(errorMessage);
      }

      // Erros de timeout
      if (errorString.contains('TimeoutException') ||
          errorString.contains('timed out')) {
        throw Exception('Tempo de conexão esgotado. Tente novamente.');
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
    _validateApiKey();
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
    _validateApiKey();
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
    _validateApiKey();
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
    _validateApiKey();
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
