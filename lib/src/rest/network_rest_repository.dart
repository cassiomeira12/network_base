import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_base/src/exceptions/base_network_exception.dart';
import 'package:network_base/src/exceptions/exception_builder.dart';
import 'package:network_base/src/exceptions/exception_model.dart';
import 'package:network_base/src/token/refresh_token_interface.dart';
import 'package:network_base/src/token/token_interface.dart';
import 'package:pretty_json/pretty_json.dart';

import 'network_rest_interface.dart';

const int receiveTimeout = 45;
const int connectTimeout = 35;

class NetworkRestRepository implements NetworkRestInterface {
  String baseUrl;
  Map<String, String>? headers;

  final String? headerToken;
  final TokenInterface? tokenInterface;
  final RefreshTokenInterface? refreshTokenInterface;
  final bool showResponseData;

  NetworkRestRepository({
    this.baseUrl = '',
    this.headers,
    this.headerToken,
    this.tokenInterface,
    this.refreshTokenInterface,
    this.showResponseData = true,
  }) {
    if (tokenInterface != null) {
      assert(headerToken != null);
    }
    headers ??= <String, String>{};
  }

  Future<Dio> _instanceDio() async {
    var token = await tokenInterface?.getToken();
    Map<String, String> tempHeaders = Map.from(headers!);
    if (token != null) {
      tempHeaders.addAll({headerToken!: token});
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: connectTimeout).inMilliseconds,
        receiveTimeout: const Duration(seconds: receiveTimeout).inMilliseconds,
        contentType: 'application/json',
        headers: tempHeaders,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('-------------------------------------------');
            debugPrint('onRequest => [${options.method}] ${options.uri}');
            if (options.data != null) {
              debugPrint('DATA => ${options.data}');
            }
            if (options.queryParameters.isNotEmpty) {
              debugPrint('PARAMS => ${options.queryParameters}');
            }
            debugPrint('-------------------------------------------');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('-------------------------------------------');
            debugPrint(
                'onResponse => [${response.requestOptions.method}] ${response.requestOptions.uri}');
            debugPrint('STATUS CODE => ${response.statusCode}');
            if (showResponseData) {
              debugPrint('DATA =>');
              final pattern = RegExp('.{1,800}');
              pattern
                  .allMatches(prettyJson(response.data, indent: 2))
                  .forEach((match) => debugPrint(match.group(0)));
            }
            debugPrint('-------------------------------------------');
          }
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          if (kDebugMode) {
            debugPrint('-------------------------------------------');
            debugPrint(
                'onError => [${error.requestOptions.method}] ${error.requestOptions.uri}');
            debugPrint('STATUS CODE => ${error.response?.statusCode}');
            debugPrint('ERROR => ${error.response}');
            debugPrint('-------------------------------------------');
          }
          return handler.next(error);
        },
      ),
    );
    return dio;
  }

  @override
  Future<bool> refreshToken() async {
    return await refreshTokenInterface?.refreshToken() ?? false;
  }

  @override
  Future<Response> get(
    String url, {
    String? baseUrl,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  }) async {
    final dio = await _instanceDio();
    dio.options.headers.addAll(headers);

    if (contentType != null) {
      dio.options.contentType = contentType;
    }

    if (timeoutSeconds != null) {
      dio.options.receiveTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.connectTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.sendTimeout = Duration(seconds: timeoutSeconds).inSeconds;
    }

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    try {
      final response = await dio.get(url, queryParameters: queryParameters);
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return get(
            url,
            baseUrl: baseUrl,
            headers: headers,
            queryParameters: queryParameters,
            contentType: contentType,
            timeoutSeconds: timeoutSeconds,
          );
        } else {
          throw _buildException(error);
        }
      } else {
        throw _buildException(error);
      }
    } catch (error) {
      throw BaseNetworkException();
    }
  }

  @override
  Future<Response> post(
    String url, {
    data,
    String? baseUrl,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  }) async {
    final dio = await _instanceDio();
    dio.options.headers.addAll(headers);

    if (contentType != null) {
      dio.options.contentType = contentType;
    }

    if (timeoutSeconds != null) {
      dio.options.receiveTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.connectTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.sendTimeout = Duration(seconds: timeoutSeconds).inSeconds;
    }

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    try {
      final response = await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return post(
            url,
            data: data,
            baseUrl: baseUrl,
            headers: headers,
            queryParameters: queryParameters,
            contentType: contentType,
            timeoutSeconds: timeoutSeconds,
          );
        } else {
          throw _buildException(error);
        }
      } else {
        throw _buildException(error);
      }
    } catch (error) {
      throw BaseNetworkException();
    }
  }

  @override
  Future<Response> put(
    String url, {
    data,
    String? baseUrl,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  }) async {
    final dio = await _instanceDio();
    dio.options.headers.addAll(headers);

    if (contentType != null) {
      dio.options.contentType = contentType;
    }

    if (timeoutSeconds != null) {
      dio.options.receiveTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.connectTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.sendTimeout = Duration(seconds: timeoutSeconds).inSeconds;
    }

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return put(
            url,
            data: data,
            baseUrl: baseUrl,
            headers: headers,
            queryParameters: queryParameters,
            contentType: contentType,
            timeoutSeconds: timeoutSeconds,
          );
        } else {
          throw _buildException(error);
        }
      } else {
        throw _buildException(error);
      }
    } catch (error) {
      throw BaseNetworkException();
    }
  }

  @override
  Future<Response> delete(
    String url, {
    data,
    String? baseUrl,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
    int? timeoutSeconds,
  }) async {
    final dio = await _instanceDio();
    dio.options.headers.addAll(headers);

    if (contentType != null) {
      dio.options.contentType = contentType;
    }

    if (timeoutSeconds != null) {
      dio.options.receiveTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.connectTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.sendTimeout = Duration(seconds: timeoutSeconds).inSeconds;
    }

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return delete(
            url,
            data: data,
            baseUrl: baseUrl,
            headers: headers,
            queryParameters: queryParameters,
            contentType: contentType,
            timeoutSeconds: timeoutSeconds,
          );
        } else {
          throw _buildException(error);
        }
      } else {
        throw _buildException(error);
      }
    } catch (error) {
      throw BaseNetworkException();
    }
  }

  @override
  Future<Response> uploadFile(
    String url, {
    required Map<String, File> formData,
    String? baseUrl,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    int? timeoutSeconds,
  }) async {
    final dio = await _instanceDio();
    dio.options.headers.addAll(headers);

    if (timeoutSeconds != null) {
      dio.options.receiveTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.connectTimeout = Duration(seconds: timeoutSeconds).inSeconds;
      dio.options.sendTimeout = Duration(seconds: timeoutSeconds).inSeconds;
    }

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    try {
      final form = <String, MultipartFile>{};

      for (var entry in formData.entries) {
        final filename = entry.value.path.split('/').last;
        final file = MultipartFile(
          entry.value.openRead(),
          await entry.value.length(),
          filename: filename,
        );
        form[entry.key] = file;
      }

      final response = await dio.post(
        url,
        data: FormData.fromMap(form),
        options: Options(contentType: 'multipart/form-data'),
      );

      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return uploadFile(
            url,
            formData: formData,
            baseUrl: baseUrl,
            headers: headers,
            queryParameters: queryParameters,
            timeoutSeconds: timeoutSeconds,
          );
        } else {
          throw _buildException(error);
        }
      } else {
        throw _buildException(error);
      }
    } catch (error) {
      throw BaseNetworkException();
    }
  }

  ExceptionModel _buildException(DioError error) {
    if (error.response == null) {
      return BaseNetworkException(
        code: -1,
        message: 'Ops! Verifique sua conexão com a internet.',
      );
    }

    var statusCode = error.response!.statusCode;

    var body = error.response?.data;

    if (body == null) {
      throw ExceptionBuilder.builderByStatus(
        statusCode ?? 0,
        message: 'body is null',
      );
    }

    if (body.toString().contains('<html>')) {
      throw ExceptionBuilder.builderByStatus(
        statusCode ?? 0,
        message: body,
      );
    }

    if (body['code'] != null) {
      statusCode = body['code'];
    }

    String? errorType;
    String? messageError;

    try {
      dynamic json = error.response!.data;
      errorType = json['type'];
      switch (json['error'].runtimeType.toString()) {
        case 'String':
          messageError = json['error'];
          break;
        case '_InternalLinkedHashMap<String, dynamic>':
          messageError = json['error']['message'];
          break;
        case 'List':
          break;
        default:
      }
    } catch (error) {
      throw BaseNetworkException(
        code: statusCode ?? 0,
        message: 'Ops! Não foi possível obter resposta do servidor.',
      );
    }

    if (errorType != null) {
      switch (errorType) {
        case 'wrong_credentials_error':
          messageError = "Senha ou e-mail incorretos.";
          break;
        default:
      }
    }

    throw ExceptionBuilder.builderByStatus(
      statusCode ?? 0,
      message: error.response?.data ?? messageError,
    );
  }
}
