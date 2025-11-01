import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Serviço para gerenciar configurações remotas via Firebase Remote Config
/// Permite atualizar valores como API keys sem precisar lançar nova versão do app
class RemoteConfigService {
  static RemoteConfigService? _instance;
  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  RemoteConfigService._();

  factory RemoteConfigService() {
    _instance ??= RemoteConfigService._();
    return _instance!;
  }

  /// Inicializa o Remote Config
  /// Retorna true se inicializado com sucesso, false caso contrário
  Future<bool> initialize() async {
    if (_initialized && _remoteConfig != null) {
      return true;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Configurações padrão (fallback caso não consiga buscar do Firebase)
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Valores padrão caso o Firebase não esteja configurado ou não consiga buscar
      // Obtém a chave local do .env ou hardcoded como fallback
      final localApiKey =
          dotenv.env['GIPHY_API_KEY'] ??
          const String.fromEnvironment(
            'GIPHY_API_KEY',
            defaultValue: 'YOUR_API_KEY_HERE',
          );
      await _remoteConfig!.setDefaults({'giphy_api_key': localApiKey});

      // Tenta buscar valores atualizados do Firebase
      try {
        await _remoteConfig!.fetchAndActivate();
        debugPrint('[RemoteConfigService] Configurações remotas carregadas');
      } catch (e) {
        debugPrint(
          '[RemoteConfigService] Não foi possível buscar do Firebase, usando valores padrão: $e',
        );
      }

      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('[RemoteConfigService] Erro ao inicializar: $e');
      debugPrint(
        '[RemoteConfigService] Usando configurações locais (.env ou hardcoded)',
      );
      _initialized = false;
      return false;
    }
  }

  /// Obtém a API Key do Giphy
  /// Tenta buscar do Remote Config primeiro, depois do .env, depois do hardcoded
  String getGiphyApiKey() {
    if (_initialized && _remoteConfig != null) {
      try {
        final remoteKey = _remoteConfig!.getString('giphy_api_key');
        // Obtém a chave local para comparação
        final localKey =
            dotenv.env['GIPHY_API_KEY'] ??
            const String.fromEnvironment(
              'GIPHY_API_KEY',
              defaultValue: 'YOUR_API_KEY_HERE',
            );
        // Só usa se não for o valor padrão ou se estiver configurado
        if (remoteKey.isNotEmpty &&
            remoteKey != 'YOUR_API_KEY_HERE' &&
            remoteKey != localKey) {
          debugPrint('[RemoteConfigService] Usando API key do Remote Config');
          return remoteKey;
        }
      } catch (e) {
        debugPrint('[RemoteConfigService] Erro ao ler do Remote Config: $e');
      }
    }

    // Fallback para o método original
    debugPrint(
      '[RemoteConfigService] Usando API key local (.env ou hardcoded)',
    );
    return dotenv.env['GIPHY_API_KEY'] ??
        const String.fromEnvironment(
          'GIPHY_API_KEY',
          defaultValue: 'YOUR_API_KEY_HERE',
        );
  }

  /// Força atualização das configurações remotas
  /// Útil quando você precisa atualizar a API key e quer que os apps busquem imediatamente
  Future<bool> fetchAndActivate() async {
    if (!_initialized || _remoteConfig == null) {
      return false;
    }

    try {
      final updated = await _remoteConfig!.fetchAndActivate();
      if (updated) {
        debugPrint(
          '[RemoteConfigService] Configurações remotas atualizadas com sucesso',
        );
      }
      return updated;
    } catch (e) {
      debugPrint('[RemoteConfigService] Erro ao atualizar configurações: $e');
      return false;
    }
  }

  /// Verifica se o Remote Config está disponível
  bool get isAvailable => _initialized && _remoteConfig != null;
}
