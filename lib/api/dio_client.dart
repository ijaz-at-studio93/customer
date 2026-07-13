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

import 'dart:async';

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
import 'auth_api.dart';
import 'dio_connectivity_request_retrier.dart';
import 'dio_interceptors.dart';
export 'package:salon_customer/util/Extensions.dart' show DioResponseExtension;

class DioClient {
  static CancelToken? cancelToken;
  static Dio? _dio;

  static bool _isRefreshing = false;
  static Completer<TokenRefreshOutcome>? _refreshCompleter;
  static bool _isLoggingOut = false;

  static Dio get client {
    return Get.find<Dio>();
  }

  /// Logs the user out exactly once per dead session. Guarded so concurrent
  /// 401s (or a later request that 401s after teardown began) can't stack up
  /// multiple [AuthController.resetApp] calls and navigation storms. The guard
  /// is released by [markSessionActive] when a new session is established.
  static void _forceLogout() {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    Get.find<AuthController>().resetApp();
  }

  /// Called when a fresh session is persisted (login / signup / refresh) so a
  /// future genuine expiry is able to log the user out again.
  static void markSessionActive() {
    _isLoggingOut = false;
  }

  static init() {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: APIConstants.baseUrl,
        // Only 2xx goes to onResponse — 401/403 properly routes to onError
        validateStatus: (status) {
          return status != null && status < 300;
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
          error: true,
          compact: false,
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          /// ---------------------------
          /// REQUEST — attach token
          /// ---------------------------
          onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
            if (options.extra['skipAuth'] == true) {
              return handler.next(options);
            }
            String token = SharedPrefs.readStringValue(PrefConstants.token);
            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              options.headers['x-access-token'] = token;
            }
            return handler.next(options);
          },

          /// ---------------------------
          /// RESPONSE — server-side errors only
          /// ---------------------------
          onResponse: (Response<dynamic> resp, ResponseInterceptorHandler handler) {
            if (resp.statusCode == 500) {
              showMessage("Please wait, server under maintenance");
            }
            return handler.next(resp);
          },

          /// ---------------------------
          /// ERROR — token refresh flow
          /// ---------------------------
          onError: (DioException error, ErrorInterceptorHandler handler) async {
            final int? statusCode = error.response?.statusCode;

            if (statusCode != 401 && statusCode != 403) {
              return handler.next(error);
            }

            final RequestOptions requestOptions = error.requestOptions;

            // The refresh call itself must never re-enter this logic (deadlock),
            // and a request that already retried once must not loop forever.
            if (requestOptions.extra['isRefreshCall'] == true ||
                requestOptions.extra['retried'] == true) {
              return handler.next(error);
            }

            // ---- Single-flight refresh --------------------------------------
            // The first 401 owns the refresh; concurrent 401s await its outcome
            // instead of each firing their own refresh (and their own logout).
            final bool isOwner = !_isRefreshing;
            final Completer<TokenRefreshOutcome> completer;

            if (isOwner) {
              _isRefreshing = true;
              _refreshCompleter = Completer<TokenRefreshOutcome>();
              completer = _refreshCompleter!;
              try {
                completer.complete(await AuthAPI.refreshAccessToken());
              } catch (_) {
                completer.complete(TokenRefreshOutcome.transientFailure);
              } finally {
                _isRefreshing = false;
                _refreshCompleter = null;
              }
            } else {
              // Capture synchronously — guaranteed non-null while refreshing.
              completer = _refreshCompleter!;
            }

            TokenRefreshOutcome outcome;
            try {
              outcome = await completer.future.timeout(
                const Duration(seconds: 15),
                onTimeout: () => TokenRefreshOutcome.transientFailure,
              );
            } catch (_) {
              outcome = TokenRefreshOutcome.transientFailure;
            }

            switch (outcome) {
              case TokenRefreshOutcome.success:
                final String newToken =
                    SharedPrefs.readStringValue(PrefConstants.token);
                requestOptions.headers['Authorization'] = 'Bearer $newToken';
                requestOptions.headers['x-access-token'] = newToken;
                requestOptions.extra['retried'] = true;
                try {
                  final Response retryResponse =
                      await _dio!.fetch(requestOptions);
                  return handler.resolve(retryResponse);
                } on DioException catch (retryError) {
                  return handler.next(retryError);
                }

              case TokenRefreshOutcome.sessionExpired:
                // Session is genuinely dead. Only the refresh owner tears down
                // the app so concurrent 401s don't trigger multiple logouts.
                if (isOwner) {
                  _forceLogout();
                }
                return handler.next(error);

              case TokenRefreshOutcome.transientFailure:
                // Network/server blip — keep the session, just fail this call.
                return handler.next(error);
            }
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