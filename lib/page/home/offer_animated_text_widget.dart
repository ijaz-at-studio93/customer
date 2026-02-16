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

  void _startLoop() {
    loopTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;

      /// STEP 1 — salon goes DOWN
      setState(() {
        showSalon = false;
      });

      await Future.delayed(const Duration(milliseconds: 450));

      /// STEP 2 — content comes FROM TOP
      setState(() {
        showContent = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      /// STEP 3 — content goes DOWN
      setState(() {
        showContent = false;
      });

      await Future.delayed(const Duration(milliseconds: 450));

      /// STEP 4 — salon comes FROM TOP again
      setState(() {
        showSalon = true;
      });
    });
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
          height: 45,
          child: Stack(
            alignment: Alignment.center, // 🔥 keeps everything centered
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
                          fontSize: 18,
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
                  child: SizedBox(
                    width: double.infinity, // 🔥 IMPORTANT
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 1),

        /// STATIC TEXT (never animates)
        const Text(
          "               *Offer can be applied at checkout",
          style: TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 9,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
