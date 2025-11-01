import 'package:flutter/material.dart';
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
  try {
    await Firebase.initializeApp();
    debugPrint('[Main] Firebase inicializado com sucesso');
    
    // Inicializa Remote Config para permitir atualização remota da API key
    await RemoteConfigService().initialize();
    debugPrint('[Main] Remote Config inicializado');
  } catch (e) {
    debugPrint(
      '[Main] Firebase não configurado. Usando configurações locais (.env ou hardcoded).',
    );
    debugPrint('[Main] Erro: $e');
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
