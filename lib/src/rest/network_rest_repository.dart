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

  NetworkRestRepository({
    this.baseUrl = '',
    this.headers,
    this.headerToken,
    this.tokenInterface,
    this.refreshTokenInterface,
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
            debugPrint('onRequest => ${options.path}');
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
            debugPrint('onResponse => ${response.requestOptions.path}');
            debugPrint('STATUS CODE => ${response.statusCode}');
            debugPrint('DATA =>');
            final pattern = RegExp('.{1,800}');
            pattern
                .allMatches(prettyJson(response.data, indent: 2))
                .forEach((match) => debugPrint(match.group(0)));
            debugPrint('-------------------------------------------');
          }
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          if (kDebugMode) {
            debugPrint('-------------------------------------------');
            debugPrint('onError => ${error.requestOptions.path}');
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
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    final dio = await _instanceDio();
    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: contentType == null
            ? null
            : Options(
                contentType: contentType,
              ),
      )
        ..requestOptions.headers.addAll(headers);
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return get(url, queryParameters: queryParameters);
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
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    final dio = await _instanceDio();
    try {
      final response = await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: contentType == null
            ? null
            : Options(
                contentType: contentType,
              ),
      )
        ..requestOptions.headers.addAll(headers);
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return get(url, queryParameters: queryParameters);
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
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    final dio = await _instanceDio();
    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: contentType == null
            ? null
            : Options(
                contentType: contentType,
              ),
      )
        ..requestOptions.headers.addAll(headers);
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return get(url, queryParameters: queryParameters);
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
    Map<String, dynamic> headers = const {},
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    final dio = await _instanceDio();
    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: contentType == null
            ? null
            : Options(
                contentType: contentType,
              ),
      )
        ..requestOptions.headers.addAll(headers);
      return response;
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        if (await refreshToken()) {
          return get(
            url,
            queryParameters: queryParameters,
            contentType: contentType,
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
      message: messageError,
    );
  }
}
