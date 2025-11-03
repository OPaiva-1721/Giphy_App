import 'package:flutter/material.dart';

/// Rotas do aplicativo
class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String explore = '/explore';
  static const String collections = '/collections';
  static const String collectionDetail = '/collection-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String achievements = '/achievements';
  static const String favorites = '/favorites';
  static const String downloads = '/downloads';
  static const String gifDetail = '/gif-detail';
  static const String createCollection = '/create-collection';
  static const String editCollection = '/edit-collection';

  /// Gera rotas
  static Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        // Será implementado na próxima etapa
        return null;

      case search:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: routeSettings,
        );

      case explore:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: routeSettings,
        );

      case collections:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: routeSettings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: routeSettings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: routeSettings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  /// Navega para uma rota
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Substitui a rota atual
  static Future<T?> pushReplacement<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Remove todas as rotas e navega
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Volta para a tela anterior
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Verifica se pode voltar
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
