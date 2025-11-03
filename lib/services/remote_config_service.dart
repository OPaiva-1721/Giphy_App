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
      // Duration.zero permite atualização imediata (sem cache mínimo)
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              Duration.zero, // Atualização imediata (sem cache)
        ),
      );

      // Valores padrão caso o Firebase não esteja configurado ou não consiga buscar
      // Obtém a chave local do .env
      final localApiKey = dotenv.env['GIPHY_API_KEY'] ?? '';
      await _remoteConfig!.setDefaults({'giphy_api_key': localApiKey});

      // Tenta buscar valores atualizados do Firebase
      try {
        debugPrint(
          '[RemoteConfigService] Tentando buscar configurações do Firebase...',
        );
        final updated = await _remoteConfig!.fetchAndActivate();
        if (updated) {
          debugPrint(
            '[RemoteConfigService] ✅ Configurações remotas carregadas e ativadas',
          );
          final remoteKey = _remoteConfig!.getString('giphy_api_key');
          debugPrint(
            '[RemoteConfigService] Chave obtida do Remote Config: ${remoteKey.isNotEmpty ? "${remoteKey.substring(0, remoteKey.length > 8 ? 8 : remoteKey.length)}..." : "VAZIA"}',
          );
        } else {
          debugPrint(
            '[RemoteConfigService] ⚠️ Configurações buscadas mas não havia novas atualizações',
          );
        }
      } catch (e, stackTrace) {
        debugPrint('[RemoteConfigService] ❌ Erro ao buscar do Firebase: $e');
        debugPrint('[RemoteConfigService] Stack trace: $stackTrace');
        debugPrint(
          '[RemoteConfigService] Usando valores padrão (localApiKey: ${localApiKey.isNotEmpty ? "${localApiKey.substring(0, localApiKey.length > 8 ? 8 : localApiKey.length)}..." : "VAZIA"})',
        );
      }

      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('[RemoteConfigService] Erro ao inicializar: $e');
      debugPrint('[RemoteConfigService] Usando configurações locais (.env)');
      _initialized = false;
      return false;
    }
  }

  /// Obtém a API Key do Giphy
  /// Prioridade: 1) Remote Config 2) .env
  String getGiphyApiKey() {
    if (_initialized && _remoteConfig != null) {
      try {
        final remoteKey = _remoteConfig!.getString('giphy_api_key');
        // Sempre usa a chave remota se estiver disponível e for válida
        if (remoteKey.isNotEmpty) {
          debugPrint(
            '[RemoteConfigService] ✅ Usando API key do Remote Config (${remoteKey.substring(0, remoteKey.length > 8 ? 8 : remoteKey.length)}...)',
          );
          return remoteKey;
        } else {
          debugPrint(
            '[RemoteConfigService] ⚠️ Remote Config retornou chave vazia',
          );
        }
      } catch (e) {
        debugPrint('[RemoteConfigService] Erro ao ler do Remote Config: $e');
      }
    } else {
      debugPrint('[RemoteConfigService] ⚠️ Remote Config não inicializado');
    }

    // Fallback para .env
    final envKey = dotenv.env['GIPHY_API_KEY'] ?? '';
    if (envKey.isNotEmpty) {
      debugPrint('[RemoteConfigService] ✅ Usando API key local (.env)');
      return envKey;
    } else {
      debugPrint(
        '[RemoteConfigService] ⚠️ Arquivo .env não contém GIPHY_API_KEY',
      );
    }

    // Se nenhum estiver disponível, retorna vazio
    debugPrint('[RemoteConfigService] ❌ Nenhuma API key configurada!');
    debugPrint(
      '[RemoteConfigService] Configure o Firebase Remote Config com a chave "giphy_api_key" no Firebase Console',
    );
    return '';
  }

  /// Força atualização imediata das configurações remotas
  /// Ignora o cache e busca valores atualizados do Firebase imediatamente
  Future<bool> fetchAndActivate() async {
    if (!_initialized || _remoteConfig == null) {
      return false;
    }

    try {
      // Busca e ativa imediatamente, ignorando o cache
      final updated = await _remoteConfig!.fetchAndActivate();
      if (updated) {
        debugPrint(
          '[RemoteConfigService] Configurações remotas atualizadas com sucesso (imediatamente)',
        );
      } else {
        debugPrint(
          '[RemoteConfigService] Não havia novas configurações para atualizar',
        );
      }
      return updated;
    } catch (e) {
      debugPrint('[RemoteConfigService] Erro ao atualizar configurações: $e');
      return false;
    }
  }

  /// Força busca imediata mesmo se já estiver inicializado
  /// Útil para atualizar a chave após mudanças no Firebase Console
  Future<bool> forceFetch() async {
    if (_remoteConfig == null) {
      // Se não estiver inicializado, tenta inicializar primeiro
      final initialized = await initialize();
      if (!initialized) {
        debugPrint(
          '[RemoteConfigService] Não foi possível inicializar para forceFetch',
        );
        return false;
      }
    }

    // Tenta buscar até 3 vezes com delay
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint(
          '[RemoteConfigService] Tentativa $attempt/3 de forceFetch...',
        );
        final updated = await fetchAndActivate();
        if (updated) {
          debugPrint(
            '[RemoteConfigService] ✅ forceFetch bem-sucedido na tentativa $attempt',
          );
          return true;
        } else if (attempt < 3) {
          debugPrint(
            '[RemoteConfigService] ⚠️ Nenhuma atualização, tentando novamente...',
          );
          await Future.delayed(Duration(seconds: attempt)); // Delay progressivo
        }
      } catch (e) {
        debugPrint('[RemoteConfigService] ❌ Erro na tentativa $attempt: $e');
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    debugPrint('[RemoteConfigService] ⚠️ forceFetch falhou após 3 tentativas');
    return false;
  }

  /// Verifica se o Remote Config está disponível
  bool get isAvailable => _initialized && _remoteConfig != null;
}
