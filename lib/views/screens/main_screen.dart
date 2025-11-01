import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../constants/app_strings.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'collections_screen.dart';
import 'profile_screen.dart';

/// Tela principal com navegação inferior
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    CollectionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh de conteúdo ao trocar de aba
          final gifVm = context.read<GifViewModel>();
          switch (index) {
            case 0: // Home
              gifVm.fetchRandomGif();
              break;
            case 1: // Explore
              gifVm.fetchTrendingGifs(limit: 50);
              break;
            case 2: // Collections
              // Nada por agora (coleções carregam do storage)
              break;
            case 3: // Profile
              // Poderia atualizar stats se necessário
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: AppStrings.navExplore,
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_outlined),
            selectedIcon: Icon(Icons.collections),
            label: AppStrings.navCollections,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}

