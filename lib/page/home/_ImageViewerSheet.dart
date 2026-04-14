import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerSheet extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerSheet({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewerSheet> createState() => _ImageViewerSheetState();
}

class _ImageViewerSheetState extends State<ImageViewerSheet> {
  late PageController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          /// 🔥 DRAG HANDLE (nice UX)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          /// 🔝 TOP BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${currentIndex + 1} / ${widget.images.length}",
                  style: const TextStyle(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 30,),
                )
              ],
            ),
          ),

          /// 🖼 IMAGE VIEWER
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) {
                setState(() => currentIndex = i);
              },
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 3,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                      const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (_, __, ___) =>
                      const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}