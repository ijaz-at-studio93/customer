import 'package:flutter/material.dart';

class ActionIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  State<ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<ActionIconButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: isPressed ? 0.85 : 1,
        // child: Container(
        //   padding: const EdgeInsets.all(6), // 👈 bigger tap area
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: isPressed
        //         ? Colors.grey.withOpacity(0.15)
        //         : Colors.transparent,
        //   ),
        //   child: Icon(widget.icon, size: 18),
        // ),
        child: Container(
          width: 36,   // 👈 FIXED tap area
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPressed
                ? Colors.grey.withOpacity(0.15)
                : Colors.transparent,
          ),
          child: Icon(widget.icon, size: 18),
        ),
      ),
    );
  }
}