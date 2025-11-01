import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../viewmodels/gif_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'widgets/gif_display_widget.dart';
import 'widgets/controls_widget.dart';
import 'widgets/comments_dialog.dart';
import 'widgets/stats_dialog.dart';
import 'widgets/editor_dialog.dart';
import 'widgets/favorites_page.dart';

class GifPage extends StatefulWidget {
  final GifViewModel gifViewModel;
  final ThemeViewModel themeViewModel;

  const GifPage({
    super.key,
    required this.gifViewModel,
    required this.themeViewModel,
  });

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {
  @override
  void initState() {
    super.initState();
    widget.gifViewModel.initialize().then((_) {
      widget.gifViewModel.fetchRandomGif();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gifViewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Buscador de GIF 2.0 (${widget.gifViewModel.userStats.points} pts)',
            ),
            actions: [
              // Theme selector
              PopupMenuButton<String>(
                tooltip: 'Tema',
                icon: const Icon(Icons.color_lens_outlined),
                onSelected: (value) {
                  switch (value) {
                    case 'light':
                      widget.themeViewModel.setThemeMode(ThemeMode.light);
                      break;
                    case 'dark':
                      widget.themeViewModel.setThemeMode(ThemeMode.dark);
                      break;
                    default:
                      widget.themeViewModel.setThemeMode(ThemeMode.system);
                  }
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    value: 'system',
                    checked:
                        widget.themeViewModel.themeMode == ThemeMode.system,
                    child: const Text('Sistema'),
                  ),
                  CheckedPopupMenuItem(
                    value: 'light',
                    checked: widget.themeViewModel.themeMode == ThemeMode.light,
                    child: const Text('Claro'),
                  ),
                  CheckedPopupMenuItem(
                    value: 'dark',
                    checked: widget.themeViewModel.themeMode == ThemeMode.dark,
                    child: const Text('Escuro'),
                  ),
                ],
              ),

              // Favorite button
              IconButton(
                tooltip: widget.gifViewModel.isCurrentGifFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                icon: Icon(
                  widget.gifViewModel.isCurrentGifFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                onPressed: widget.gifViewModel.currentGif?.url == null
                    ? null
                    : () => widget.gifViewModel.toggleFavorite(),
              ),

              // Favorites page
              IconButton(
                tooltip: 'Favoritos',
                icon: const Icon(Icons.collections_bookmark_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FavoritesPage(
                        favorites: widget.gifViewModel.favorites,
                        onRemove: widget.gifViewModel.removeFavorite,
                      ),
                    ),
                  );
                },
              ),

              // Stats
              IconButton(
                tooltip: 'Estatísticas',
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () => _showStatsDialog(),
              ),

              // Categories
              PopupMenuButton<String>(
                tooltip: 'Categorias',
                icon: const Icon(Icons.category_outlined),
                onSelected: (category) =>
                    widget.gifViewModel.fetchByCategory(category),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'trending',
                    child: Text('🔥 Trending'),
                  ),
                  const PopupMenuItem(
                    value: 'funny',
                    child: Text('😂 Engraçado'),
                  ),
                  const PopupMenuItem(
                    value: 'animals',
                    child: Text('🐱 Animais'),
                  ),
                  const PopupMenuItem(
                    value: 'sports',
                    child: Text('⚽ Esportes'),
                  ),
                  const PopupMenuItem(value: 'memes', child: Text('😎 Memes')),
                  const PopupMenuItem(
                    value: 'reactions',
                    child: Text('😮 Reações'),
                  ),
                  const PopupMenuItem(
                    value: 'celebrities',
                    child: Text('⭐ Celebridades'),
                  ),
                  const PopupMenuItem(value: 'tv', child: Text('📺 TV')),
                  const PopupMenuItem(
                    value: 'movies',
                    child: Text('🎬 Filmes'),
                  ),
                ],
              ),

              // Editor
              IconButton(
                tooltip: 'Editor de GIFs',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditorDialog(),
              ),

              // Share
              if (widget.gifViewModel.currentGif?.url != null)
                IconButton(
                  tooltip: 'Compartilhar',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    final title =
                        widget.gifViewModel.currentGif?.title?.isNotEmpty ==
                            true
                        ? widget.gifViewModel.currentGif!.title!
                        : 'Confira este GIF!';
                    Share.share(
                      '$title\n${widget.gifViewModel.currentGif!.url}',
                    );
                  },
                ),

              // Play/Pause
              if (widget.gifViewModel.currentGif?.url != null)
                IconButton(
                  tooltip: widget.gifViewModel.playing
                      ? 'Pausar GIF'
                      : 'Reproduzir GIF',
                  icon: Icon(
                    widget.gifViewModel.playing
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                  onPressed: () => widget.gifViewModel.togglePlayPause(),
                ),

              // Auto-shuffle toggle
              IconButton(
                tooltip: widget.gifViewModel.autoShuffle
                    ? 'Pausar auto (7s)'
                    : 'Retomar auto (7s)',
                icon: Icon(
                  widget.gifViewModel.autoShuffle
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                onPressed: () => widget.gifViewModel.toggleAutoShuffle(),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Controls
                ControlsWidget(
                  gifViewModel: widget.gifViewModel,
                  onSearch: (query) => widget.gifViewModel.searchGif(query),
                  onFetchRandom: () => widget.gifViewModel.fetchRandomGif(),
                  onFetchTrending: () => widget.gifViewModel.fetchTrendingGif(),
                ),

                const SizedBox(height: 6),

                // GIF Display
                Expanded(
                  child: GifDisplayWidget(
                    gifViewModel: widget.gifViewModel,
                    onTap: () => _showCommentsDialog(),
                    onReaction: (reactionType) =>
                        widget.gifViewModel.addReaction(reactionType),
                  ),
                ),

                // Title
                if (widget.gifViewModel.currentGif?.title?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.gifViewModel.currentGif!.title!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentsDialog() {
    if (widget.gifViewModel.currentGif?.url == null) return;

    showDialog(
      context: context,
      builder: (context) => CommentsDialog(
        gifViewModel: widget.gifViewModel,
        onAddComment: (text) => widget.gifViewModel.addComment(text),
        onRemoveComment: (commentId) =>
            widget.gifViewModel.removeComment(commentId),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatsDialog(
        userStats: widget.gifViewModel.userStats,
        getAchievementName: (id) =>
            widget.gifViewModel.getAchievementNotification(id),
      ),
    );
  }

  void _showEditorDialog() {
    showDialog(
      context: context,
      builder: (context) => EditorDialog(gifViewModel: widget.gifViewModel),
    );
  }
}
