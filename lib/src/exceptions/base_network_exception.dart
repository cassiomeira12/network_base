import 'exception_model.dart';

class BaseNetworkException implements ExceptionModel, Exception {
  @override
  int code;

  @override
  dynamic message;

  BaseNetworkException({
    this.code = 0,
    this.message,
  }) {
    message ??= 'Ops! ocorreu um erro.';
  }

  @override
  String toString() {
    return message;
  }
}
