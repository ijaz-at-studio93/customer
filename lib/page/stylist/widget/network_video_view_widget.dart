// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class NetworkVideoViewWidget extends StatefulWidget {
//   final String videoString;
//   final String thumbnail;

//   const NetworkVideoViewWidget({
//     super.key,
//     required this.videoString,
//     this.thumbnail = "",
//   });

//   @override
//   State<NetworkVideoViewWidget> createState() => _NetworkVideoViewWidgetState();
// }

// class _NetworkVideoViewWidgetState extends State<NetworkVideoViewWidget> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         VideoPlayerController.networkUrl(Uri.parse(widget.videoString));
//     _controller.setLooping(true);
//     _controller.initialize().then((_) {
//       if (!mounted) return;
//       setState(() {
//         _controller.play();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_controller.value.isInitialized) {
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           if (widget.thumbnail.isNotEmpty)
//             CachedNetworkImage(
//               imageUrl: widget.thumbnail,
//               fit: BoxFit.cover,
//               errorWidget: (_, __, ___) =>
//                   const ColoredBox(color: Colors.black),
//             )
//           else
//             const ColoredBox(color: Colors.black),
//           const Center(
//             child:
//                 CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//           ),
//         ],
//       );
//     }

//     return SizedBox.expand(
//       child: FittedBox(
//         fit: BoxFit.cover,
//         child: SizedBox(
//           width: _controller.value.size.width,
//           height: _controller.value.size.height,
//           child: VideoPlayer(_controller),
//         ),
//       ),
//     );
//   }
// }
