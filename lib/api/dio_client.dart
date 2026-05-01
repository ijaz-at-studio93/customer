// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart' hide Response;
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:salon_customer/controller/auth_controller.dart';
// import '../constant/api_constant.dart';
// import '../util/SharedPrefs.dart';
// import 'dio_connectivity_request_retrier.dart';
// import 'dio_interceptors.dart';
// export 'package:salon_customer/util/Extensions.dart' show DioResponseExtension;
//
// class DioClient {
//   static CancelToken? cancelToken;
//   static Dio? _dio;
//
//   static Dio get client {
//     return Get.find<Dio>();
//   }
//
//   static init() {
//     if (_dio == null) {
//       _dio = Dio(BaseOptions(
//         baseUrl: APIConstants.baseUrl,
//         validateStatus: (status) {
//           return status! <= 500;
//         },
//         headers: {
//           'Accept': 'application/json',
//         },
//       ));
//
//       _dio!.interceptors.add(
//         PrettyDioLogger(
//           requestHeader: true,
//           requestBody: true,
//           responseBody: true,
//           responseHeader: false,
//           compact: false,
//         ),
//       );
//
//       _dio!.interceptors.add(
//         InterceptorsWrapper(onRequest:
//             (RequestOptions req, RequestInterceptorHandler handler) async {
//           String token = SharedPrefs.readStringValue(PrefConstants.token);
//           debugPrint("x-access-token $token");
//           debugPrint('DioClientPrint');
//           if (token.isNotEmpty) {
//             req.headers['x-access-token'] = token;
//           }
//           return handler.next(req);
//         }, onResponse:
//             (Response<dynamic> resp, ResponseInterceptorHandler handler) async {
//           try {
//             if (resp.statusCode == 401) {
//
//               final refreshToken = SharedPrefs.readStringValue(PrefConstants.refreshToken);
//
//               if (refreshToken.isEmpty) {
//                 // No refresh token saved → logout
//                 Get.find<AuthController>().resetApp();
//                 return handler.next(resp);
//               }
//
//               try {
//                 // Silently call refresh endpoint
//                 final refreshResponse = await _dio!.get(
//                   'auth/refresh',
//                   options: Options(
//                     headers: {'Authorization': 'Bearer $refreshToken'},
//                   ),
//                 );
//
//                 if (refreshResponse.statusCode == 200) {
//                   // Save new tokens
//                   final newAccessToken = refreshResponse.data['data']['accessToken'];
//                   final newRefreshToken = refreshResponse.data['data']['refreshToken'];
//
//                   await SharedPrefs.writeValue(PrefConstants.token, newAccessToken);
//                   await SharedPrefs.writeValue(PrefConstants.refreshToken, newRefreshToken);
//
//                   // Retry original failed request with new access token
//                   resp.requestOptions.headers['x-access-token'] = newAccessToken;
//                   final retryResponse = await _dio!.fetch(resp.requestOptions);
//                   return handler.resolve(retryResponse);
//
//                 } else {
//                   // Refresh failed → logout
//                   Get.find<AuthController>().resetApp();
//                 }
//
//               } catch (e) {
//                 // Refresh request itself failed → logout
//                 Get.find<AuthController>().resetApp();
//               }
//             }
//             if (resp.statusCode == 500 || resp.statusCode == 502) {
//               showMessage("Internal Server Error Bad Gateway");
//             }
//           } catch (e) {
//             return handler.next(resp);
//           }
//           return handler.next(resp);
//         },
//         //     onResponse:
//         //     (Response<dynamic> resp, ResponseInterceptorHandler handler) async {
//         //   try {
//         //     if (resp.statusCode == 401) {
//         //       Get.find<AuthController>().resetApp();
//         //     }
//         //     if (resp.statusCode == 500 || resp.statusCode == 502) {
//         //       showMessage("Internal Server Error Bad Gateway");
//         //     }
//         //   } catch (e) {
//         //     return handler.next(resp);
//         //   }
//         //   return handler.next(resp);
//         // },
//             onError:
//             (DioException error, ErrorInterceptorHandler handler) async {
//           return handler.next(error);
//         }),
//       );
//
//       _dio!.interceptors.add(RetryOnConnectionChangeInterceptor(
//         requestRetrier: DioConnectivityRequestRetrier(
//           dio: _dio!,
//           connectivity: Connectivity(),
//         ),
//       ));
//     }
//     Get.put(_dio!, permanent: true);
//   }
//
//   static Map<String, String> get headers {
//     String? token = SharedPrefs.readStringValue(PrefConstants.token);
//     if (token.isNotEmpty) {
//       return {'Authorization': 'Bearer $token'};
//     } else {
//       return {};
//     }
//   }
// }
//
// Future<void> showError(error) async {
//   String message = "Error";
//   try {
//     if (error is DioException) {
//       if (error.type == DioExceptionType.cancel) {
//         return;
//       } else {
//         message = "API Error";
//       }
//     } else if (error is PlatformException) {
//       message = "Platform Error";
//     } else if (error.containsKey('response') &&
//         error['response'] != null &&
//         error['response']['appointment'] != null) {
//       message = error['response']['appointment'];
//     } else {
//       message = error['message'];
//     }
//     showMessage(message);
//   } catch (e) {
//     showMessage(message);
//   }
// }
//
// Future<void> showMessage(String message, {int duration = 3}) async {
//   if (Get.context != null) {
//     Get.showSnackbar(GetSnackBar(
//       message: message.isEmpty ? "Error" : message,
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(12),
//       duration: Duration(seconds: duration),
//       borderRadius: 16,
//       backgroundColor: Colors.black87,
//     ));
//   }
// }

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import '../constant/api_constant.dart';
import '../util/SharedPrefs.dart';
import 'dio_connectivity_request_retrier.dart';
import 'dio_interceptors.dart';
export 'package:salon_customer/util/Extensions.dart' show DioResponseExtension;

