import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../widgets/gif_card.dart';
import '../widgets/category_chip.dart';

/// Categorias populares
const List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[
  {'name': 'Reações', 'icon': Icons.emoji_emotions},
  {'name': 'Animais', 'icon': Icons.pets},
  {'name': 'Esportes', 'icon': Icons.sports_soccer},
  {'name': 'Celebridades', 'icon': Icons.star},
  {'name': 'Filmes', 'icon': Icons.movie},
  {'name': 'TV', 'icon': Icons.tv},
  {'name': 'Música', 'icon': Icons.music_note},
  {'name': 'Arte', 'icon': Icons.palette},
  {'name': 'Natureza', 'icon': Icons.nature},
  {'name': 'Comida', 'icon': Icons.restaurant},
  {'name': 'Memes', 'icon': Icons.mood},
  {'name': 'Amor', 'icon': Icons.favorite},
  {'name': 'Festa', 'icon': Icons.celebration},
  {'name': 'Jogos', 'icon': Icons.sports_esports},
];

/// Mapeia rótulos PT-BR para termos de busca aceitos pela API
const Map<String, String> _categoryQueryMap = {
  'Reações': 'reactions',
  'Animais': 'animals',
  'Esportes': 'sports',
  'Celebridades': 'celebrities',
  'Filmes': 'movies',
  'TV': 'tv',
  'Música': 'music',
  'Arte': 'art',
  'Natureza': 'nature',
  'Comida': 'food',
  'Memes': 'memes',
  'Amor': 'love',
  'Festa': 'party',
  'Jogos': 'games',
};

/// Tela de exploração com categorias e trending
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gifViewModel = context.read<GifViewModel>();
      if (gifViewModel.gifs.isEmpty) {
        gifViewModel.fetchTrendingGifs(limit: 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navExplore)),
      body: Consumer<GifViewModel>(
        builder: (context, viewModel, _) {
          // Mostra erro se houver (apenas uma vez)
          if (viewModel.hasError && viewModel.errorMessage != null) {
            final errorMessage = viewModel.errorMessage!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Limpa o erro antes de mostrar para evitar loop
              viewModel.clearError();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(
                        reason: SnackBarClosedReason.action,
                      );
                    },
                  ),
                ),
              );
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_selectedCategory != null) {
                final query =
                    _categoryQueryMap[_selectedCategory] ?? _selectedCategory!;
                await viewModel.searchGifs(query, limit: 50);
              } else {
                await viewModel.fetchTrendingGifs(limit: 50);
              }
            },
            child: CustomScrollView(
              slivers: [
                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.searchCategories,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((category) {
                            final isSelected =
                                _selectedCategory == category['name'];
                            return CategoryChip(
                              label: category['name'] as String,
                              icon: category['icon'] as IconData,
                              selected: isSelected,
                              onTap: () async {
                                if (isSelected) {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                  await viewModel.fetchTrendingGifs(limit: 50);
                                } else {
                                  final selectedName =
                                      category['name'] as String;
                                  setState(() {
                                    _selectedCategory = selectedName;
                                  });
                                  final query =
                                      _categoryQueryMap[selectedName] ??
                                      selectedName;
                                  await viewModel.searchGifs(query, limit: 50);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      _selectedCategory ?? AppStrings.searchTrending,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Loading state
                if (viewModel.loading && viewModel.gifs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Empty state
                if (!viewModel.loading && viewModel.gifs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noResults,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () =>
                                viewModel.fetchTrendingGifs(limit: 50),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // GIFs Grid - sempre mostra quando há GIFs, mesmo durante loading
                if (viewModel.gifs.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childCount: viewModel.gifs.length,
                      itemBuilder: (context, index) {
                        final gif = viewModel.gifs[index];
                        return GifCard(
                          gif: gif,
                          isFavorite: viewModel.favorites.any(
                            (f) => f.gif.id == gif.id,
                          ),
                          onTap: () {
                            // Maximiza o GIF ao tocar
                            // O GifCard já tem a funcionalidade de maximizar
                          },
                          onFavorite: () async {
                            if (viewModel.favorites.any(
                              (f) => f.gif.id == gif.id,
                            )) {
                              await viewModel.removeFavorite(gif);
                            } else {
                              await viewModel.addFavorite(gif);
                            }
                          },
                          onShare: () => viewModel.shareCurrentGif(),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
