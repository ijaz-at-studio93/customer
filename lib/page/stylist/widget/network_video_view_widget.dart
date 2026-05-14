import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../project_specific/progressbar_view.dart';

class NetworkVideoViewWidget extends StatefulWidget {
  final String videoString;
  final ValueNotifier<bool>? pauseNotifier;

  const NetworkVideoViewWidget({
    super.key,
    required this.videoString,
    this.pauseNotifier,
  });

  @override
  State<NetworkVideoViewWidget> createState() => _NetworkVideoViewWidgetState();
}

class _NetworkVideoViewWidgetState extends State<NetworkVideoViewWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoString));
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          if (widget.pauseNotifier?.value != true) {
            _controller.play();
          }
        });
      }
    });
    widget.pauseNotifier?.addListener(_onPauseChanged);
  }

  void _onPauseChanged() {
    if (widget.pauseNotifier?.value == true) {
      _controller.pause();
    } else {
      if (_controller.value.isInitialized) _controller.play();
    }
  }

  @override
  void dispose() {
    widget.pauseNotifier?.removeListener(_onPauseChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const ProgressBarView(),
        ), /* Positioned(
            left: 0,
            right: 0,
            top: Get.height / 2,
            child: isPlay
                ? const SizedBox()
                : const Icon(
              Icons.play_arrow,
              size: 50,
            ))*/
      ],
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
