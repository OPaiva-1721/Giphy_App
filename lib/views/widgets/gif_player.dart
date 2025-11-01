import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../models/gif_model.dart';
import '../../constants/app_colors.dart';

/// Player de GIF com controles
class GifPlayer extends StatefulWidget {
  final GifModel gif;
  final bool playing;
  final VoidCallback? onPlayPause;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final bool isFavorite;
  final bool showControls;
  final VoidCallback? onAddToCollection;

  const GifPlayer({
    super.key,
    required this.gif,
    this.playing = true,
    this.onPlayPause,
    this.onFavorite,
    this.onShare,
    this.onDownload,
    this.isFavorite = false,
    this.showControls = true,
    this.onAddToCollection,
  });

  @override
  State<GifPlayer> createState() => _GifPlayerState();
}

class _GifPlayerState extends State<GifPlayer> {
  bool _showControls = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        // Maximizar GIF ao dar duplo toque
        _showFullScreen(context);
      },
      onTap: () {
        if (widget.showControls) {
          setState(() {
            _showControls = !_showControls;
          });

          if (_showControls) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showControls = false;
                });
              }
            });
          }
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // GIF
            Center(
              child: widget.gif.url != null
                  ? CachedNetworkImage(
                      imageUrl: widget.playing
                          ? widget.gif.url!
                          : (widget.gif.stillUrl ?? widget.gif.url!),
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: AppColors.backgroundDark,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.backgroundDark,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Erro ao carregar GIF',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Nenhum GIF selecionado',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
            ),

            // Controls overlay
            if (_showControls && widget.showControls)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top bar
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.gif.title != null)
                                      Text(
                                        widget.gif.title!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (widget.gif.username != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '@${widget.gif.username}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Center play/pause button
                      if (widget.onPlayPause != null)
                        Center(
                          child: IconButton(
                            onPressed: widget.onPlayPause,
                            icon: Icon(
                              widget.playing
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Bottom controls
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Maximize
                              _ControlButton(
                                icon: Icons.fullscreen,
                                label: 'Maximizar',
                                onTap: () => _showFullScreen(context),
                              ),

                              // Favorite
                              if (widget.onFavorite != null)
                                _ControlButton(
                                  icon: widget.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  label: 'Favoritar',
                                  onTap: widget.onFavorite!,
                                  color: widget.isFavorite ? Colors.red : null,
                                ),

                              // Add to Collection
                              if (widget.onAddToCollection != null)
                                _ControlButton(
                                  icon: Icons.playlist_add,
                                  label: 'Coleção',
                                  onTap: widget.onAddToCollection!,
                                ),

                              // Share
                              if (widget.onShare != null)
                                _ControlButton(
                                  icon: Icons.share,
                                  label: 'Compartilhar',
                                  onTap: widget.onShare!,
                                ),

                              // Download
                              if (widget.onDownload != null)
                                _ControlButton(
                                  icon: Icons.download,
                                  label: 'Baixar',
                                  onTap: widget.onDownload!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    if (widget.gif.url == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoView(
                imageProvider: CachedNetworkImageProvider(widget.gif.url!),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color ?? Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
