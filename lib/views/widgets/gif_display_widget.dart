import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/cache_service.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../models/reaction_model.dart';

class GifDisplayWidget extends StatelessWidget {
  final GifViewModel gifViewModel;
  final VoidCallback? onTap;
  final Function(String)? onReaction;

  const GifDisplayWidget({
    super.key,
    required this.gifViewModel,
    this.onTap,
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[GifDisplayWidget] Building - loading: ${gifViewModel.loading}, gif: ${gifViewModel.currentGif?.title}, url: ${gifViewModel.currentGif?.url}',
    );
    return Center(
      child: gifViewModel.loading
          ? const CircularProgressIndicator()
          : gifViewModel.currentGif?.url == null
          ? const Text('Toque em "Novo GIF" ou aguarde o auto-shuffle (7s).')
          : GestureDetector(
              onTap: onTap,
              child: Stack(
                children: [
                  // GIF or still image
                  gifViewModel.playing
                      ? _CachedGifDisplay(url: gifViewModel.currentGif!.url!)
                      : _CachedGifDisplay(
                          url:
                              (gifViewModel.currentGif!.stillUrl?.isNotEmpty ==
                                  true
                              ? gifViewModel.currentGif!.stillUrl!
                              : gifViewModel.currentGif!.url!),
                        ),

                  // Reaction button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      tooltip: 'Reagir',
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      onSelected: (reactionType) =>
                          onReaction?.call(reactionType),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'like',
                          child: Text('👍 Curtir'),
                        ),
                        const PopupMenuItem(
                          value: 'love',
                          child: Text('❤️ Amar'),
                        ),
                        const PopupMenuItem(
                          value: 'laugh',
                          child: Text('😂 Rir'),
                        ),
                        const PopupMenuItem(
                          value: 'wow',
                          child: Text('😮 Uau'),
                        ),
                        const PopupMenuItem(
                          value: 'sad',
                          child: Text('😢 Triste'),
                        ),
                        const PopupMenuItem(
                          value: 'angry',
                          child: Text('😡 Bravo'),
                        ),
                      ],
                    ),
                  ),

                  // Fullscreen button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      tooltip: 'Tela cheia',
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _FullscreenImage(
                              url: gifViewModel.currentGif!.url!,
                              title: gifViewModel.currentGif!.title ?? 'GIF',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _GifWithOnloadPing extends StatefulWidget {
  const _GifWithOnloadPing({required this.url, required this.onFirstFrame});

  final String url;
  final VoidCallback onFirstFrame;

  @override
  State<_GifWithOnloadPing> createState() => _GifWithOnloadPingState();
}

class _CachedGifDisplay extends StatefulWidget {
  const _CachedGifDisplay({required this.url});

  final String url;

  @override
  State<_CachedGifDisplay> createState() => _CachedGifDisplayState();
}

class _CachedGifDisplayState extends State<_CachedGifDisplay> {
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
      return Image.network(
        widget.url,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    }
    if (_loading) {
      return const SizedBox(
        width: 64,
        height: 64,
        child: CircularProgressIndicator(),
      );
    }
    if (_file != null) {
      return Image.file(_file!, fit: BoxFit.contain, gaplessPlayback: true);
    }
    return Image.network(
      widget.url,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}

class _GifWithOnloadPingState extends State<_GifWithOnloadPing> {
  bool _fired = false;

  @override
  void didUpdateWidget(_GifWithOnloadPing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      debugPrint(
        '[GifWithOnloadPing] URL changed from ${oldWidget.url} to ${widget.url}, resetting _fired',
      );
      _fired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSync) {
        if (frame != null && !_fired) {
          _fired = true;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onFirstFrame(),
          );
        }
        return child;
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.isEmpty ? 'GIF' : title)),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 5,
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
