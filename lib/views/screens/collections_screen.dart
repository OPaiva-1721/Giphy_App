import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../viewmodels/collection_viewmodel.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../widgets/gif_card.dart';

/// Tela de coleções e favoritos
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.navCollections),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: AppStrings.favorites),
              Tab(icon: Icon(Icons.folder), text: AppStrings.myCollections),
            ],
          ),
        ),
        body: const TabBarView(children: [_FavoritesTab(), _CollectionsTab()]),
      ),
    );
  }
}

class _FavoritesTab extends StatefulWidget {
  const _FavoritesTab();

  @override
  State<_FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<_FavoritesTab> {
  @override
  void initState() {
    super.initState();
    // Garante que os favoritos sejam carregados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<GifViewModel>();
      if (viewModel.favorites.isEmpty) {
        viewModel.refreshFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GifViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.favorites.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.refreshFavorites();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.emptyFavorites,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.refreshFavorites();
          },
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: viewModel.favorites.length,
            itemBuilder: (context, index) {
              final favorite = viewModel.favorites[index];
              return GifCard(
                gif: favorite.gif,
                isFavorite: true,
                onTap: () {
                  // Maximiza o GIF ao tocar
                  // O GifCard já tem a funcionalidade de maximizar
                },
                onFavorite: () => viewModel.removeFavorite(favorite.gif),
                onShare: () => viewModel.shareCurrentGif(),
              );
            },
          ),
        );
      },
    );
  }
}

class _CollectionsTab extends StatefulWidget {
  const _CollectionsTab();

  @override
  State<_CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<_CollectionsTab> {
  @override
  void initState() {
    super.initState();
    // Garante que as coleções sejam carregadas
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<CollectionViewModel>();
      if (viewModel.collections.isEmpty && viewModel.favorites.isEmpty) {
        await viewModel.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.collections.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.folder_open,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.emptyCollection,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateCollectionDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.createCollection),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.collections.length,
            itemBuilder: (context, index) {
              final collection = viewModel.collections[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: collection.color != null
                          ? Color(int.parse(collection.color!))
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.folder, color: AppColors.primary),
                  ),
                  title: Text(collection.name),
                  subtitle: Text(
                    '${collection.gifCount} GIFs',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    viewModel.selectCollection(collection);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            _CollectionDetailScreen(collection: collection),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.createCollection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.collectionName,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<CollectionViewModel>().createCollection(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}

class _CollectionDetailScreen extends StatelessWidget {
  final dynamic collection;

  const _CollectionDetailScreen({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(collection.name)),
      body: Consumer2<CollectionViewModel, GifViewModel>(
        builder: (context, collectionViewModel, gifViewModel, _) {
          final gifs = collectionViewModel.selectedCollectionFavorites;

          if (gifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.emptyCollection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: gifs.length,
            itemBuilder: (context, index) {
              final favorite = gifs[index];
              return GifCard(
                gif: favorite.gif,
                isFavorite: true,
                onTap: () {
                  // Maximiza o GIF ao tocar
                  // O GifCard já tem a funcionalidade de maximizar
                },
                onFavorite: () => gifViewModel.removeFavorite(favorite.gif),
                onShare: () => gifViewModel.shareCurrentGif(),
              );
            },
          );
        },
      ),
    );
  }
}
