import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart' hide Response;

import '../controller/auth_controller.dart';
import 'dio_connectivity_request_retrier.dart';


class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;

  RetryOnConnectionChangeInterceptor({required this.requestRetrier});

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        Get.find<AuthController>().setShowProgress = false;

        if (Get.find<AuthController>().isDialogShow) {
          /*Get.to(() => const NoInternetConnection());*/
          /*Get.dialog(
            NoInternetConnectionDialog(callbackPosBtn: () {
              Get.find<AuthController>().setIsDialogShow = true;
              Get.back();
            }),
            barrierDismissible: false,
          );*/
          Get.find<AuthController>().setIsDialogShow = false;
        }
        Response response = await requestRetrier.scheduleRequestRetry(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        debugPrint(e.toString());
        debugPrint(e.runtimeType.toString());
        // Let any new error from the retrier pass through
        // return handler.resolve(e);
      }
    }
    // Let the error pass through if it's not the error we're looking for
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.unknown && err.error != null && err.error is SocketException;
  }
}
