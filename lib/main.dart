import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/gif_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/collection_viewmodel.dart';
import 'views/screens/main_screen.dart';
import 'utils/app_theme.dart';
import 'constants/app_strings.dart';
import 'config/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tenta carregar .env, mas não bloqueia se não existir
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      '[Main] Arquivo .env não encontrado. Use .env.example como template.',
    );
  }

  // Inicializa Firebase e Remote Config (opcional - não quebra se não configurado)
  // Na web, só inicializa se tiver FirebaseOptions configuradas
  if (kIsWeb) {
    // Na web, Firebase precisa de FirebaseOptions explicitamente
    // Se não estiver configurado, pula a inicialização
    debugPrint(
      '[Main] Plataforma Web detectada. Firebase precisa de firebase_options.dart configurado.',
    );
    debugPrint(
      '[Main] Pulando inicialização do Firebase. Usando configurações locais (.env ou hardcoded).',
    );
  } else {
    // Para Android/iOS, tenta inicializar normalmente
    try {
      debugPrint('[Main] Inicializando Firebase...');
      await Firebase.initializeApp();
      debugPrint('[Main] ✅ Firebase inicializado com sucesso');

      // Inicializa Remote Config para permitir atualização remota da API key
      debugPrint('[Main] Inicializando Remote Config...');
      final remoteConfigInitialized = await RemoteConfigService().initialize();
      if (remoteConfigInitialized) {
        debugPrint('[Main] ✅ Remote Config inicializado');
        // Força uma busca imediata para garantir que temos a chave
        try {
          await RemoteConfigService().forceFetch();
          final apiKey = RemoteConfigService().getGiphyApiKey();
          debugPrint(
            '[Main] API Key status: ${apiKey.isNotEmpty ? "✅ Configurada" : "❌ VAZIA"}',
          );
        } catch (e) {
          debugPrint('[Main] ⚠️ Erro ao forçar busca do Remote Config: $e');
        }
      } else {
        debugPrint('[Main] ⚠️ Remote Config não inicializado, usando .env');
      }
    } catch (e, stackTrace) {
      debugPrint('[Main] ❌ Erro ao inicializar Firebase: $e');
      debugPrint('[Main] Stack trace: $stackTrace');
      debugPrint(
        '[Main] Firebase não configurado. Usando configurações locais (.env).',
      );

      // Verifica se .env tem a chave
      try {
        final envKey = dotenv.env['GIPHY_API_KEY'] ?? '';
        if (envKey.isNotEmpty) {
          debugPrint('[Main] ✅ Encontrou GIPHY_API_KEY no .env');
        } else {
          debugPrint('[Main] ❌ GIPHY_API_KEY não encontrado no .env');
        }
      } catch (e) {
        debugPrint('[Main] ⚠️ Erro ao ler .env: $e');
      }
    }
  }

  runApp(const GiphyUltimateApp());
}

class GiphyUltimateApp extends StatelessWidget {
  const GiphyUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => GifViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => UserViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()..initialize()),
        ChangeNotifierProvider(
          create: (_) => CollectionViewModel()..initialize(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            onGenerateRoute: AppRoutes.generateRoute,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
