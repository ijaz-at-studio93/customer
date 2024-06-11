import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog extends StatelessWidget {
  final String? title;
  final String? desc;

  const PermissionDialog({Key? key, this.title, this.desc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? AlertDialog(
            title: Text(title ?? 'Enable camera access'),
            actionsPadding: const EdgeInsets.only(bottom: 20),
            content: Text(desc ??
                'Please update permissions to let fame access your camera'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () {
                        Get.back(result:  true);
                      },
                      splashColor: Colors.grey.withOpacity(0.7),
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: Get.textTheme.titleMedium?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                  const SizedBox(width: 20),
                  InkWell(
                      onTap: () async {
                        Get.back();
                        await openAppSettings();
                      },
                      splashColor: Colors.grey.withOpacity(0.7),
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: Get.textTheme.titleMedium?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          )
        : CupertinoAlertDialog(
            title: Text(title ?? 'Enable camera access'),
            content: Text(desc ??
                'Please update permissions to let fame access your camera'),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              CupertinoDialogAction(

                onPressed: () {
                  Get.back(result:  true);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
  }
}
