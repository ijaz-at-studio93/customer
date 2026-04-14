import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPopupViewer extends StatefulWidget {
  final String videoUrl;

  const VideoPopupViewer({super.key, required this.videoUrl});

  @override
  State<VideoPopupViewer> createState() => _VideoPopupViewerState();
}

class _VideoPopupViewerState extends State<VideoPopupViewer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🔥 Zoom support
        InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(),
          ),
        ),

        /// ❌ Close button
        // Positioned(
        //   top: 10,
        //   right: 10,
        //   child: GestureDetector(
        //     onTap: () => Navigator.pop(context),
        //     child: const Icon(Icons.close, color: Colors.white, size: 26),
        //   ),
        // ),
      ],
    );
  }
}