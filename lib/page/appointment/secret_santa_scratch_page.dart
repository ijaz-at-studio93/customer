import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'package:confetti/confetti.dart';

class SecretSantaScratchDialog extends StatefulWidget {
  final String rewardName;

  const SecretSantaScratchDialog({
    super.key,
    required this.rewardName
  });

  @override
  State<SecretSantaScratchDialog> createState() =>
      _SecretSantaScratchDialogState();
}

class _SecretSantaScratchDialogState extends State<SecretSantaScratchDialog>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  late ConfettiController _confetti;

  // glow / blink animation
  late final AnimationController _glowController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 1));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutBack),
    );

    _opacityAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [

            // 🎬 GIF BACKGROUND
            Positioned.fill(
              child: Image.asset(
                "assets/gifs/secret_santa_bg.gif",
                fit: BoxFit.cover,
              ),
            ),

            // 🟣 OPTIONAL: dark overlay for readability
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
            // ---------------- CONFETTI ----------------
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 30,
                  minBlastForce: 10,
                  gravity: 0.3,
                ),
              ),
            ),

            // ---------------- MAIN UI ----------------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Secret Santa 🎅",
                    style: TextStyle(
                      fontFamily: "Bungee",  // <-- Use your uploaded font
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9B4DFF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Santa has a special surprise for you!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 18),

                  // ------------- GLOWING CIRCLE + SCRATCH -------------
                  // AnimatedBuilder(
                  //   animation: _glowController,
                  //   builder: (context, child) {
                  //     return Opacity(
                  //       opacity: _opacityAnim.value,
                  //       child: Transform.scale(
                  //         scale: _scaleAnim.value,
                  //         child: child,
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     width: circleSize,
                  //     height: circleSize,
                  //     decoration: const BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       gradient: RadialGradient(
                  //         colors: [Color(0xFFFDF4FF), Color(0xFFE2C5FF)],
                  //         center: Alignment.center,
                  //         radius: 0.75,
                  //       ),
                  //     ),
                  //     padding: const EdgeInsets.all(2),
                  //     child: _buildScratchLayer(circleSize - 40),
                  //   ),
                  // ),

                  SizedBox(
                    width: circleSize,
                    height: circleSize,// 👈 keeps dialog wide
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -50), // 👈 move UP (adjust as needed)
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnim.value,
                              child: Transform.scale(
                                scale: _scaleAnim.value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildScratchLayer(circleSize * 0.75),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: !_revealed
                        ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B4DFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: null,
                      child: const Text(
                        "Scratch to reveal your surprise",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                        : Row(
                          children: [
                            // ❌ IGNORE
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF9B4DFF)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: const Text(
                                  "Ignore",
                                  style: TextStyle(
                                    color: Color(0xFF9B4DFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // ✅ CLAIM
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9B4DFF),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: const Text(
                                  "Claim",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
    );
  }

  Widget _buildScratchLayer(double size) {
    final cardSize = size * 0.8; // inner card size inside purple circle

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Scratcher(
          brushSize: 45,
          threshold: 60,
          // this is the “gold scratch card” artwork on top
          image: Image.asset(
            "assets/images/secret_santa_card.png",
            width: cardSize,
            height: cardSize,
            fit: BoxFit.cover,
          ),
          color: Colors
              .transparent, // important: no extra background colour, no black box
          onThreshold: () {
            if (!_revealed) {
              setState(() => _revealed = true);
              _confetti.play();
            }
          },

          // 👇 This is what becomes visible as you scratch
          child: Container(
            width: size * 1.0,
            height: size * 1.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: const DecorationImage(
                image: AssetImage("assets/images/secret_santa_reveal.png"),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.center,
            child: _revealed
                ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Congratulations\n\nYou Won\nFree "+widget.rewardName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 8,
                        color: Colors.black),
                  ],
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ),
      )
    );
  }
}
