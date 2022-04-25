import 'dart:io';

import 'package:dio/dio.dart';

import '../token/refresh_token_interface.dart';

abstract class NetworkRestInterface with RefreshTokenInterface {
  Future<Response> get(
    String url, {
    String? baseUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  });

  Future<Response> post(
    String url, {
    data,
    String? baseUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  });

  Future<Response> put(
    String url, {
    data,
    String? baseUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  });

  Future<Response> delete(
    String url, {
    data,
    String? baseUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  });

  Future<Response> uploadFile(
    String url, {
    required Map<String, File> formData,
    String? baseUrl,
    Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
    int? timeoutSeconds,
  });
}
