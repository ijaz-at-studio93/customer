import 'package:flutter/material.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../constant/color_constant.dart';
//
// class AddButtonWidget extends StatefulWidget {
//   final VoidCallback onPress;
//   final  Color  color;
//   const AddButtonWidget({super.key, required this.onPress, required this.color});
//
//   @override
//   State<AddButtonWidget> createState() => _AddButtonWidgetState();
// }
//
// class _AddButtonWidgetState extends State<AddButtonWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(10),
//         onTap: widget.onPress,
//         child: Container(
//           height: 40,
//           width: 110,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: ColorConstant.whiteColor,
//             border: Border.all(color: widget.color),
//           ),
//           child: Container(
//             color: Colors.transparent,
//             height: 40,
//             width: 110,
//             child: Center(
//               child: Text(
//                 "Add",
//                 style: AppTextTheme.bold
//                     .copyWith(fontSize: 12, color: widget.color,fontFamily: 'Outfit'),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class AddButtonWidget extends StatefulWidget {
  final VoidCallback onPress;
  final Color color;

  const AddButtonWidget({
    super.key,
    required this.onPress,
    required this.color,
  });

  @override
  State<AddButtonWidget> createState() => _AddButtonWidgetState();
}

class _AddButtonWidgetState extends State<AddButtonWidget> {
  bool isProcessing = false; // 🔥 prevent spam

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          if (isProcessing) return; // 🔥 prevent multiple taps

          setState(() {
            isProcessing = true;
          });

          widget.onPress();

          await Future.delayed(const Duration(milliseconds: 200));
          // small buffer to avoid double tap spam

          setState(() {
            isProcessing = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 40,
          width: 110,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isProcessing
                ? widget.color.withOpacity(0.1) // 👈 press feedback
                : ColorConstant.whiteColor,
            border: Border.all(color: widget.color),
          ),
          child: Text(
            isProcessing ? "..." : "Add", // 👈 optional feedback
            style: AppTextTheme.bold.copyWith(
              fontSize: 12,
              color: widget.color,
              fontFamily: 'Outfit',
            ),
          ),
        ),
      ),
    );
  }
}