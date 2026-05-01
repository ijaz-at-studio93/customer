import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoViewWidget extends StatefulWidget {
  final String videoString;
  final bool muted; // ADD THIS

  const NetworkVideoViewWidget({
    super.key,
    required this.videoString,
    this.muted = false, // default is sound on
  });

  @override
  State<NetworkVideoViewWidget> createState() =>
      _NetworkVideoViewWidgetState();
}

class _NetworkVideoViewWidgetState
    extends State<NetworkVideoViewWidget> {
  CachedVideoPlayerPlus? _player;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.videoString),
    );

    _player!.initialize().then((_) {
      if (!mounted) return;

      _player!.controller.setLooping(true);
      _player!.controller.play();
      _player!.controller.setVolume(widget.muted ? 0.0 : 1.0); // CHANGE THIS

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
    if (!_isInitialized || _player == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final controller = _player!.controller;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}