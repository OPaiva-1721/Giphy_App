import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../viewmodels/collection_viewmodel.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../models/gif_model.dart';
import '../widgets/gif_player.dart';
import 'search_screen.dart';

/// Tela inicial com visualizador de GIFs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega o primeiro GIF
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gifViewModel = context.read<GifViewModel>();
      if (gifViewModel.currentGif == null) {
        gifViewModel.fetchRandomGif();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            tooltip: AppStrings.search,
          ),

          // Auto-shuffle toggle
          Consumer<GifViewModel>(
            builder: (context, viewModel, _) {
              return IconButton(
                icon: Icon(
                  viewModel.autoShuffle
                      ? Icons.shuffle
                      : Icons.shuffle_outlined,
                ),
                onPressed: viewModel.toggleAutoShuffle,
                tooltip: AppStrings.autoShuffle,
                color: viewModel.autoShuffle ? AppColors.accent : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<GifViewModel>(
        builder: (context, viewModel, _) {
          // Mostra erro se houver
          if (viewModel.hasError && viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () => viewModel.clearError(),
                  ),
                ),
              );
            });
          }

          if (viewModel.loading && viewModel.currentGif == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.currentGif == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    viewModel.hasError ? Icons.error_outline : Icons.gif_box,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.hasError
                        ? (viewModel.errorMessage ?? AppStrings.errorGeneric)
                        : 'Nenhum GIF carregado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      viewModel.clearError();
                      viewModel.fetchRandomGif();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(AppStrings.newGif),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchRandomGif();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                  child: Stack(
                    children: [
                      // GIF Player
                      GifPlayer(
                        gif: viewModel.currentGif!,
                        playing: viewModel.playing,
                        isFavorite: viewModel.isCurrentGifFavorite,
                        onPlayPause: viewModel.togglePlaying,
                        onFavorite: () async {
                          await viewModel.toggleFavorite();
                        },
                        onShare: () => viewModel.shareCurrentGif(),
                        onDownload: () => viewModel.downloadCurrentGif(),
                        onAddToCollection: () => _showAddToCollectionSheet(
                          context,
                          viewModel.currentGif!,
                        ),
                      ),

                      // Loading overlay
                      if (viewModel.loading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<GifViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Trending GIF button
              FloatingActionButton.small(
                heroTag: 'trending',
                onPressed: viewModel.loading
                    ? null
                    : viewModel.fetchTrendingGif,
                tooltip: AppStrings.trendingGif,
                child: const Icon(Icons.trending_up),
              ),

              const SizedBox(height: 12),

              // Random GIF button
              FloatingActionButton(
                heroTag: 'random',
                onPressed: viewModel.loading ? null : viewModel.fetchRandomGif,
                tooltip: AppStrings.randomGif,
                child: const Icon(Icons.shuffle),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddToCollectionSheet(BuildContext context, GifModel gif) async {
    final collectionVm = context.read<CollectionViewModel>();
    await collectionVm.initialize();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final collections = collectionVm.collections;
        if (collections.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.folder_open,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma coleção criada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crie uma coleção na aba Coleções para organizar seus GIFs favoritos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Navegar para aba de coleções
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Coleção'),
                ),
              ],
            ),
          );
        }

        return Consumer<CollectionViewModel>(
          builder: (context, vm, _) {
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: collections.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (c, i) {
                final col = collections[i];
                final alreadyIn = vm.isGifInCollection(col.id, gif.id ?? '');
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: col.color != null
                          ? Color(int.parse(col.color!))
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder, color: AppColors.primary),
                  ),
                  title: Text(col.name),
                  subtitle:
                      col.description != null && col.description!.isNotEmpty
                      ? Text(col.description!)
                      : Text('${col.gifCount} GIFs'),
                  trailing: Icon(
                    alreadyIn ? Icons.check_circle : Icons.add_circle_outline,
                    color: alreadyIn ? AppColors.accent : null,
                  ),
                  onTap: () async {
                    if (!alreadyIn) {
                      await vm.addGifToCollection(col.id, gif);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Adicionado em ${col.name}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else if (gif.id != null) {
                      await vm.removeGifFromCollection(col.id, gif.id!);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Removido de ${col.name}')),
                        );
                      }
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
