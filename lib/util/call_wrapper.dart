import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SharedPrefs.dart';
import '../constant/variable_constant.dart';

class CallWrapper extends StatefulWidget {
  final Widget child;
  final Offset? initialPosition;

  const CallWrapper({required this.child, this.initialPosition, Key? key}) : super(key: key);

  @override
  State<CallWrapper> createState() => _CallWrapperState();
}

class _CallWrapperState extends State<CallWrapper> {
  late Offset position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    const fabSize = 56.0;
    const margin = 16.0;

    // Start bottom-right but lifted up by ~80px (enough for label + safe space)
    position = Offset(
      size.width - fabSize - margin,
      size.height - fabSize - margin - kBottomNavigationBarHeight - 80,
    );
  }

  void _makeCall() async {
    final uri = Uri(scheme: 'tel', path: '+919347882037');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Offset _clampToBounds(Offset p) {
    final size = MediaQuery.of(context).size;
    final safe = MediaQuery.of(context).viewPadding;
    const fabSize = 56.0;
    const margin = 8.0;

    final minX = margin;
    final maxX = size.width - fabSize - margin;

    final minY = safe.top + margin;
    final maxY = size.height - fabSize - margin - kBottomNavigationBarHeight - 5;
    // 30px extra space above bottom nav so "Help 24*7" text is always visible

    return Offset(
      p.dx.clamp(minX, maxX),
      p.dy.clamp(minY, maxY),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanUpdate: (d) {
              setState(() => position = _clampToBounds(position + d.delta));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'global-call-fab',
                  onPressed: _makeCall,
                  backgroundColor: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender),
                  ),
                  child: const Icon(Icons.call, size: 28),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Help 24×7",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
