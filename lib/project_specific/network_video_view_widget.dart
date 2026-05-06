import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoViewWidget extends StatefulWidget {
  final String videoString;
  final String thumbnail;
  final bool muted; // ADD THIS

  const NetworkVideoViewWidget({
    super.key,
    required this.videoString,
    required this.thumbnail,
    this.muted = false, // default is sound on
  });

  @override
  State<NetworkVideoViewWidget> createState() => _NetworkVideoViewWidgetState();
}

class _NetworkVideoViewWidgetState extends State<NetworkVideoViewWidget> {
  CachedVideoPlayerPlus? _player;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.videoString),
    );

    _player?.initialize().then((_) {
      if (!mounted) return;
      _player?.controller.setLooping(true);
      _player?.controller.setVolume(widget.muted ? 0.0 : 1.0); // CHANGE THIS
      _player?.controller.play();

      setState(() {
        _isInitialized = true; // ✅ control rendering safely
      });
    }).catchError((e) {
      debugPrint("Video init error: $e");
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 SAFETY CHECK (MOST IMPORTANT)

    /// 🔥 LOADING STATE
    if (!_isInitialized || _player == null) {
      return Stack(
        children: [
          Center(
            child: widget.thumbnail.isEmpty
                ? const SizedBox()
                : CachedNetworkImage(
                    imageUrl: widget.thumbnail,
                    fit: BoxFit.cover,
                  ),
          ),
          const ColoredBox(
            color: Colors.black45,
            child: Center(child: CircularProgressIndicator(strokeWidth: 5)),
          ),
        ],
      );
    }

    final controller = _player!.controller;

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(
          controller,
        ),
      ),
    );
  }
}
