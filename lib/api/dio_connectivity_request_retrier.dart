import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../controller/auth_controller.dart';

class DioConnectivityRequestRetrier {
  final Dio dio;
  final Connectivity connectivity;

  DioConnectivityRequestRetrier({
    required this.dio,
    required this.connectivity,
  });

  Future<Response> scheduleRequestRetry(RequestOptions requestOptions) async {
    StreamSubscription? streamSubscription;
    final responseCompleter = Completer<Response>();

    streamSubscription = connectivity.onConnectivityChanged.listen(
          (connectivityResult) async {
        if (connectivityResult != ConnectivityResult.none) {
          streamSubscription?.cancel();
          // Complete the completer instead of returning
          responseCompleter.complete(
            dio.request(
              requestOptions.path,
              cancelToken: requestOptions.cancelToken,
              data: requestOptions.data,
              onReceiveProgress: requestOptions.onReceiveProgress,
              onSendProgress: requestOptions.onSendProgress,
              queryParameters: requestOptions.queryParameters,
              options: Options(headers: requestOptions.headers, method: requestOptions.method, extra: requestOptions.extra),
            ),
          );
          debugPrint('ConnectedGetBack');
          Get.find<AuthController>().setIsDialogShow = true;
          Get.back();
        }
      },
    );

    return responseCompleter.future;
  }
}
