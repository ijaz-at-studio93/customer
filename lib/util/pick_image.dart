import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FileUtils {
  static openPlatformImagePicker(
      {required Function(File) onSelectImage}) async {
    if (Platform.isAndroid) {
      showDialog(
          context: Get.context!,
          builder: (context) {
            return Dialog(
              child: Container(
                height: Get.height * 0.12,
                width: Get.width * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Get.back();
                            File selectedImage = await openCameraForImage();
                            onSelectImage.call(selectedImage);
                          },
                          splashColor: Colors.grey.withOpacity(0.7),
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                "Camera",
                                style: Get.textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        height: 0.0,
                        color: Color(0xa6545458),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Get.back();
                            File selectedImage = await pickImageFromGallery();
                            onSelectImage.call(selectedImage);
                          },
                          splashColor: Colors.grey.withOpacity(0.7),
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                "Gallery",
                                style: Get.textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    } else {
      await showCupertinoDialog(
          context: Get.context!,
          builder: (context) =>
              CupertinoAlertDialog(
                title: const Text("Choose Option"),
                content:
                const Text("Choose photo from gallery or Capture new ..."),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () async {
                      Get.back();
                      File selectedImage = await openCameraForImage();
                      onSelectImage.call(selectedImage);
                    },
                    child: const Text("Capture new photo"),
                  ),
                  CupertinoDialogAction(
                    onPressed: () async {
                      Get.back();
                      File selectedImage = await pickImageFromGallery();
                      onSelectImage.call(selectedImage);
                    },
                    child: const Text("Select from gallery"),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ));
    }
  }

  static Future<File> openCameraForImage() async {
    XFile? file = await (ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 30));
    return File(file!.path);
  }

  static Future<File> pickImageFromGallery() async {
    XFile? file = await (ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30));
    return File(file!.path);
  }
}
