import 'dart:async';
import 'package:flutter/material.dart';

class OfferAnimatedTextWidget extends StatefulWidget {
  final String salonName;
  final String title;
  final String description;

  const OfferAnimatedTextWidget({
    super.key,
    required this.salonName,
    required this.title,
    required this.description,
  });

  @override
  State<OfferAnimatedTextWidget> createState() =>
      _OfferAnimatedTextWidgetState();
}

class _OfferAnimatedTextWidgetState extends State<OfferAnimatedTextWidget> {
  bool showSalon = true;
  bool showContent = false;
  Timer? loopTimer;

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  void _startLoop() async {
    while (mounted) {
      /// ✅ SHOW SALON
      setState(() {
        showSalon = true;
        showContent = false;
      });

      await Future.delayed(const Duration(seconds: 2));

      /// transition
      setState(() {
        showSalon = false;
      });

      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;

      /// ✅ SHOW CONTENT
      setState(() {
        showContent = true;
      });

      // await Future.delayed(const Duration(seconds: 2));

      /// transition
      setState(() {
        showContent = false;
      });

      await Future.delayed(const Duration(milliseconds: 450));
    }
  }

  @override
  void dispose() {
    loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// ANIMATED AREA (salon + offer)
        SizedBox(
          height: 42,
          child: Stack(
            //alignment: Alignment.center, // 🔥 keeps everything centered
            children: [
              /// SALON NAME — moves DOWN from center
              AnimatedSlide(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                offset: showSalon ? Offset.zero : const Offset(0, 0.4),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showSalon ? 1 : 0,
                  child: Align(
                    alignment: Alignment.centerLeft, // 🔥 FIX
                    child: SizedBox(
                      width: double.infinity, // 🔥 IMPORTANT
                      child: Text(
                        widget.salonName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// OFFER CONTENT — comes from TOP to center
              AnimatedSlide(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                offset: showContent ? Offset.zero : const Offset(0, -0.4),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showContent ? 1 : 0,
                  child: Align(
                    alignment: Alignment.centerLeft, // 👈 SAME AS SALON
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 👈 KEY FIX
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2), // small spacing
                          Text(
                            widget.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
