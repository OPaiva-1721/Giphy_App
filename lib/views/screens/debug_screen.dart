import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../services/remote_config_service.dart';
import '../../constants/app_colors.dart';
import '../../viewmodels/gif_viewmodel.dart';

/// Tela de debug para verificar status do Firebase e API keys
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isRefreshing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isRefreshing = true;
      _statusMessage = 'Verificando status...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final remoteConfig = RemoteConfigService();
    final apiKey = remoteConfig.getGiphyApiKey();

    setState(() {
      _isRefreshing = false;
      if (apiKey.isNotEmpty) {
        _statusMessage = '✅ API Key configurada';
      } else {
        _statusMessage = '❌ API Key não configurada';
      }
    });
  }

  Future<void> _forceFetch() async {
    setState(() {
      _isRefreshing = true;
      _statusMessage = 'Forçando atualização do Remote Config...';
    });

    try {
      final updated = await RemoteConfigService().forceFetch();
      if (updated) {
        // Limpa erros de API key nos ViewModels
        try {
          final gifViewModel = Provider.of<GifViewModel>(context, listen: false);
          if (gifViewModel.isApiKeyError) {
            gifViewModel.clearError();
          }
        } catch (e) {
          debugPrint('[DebugScreen] Erro ao limpar erros: $e');
        }

        setState(() {
          _statusMessage = '✅ Configurações atualizadas com sucesso! Erros limpos.';
        });
        await Future.delayed(const Duration(seconds: 1));
        _checkStatus();
      } else {
        setState(() {
          _statusMessage = '⚠️ Nenhuma atualização disponível';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erro: $e';
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = RemoteConfigService();
    final apiKey = remoteConfig.getGiphyApiKey();
    final isAvailable = remoteConfig.isAvailable;
    final envKey = dotenv.env['GIPHY_API_KEY'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug / Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _checkStatus,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status geral
              Card(
                color: apiKey.isNotEmpty
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            apiKey.isNotEmpty
                                ? Icons.check_circle
                                : Icons.error,
                            color: apiKey.isNotEmpty ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage.isEmpty
                                  ? (apiKey.isNotEmpty
                                      ? '✅ API Key configurada'
                                      : '❌ API Key não configurada')
                                  : _statusMessage,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: apiKey.isNotEmpty
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isRefreshing)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Firebase Status
              _buildSection(
                context,
                'Firebase Status',
                [
                  _buildStatusRow(
                    'Remote Config Inicializado',
                    isAvailable,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // API Key Status
              _buildSection(
                context,
                'API Key Status',
                [
                  _buildStatusRow(
                    'Chave do Remote Config',
                    apiKey.isNotEmpty && isAvailable,
                    value: isAvailable && apiKey.isNotEmpty
                        ? '${apiKey.substring(0, apiKey.length > 12 ? 12 : apiKey.length)}...'
                        : 'Não disponível',
                  ),
                  _buildStatusRow(
                    'Chave do .env',
                    envKey.isNotEmpty,
                    value: envKey.isNotEmpty
                        ? '${envKey.substring(0, envKey.length > 12 ? 12 : envKey.length)}...'
                        : 'Não encontrada',
                  ),
                  _buildStatusRow(
                    'Chave em uso',
                    apiKey.isNotEmpty,
                    value: apiKey.isNotEmpty
                        ? '${apiKey.substring(0, apiKey.length > 12 ? 12 : apiKey.length)}...'
                        : 'NENHUMA',
                    isError: apiKey.isEmpty,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRefreshing ? null : _forceFetch,
                      icon: const Icon(Icons.sync),
                      label: const Text('Forçar Atualização'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Informações adicionais
              _buildSection(
                context,
                'Informações',
                [
                  _buildInfoRow('Fonte da API Key:', isAvailable && apiKey.isNotEmpty
                      ? 'Firebase Remote Config'
                      : envKey.isNotEmpty
                          ? 'Arquivo .env'
                          : 'NENHUMA'),
                  _buildInfoRow(
                      'API Key válida:', apiKey.isNotEmpty ? 'Sim' : 'Não'),
                  _buildInfoRow(
                      'Comprimento da chave:', '${apiKey.length} caracteres'),
                ],
              ),

              const SizedBox(height: 24),

              // Instruções
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Como configurar',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Acesse o Firebase Console\n'
                        '2. Vá em Remote Config\n'
                        '3. Crie o parâmetro "giphy_api_key"\n'
                        '4. Cole sua API Key do GIPHY\n'
                        '5. Clique em "Publicar alterações"\n'
                        '6. Use o botão "Forçar Atualização" acima',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Copiar API Key (parcialmente)
              if (apiKey.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Copiar início da chave'),
                    subtitle: Text(
                      apiKey.length > 20
                          ? '${apiKey.substring(0, 20)}...'
                          : apiKey,
                    ),
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: apiKey.length > 20
                              ? '${apiKey.substring(0, 20)}...'
                              : apiKey,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Início da chave copiado!'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, bool isSuccess, {String? value, bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isSuccess && !isError
                ? Icons.check_circle
                : Icons.error_outline,
            color: isSuccess && !isError ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (value != null)
            Text(
              value,
              style: TextStyle(
                color: isError
                    ? Colors.red
                    : isSuccess
                        ? Colors.green.shade700
                        : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

