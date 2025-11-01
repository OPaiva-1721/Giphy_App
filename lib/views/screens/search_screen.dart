import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../widgets/gif_card.dart';
import '../widgets/category_chip.dart';

/// Tela de busca de GIFs
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<SearchViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onChanged: (value) {
            context.read<SearchViewModel>().searchWithDebounce(value);
            context.read<SearchViewModel>().loadSuggestions(value);
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<SearchViewModel>().search(value);
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<SearchViewModel>().clearSearch();
              },
            ),
        ],
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, searchViewModel, _) {
          // Mostra erro se houver
          if (searchViewModel.hasError &&
              searchViewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(searchViewModel.errorMessage!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () => searchViewModel.clearError(),
                  ),
                ),
              );
            });
          }

          // Mostra sugestões quando estiver digitando
          if (_searchController.text.isNotEmpty &&
              searchViewModel.searchResults.isEmpty &&
              !searchViewModel.loading) {
            return _buildSuggestions(searchViewModel);
          }

          // Mostra trending e histórico quando não há busca
          if (searchViewModel.currentQuery.isEmpty) {
            return _buildEmptyState(searchViewModel);
          }

          // Mostra erro ou sem resultados
          if (searchViewModel.searchResults.isEmpty &&
              !searchViewModel.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchViewModel.hasError
                        ? Icons.error_outline
                        : Icons.search_off,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchViewModel.hasError
                        ? (searchViewModel.errorMessage ??
                              AppStrings.errorGeneric)
                        : AppStrings.noResults,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (searchViewModel.hasError) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        searchViewModel.clearError();
                        if (searchViewModel.currentQuery.isNotEmpty) {
                          searchViewModel.search(searchViewModel.currentQuery);
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppStrings.retry),
                    ),
                  ],
                ],
              ),
            );
          }

          return _buildResults(searchViewModel);
        },
      ),
    );
  }

  Widget _buildSuggestions(SearchViewModel viewModel) {
    return ListView(
      children: [
        if (viewModel.suggestions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sugestões',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...viewModel.suggestions.map((suggestion) {
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(suggestion),
              onTap: () {
                _searchController.text = suggestion;
                viewModel.search(suggestion);
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEmptyState(SearchViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trending Searches
        if (viewModel.trendingSearches.isNotEmpty) ...[
          const Text(
            AppStrings.searchTrending,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: viewModel.trendingSearches.take(10).map((term) {
              return CategoryChip(
                label: term,
                onTap: () {
                  _searchController.text = term;
                  viewModel.search(term);
                },
                icon: Icons.trending_up,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Recent Searches
        if (viewModel.searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.searchRecent,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: viewModel.clearHistory,
                child: const Text(AppStrings.clearHistory),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...viewModel.searchHistory.take(10).map((history) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(history.query),
              subtitle: Text('${history.resultCount} resultados'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => viewModel.removeFromHistory(history.id),
              ),
              onTap: () {
                _searchController.text = history.query;
                viewModel.search(history.query);
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _buildResults(SearchViewModel searchViewModel) {
    final gifViewModel = context.read<GifViewModel>();

    return RefreshIndicator(
      onRefresh: () async {
        if (searchViewModel.currentQuery.isNotEmpty) {
          await searchViewModel.search(searchViewModel.currentQuery);
        }
      },
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount:
            searchViewModel.searchResults.length +
            (searchViewModel.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= searchViewModel.searchResults.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

        final gif = searchViewModel.searchResults[index];
        return GifCard(
          gif: gif,
          isFavorite: gifViewModel.favorites.any((f) => f.gif.id == gif.id),
          onTap: () {
            // Maximiza o GIF ao tocar
            // O GifCard já tem a funcionalidade de maximizar
          },
          onFavorite: () async {
            if (gifViewModel.favorites.any((f) => f.gif.id == gif.id)) {
              await gifViewModel.removeFavorite(gif);
            } else {
              await gifViewModel.addFavorite(gif);
            }
          },
          onShare: () => gifViewModel.shareCurrentGif(),
        );
        },
      ),
    );
  }
}
