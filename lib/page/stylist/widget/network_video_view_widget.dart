import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../project_specific/progressbar_view.dart';

class NetworkVideoViewWidget extends StatefulWidget {
  final String videoString;

  const NetworkVideoViewWidget({super.key, required this.videoString, t});

  @override
  State<NetworkVideoViewWidget> createState() => _NetworkVideoViewWidgetState();
}

class _NetworkVideoViewWidgetState extends State<NetworkVideoViewWidget> {
  late VideoPlayerController _controller;
  bool isPlay = false;
  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoString,
    ));
    _controller.setLooping(true);
    _controller.initialize().then((value) {
      setState(() {
        _controller.play();
      });
    });
    super.initState();
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
