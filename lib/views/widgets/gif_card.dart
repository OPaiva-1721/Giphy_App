import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/gif_model.dart';
import '../../constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/collection_viewmodel.dart';
import '../../services/cache_service.dart';

/// Card de GIF
class GifCard extends StatelessWidget {
  final GifModel gif;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isFavorite;
  final bool showActions;

  const GifCard({
    super.key,
    required this.gif,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.isFavorite = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _showFullScreen(context),
        onDoubleTap: () => _showFullScreen(context),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // GIF Image
              if (gif.url != null)
                _CachedGifImage(url: gif.url!, fit: BoxFit.cover),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      if (gif.title != null && gif.title!.isNotEmpty)
                        Text(
                          gif.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      // Username
                      if (gif.username != null && gif.username!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '@${gif.username}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Actions
              if (showActions)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      // Favorite button
                      if (onFavorite != null)
                        _ActionButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onTap: onFavorite!,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),

                      const SizedBox(height: 8),

                      // Share button
                      if (onShare != null)
                        _ActionButton(icon: Icons.share, onTap: onShare!),

                      const SizedBox(height: 8),

                      // Add to collection button
                      _ActionButton(
                        icon: Icons.playlist_add,
                        onTap: () => _showAddToCollectionSheet(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCollectionSheet(BuildContext context) async {
    final collectionVm = context.read<CollectionViewModel>();
    await collectionVm.initialize();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final collections = collectionVm.collections;
        if (collections.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhuma coleção. Crie uma na aba Coleções.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemBuilder: (c, i) {
            final col = collections[i];
            final alreadyIn = collectionVm.isGifInCollection(
              col.id,
              gif.id ?? '',
            );
            return ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(col.name),
              subtitle: col.description != null && col.description!.isNotEmpty
                  ? Text(col.description!)
                  : null,
              trailing: Icon(alreadyIn ? Icons.check : Icons.add),
              onTap: () async {
                if (!alreadyIn) {
                  await collectionVm.addGifToCollection(col.id, gif);
                } else if (gif.id != null) {
                  await collectionVm.removeGifFromCollection(col.id, gif.id!);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        alreadyIn
                            ? 'Removido de ${col.name}'
                            : 'Adicionado em ${col.name}',
                      ),
                    ),
                  );
                }
              },
            );
          },
          separatorBuilder: (c, i) => const Divider(height: 0),
          itemCount: collections.length,
        );
      },
    );
  }

  void _showFullScreen(BuildContext context) {
    if (gif.url == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoView(
                imageProvider: CachedNetworkImageProvider(gif.url!),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        children: [
                          if (onFavorite != null)
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                onFavorite?.call();
                              },
                            ),
                          if (onShare != null)
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.white, size: 28),
                              onPressed: () {
                                onShare?.call();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (gif.title != null || gif.username != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gif.title != null && gif.title!.isNotEmpty)
                            Text(
                              gif.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (gif.username != null && gif.username!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '@${gif.username}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color ?? Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _CachedGifImage extends StatefulWidget {
  const _CachedGifImage({required this.url, required this.fit});

  final String url;
  final BoxFit fit;

  @override
  State<_CachedGifImage> createState() => _CachedGifImageState();
}

class _CachedGifImageState extends State<_CachedGifImage> {
  File? _file;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    if (kIsWeb) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    final cache = CacheService();
    final cached = await cache.getCachedFile(widget.url);
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _file = cached;
        _loading = false;
      });
      return;
    }
    // Download e cacheia
    try {
      final resp = await http.get(Uri.parse(widget.url));
      if (resp.statusCode == 200) {
        final saved = await cache.cacheFile(widget.url, resp.bodyBytes);
        if (!mounted) return;
        setState(() {
          _file = saved;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(widget.url, fit: widget.fit, gaplessPlayback: true);
    }
    if (_loading) {
      return Container(
        color: AppColors.shimmerBase,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_file != null) {
      return Image.file(_file!, fit: widget.fit, gaplessPlayback: true);
    }
    // Fallback
    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: widget.fit,
      placeholder: (context, url) => Container(
        color: AppColors.shimmerBase,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.shimmerBase,
        child: const Center(child: Icon(Icons.error_outline, size: 48)),
      ),
    );
  }
}
