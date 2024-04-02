import 'package:dio/dio.dart';

extension DioResponseExtension on Response {
  bool get isSuccess {
    final statusCode = this.statusCode ?? 0;
    return this.statusCode! >= 200 && statusCode < 300;
  }
}


