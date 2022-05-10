import 'exception_model.dart';

class AuthenticationException implements ExceptionModel, Exception {
  @override
  int code;

  @override
  dynamic message;

  AuthenticationException({
    this.code = 0,
    this.message = 'Sua sessão expirou!',
  });

  @override
  String toString() {
    return message;
  }
}
