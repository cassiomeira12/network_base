import 'package:network_base/network_base.dart';
import 'package:network_base/src/exceptions/exception_model.dart';

class ExceptionBuilder {
  static ExceptionModel builderByStatus(
    int statusCode, {
    dynamic message,
  }) {
    switch (statusCode) {
      case 0:
      case 141:
        throw BaseNetworkException(code: statusCode, message: message);
      case 400:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Ops! Os dados informados estão incorretos.',
        );
      case 401:
        throw BaseNetworkException(code: statusCode, message: message);
      case 404:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Ops! endereço não encontrado',
        );
      case 500:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Ops! Ocorreu um erro no servidor.',
        );
      case 599:
        throw BaseNetworkException(
          code: statusCode,
          message:
              message ?? 'Ops! Não foi possível obter resposta do servidor.',
        );
      case 101:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Usuário ou senha incorretos!',
        );
      case 202:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Já existe um usuário com esse e-mail.',
        );
      case 209:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Sua sessão expirou!',
        );
      case 205:
        throw BaseNetworkException(
          code: statusCode,
          message: message ?? 'Seu e-mail ainda não foi verificado!',
        );
      default:
        throw BaseNetworkException(code: statusCode, message: message);
    }
  }
}