class DioClient {
  static CancelToken? cancelToken;
  static Dio? _dio;

  // Separate Dio instance ONLY for refresh calls
  // This prevents infinite loop through the main interceptor
  static final Dio _refreshDio = Dio(BaseOptions(
    baseUrl: APIConstants.baseUrl,
    validateStatus: (status) => status! <= 500,
  ));

  static Dio get client {
    return Get.find<Dio>();
  }

  static init() {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: APIConstants.baseUrl,
        validateStatus: (status) {
          return status! <= 500;
        },
        headers: {
          'Accept': 'application/json',
        },
      ));

      _dio!.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (RequestOptions req, RequestInterceptorHandler handler) async {
            String token = SharedPrefs.readStringValue(PrefConstants.token);
            debugPrint("x-access-token $token");
            debugPrint('DioClientPrint');
            if (token.isNotEmpty) {
              req.headers['x-access-token'] = token;
            }
            return handler.next(req);
          },
          onResponse: (Response<dynamic> resp, ResponseInterceptorHandler handler) async {
            try {
              if (resp.statusCode == 401) {

                // ISSUE 2 FIX — Retry guard
                // If this request was already retried once, don't retry again → logout
                if (resp.requestOptions.extra['retried'] == true) {
                  Get.find<AuthController>().resetApp();
                  return handler.next(resp);
                }

                final refreshToken = SharedPrefs.readStringValue(PrefConstants.refreshToken);

                if (refreshToken.isEmpty) {
                  Get.find<AuthController>().resetApp();
                  return handler.next(resp);
                }

                try {
                  // ISSUE 1 FIX — Use separate Dio instance for refresh
                  // _refreshDio does NOT have the interceptor, so no infinite loop
                  final refreshResponse = await _refreshDio.get(
                    'auth/refresh',
                    options: Options(
                      headers: {'Authorization': 'Bearer $refreshToken'},
                    ),
                  );

                  if (refreshResponse.statusCode == 200) {
                    final newAccessToken = refreshResponse.data['data']['accessToken'];
                    final newRefreshToken = refreshResponse.data['data']['refreshToken'];

                    await SharedPrefs.writeValue(PrefConstants.token, newAccessToken);
                    await SharedPrefs.writeValue(PrefConstants.refreshToken, newRefreshToken);

                    // ISSUE 2 FIX — Mark this request as retried
                    // So if it fails again, we logout instead of looping
                    resp.requestOptions.extra['retried'] = true;
                    resp.requestOptions.headers['x-access-token'] = newAccessToken;

                    final retryResponse = await _dio!.fetch(resp.requestOptions);
                    return handler.resolve(retryResponse);

                  } else {
                    Get.find<AuthController>().resetApp();
                  }

                } catch (e) {
                  Get.find<AuthController>().resetApp();
                }
              }

              if (resp.statusCode == 500 || resp.statusCode == 502) {
                showMessage("Internal Server Error Bad Gateway");
              }

            } catch (e) {
              return handler.next(resp);
            }
            return handler.next(resp);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) async {
            return handler.next(error);
          },
        ),
      );

      _dio!.interceptors.add(RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: _dio!,
          connectivity: Connectivity(),
        ),
      ));
    }
    Get.put(_dio!, permanent: true);
  }

  static Map<String, String> get headers {
    String? token = SharedPrefs.readStringValue(PrefConstants.token);
    if (token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    } else {
      return {};
    }
  }
}

Future<void> showError(error) async {
  String message = "Error";
  try {
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        return;
      } else {
        message = "API Error";
      }
    } else if (error is PlatformException) {
      message = "Platform Error";
    } else if (error.containsKey('response') &&
        error['response'] != null &&
        error['response']['appointment'] != null) {
      message = error['response']['appointment'];
    } else {
      message = error['message'];
    }
    showMessage(message);
  } catch (e) {
    showMessage(message);
  }
}

void _presentSnackBar(String message, int duration) {
  Get.showSnackbar(GetSnackBar(
    message: message.isEmpty ? "Error" : message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    duration: Duration(seconds: duration),
    borderRadius: 16,
    backgroundColor: Colors.black87,
  ));
}

bool _hasNavigatorOverlay() {
  final ctx = Get.overlayContext;
  return ctx != null && Overlay.maybeOf(ctx) != null;
}

Future<void> showMessage(String message, {int duration = 3}) async {
  if (_hasNavigatorOverlay()) {
    _presentSnackBar(message, duration);
    return;
  }
  // APIs can complete before the first frame (e.g. splash); Get.snackbar needs Overlay.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (_hasNavigatorOverlay()) {
      _presentSnackBar(message, duration);
    } else {
      debugPrint('showMessage (no overlay yet): $message');
    }
  });
}