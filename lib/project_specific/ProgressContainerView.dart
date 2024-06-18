import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ProgressContainerView extends StatelessWidget {
  final Widget? child;
  final Widget? progressWidget;
  final bool? isProgressRunning;
  final String progressText;
  final double progressWidgetOpacity;

  const ProgressContainerView(
      {@required this.child,
      @required this.isProgressRunning,
      this.progressText = "Please Wait",
      this.progressWidgetOpacity = 0.1,
      this.progressWidget,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child ?? Container(),
        Positioned.fill(
          child: Visibility(
              visible: isProgressRunning ?? false,
              child: Container(
                width: Get.width,
                  color: Colors.black.withOpacity(progressWidgetOpacity),
                  child: progressWidget ??
                      const Center(
                        child: Padding(
                            padding: EdgeInsets.all(18),
                            child: ProgressBarView()),
                      ))),
        ),
      ],
    );
  }
}
