import 'package:dio/dio.dart';

import '../token/refresh_token_interface.dart';

abstract class NetworkRestInterface with RefreshTokenInterface {
  Future<Response> get(
    String url, {
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  });

  Future<Response> post(
    String url, {
    data,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  });

  Future<Response> put(
    String url, {
    data,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  });

  Future<Response> delete(
    String url, {
    data,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  });
}
