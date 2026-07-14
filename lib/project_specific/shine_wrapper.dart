import 'package:flutter/material.dart';

/// Reusable "shine"/shimmer overlay that sweeps a soft translucent highlight
/// across its [child] on an infinite loop. Used on attention-drawing chips
/// (e.g. appointment status chips like "Awaiting Confirmation" and the salon
/// "New" tag).
class ShineWrapper extends StatefulWidget {
  final Widget child;

  const ShineWrapper({super.key, required this.child});

  @override
  State<ShineWrapper> createState() => _ShineWrapperState();
}

class _ShineWrapperState extends State<ShineWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(); // infinite loop
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final x = _controller.value;

            return LinearGradient(
              begin: Alignment(-2 + 3 * x, -1), // ← top shifted more to left
              end: Alignment(-1.2 + 3 * x, 1), // ← bottom stays
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
