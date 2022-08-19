import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:network_base/network_base.dart';
import 'package:network_base/src/exceptions/exception_builder.dart';

class NetworkGraphQlRepository implements NetworkGrapqhQlInterface {
  final String baseUrl;
  Map<String, String>? headers;

  final String? headerToken;
  final TokenInterface? tokenInterface;

  NetworkGraphQlRepository({
    required this.baseUrl,
    this.tokenInterface,
    this.headerToken,
    this.headers,
  }) {
    if (tokenInterface != null) {
      assert(headerToken != null);
    }
    headers ??= <String, String>{};
  }

  @override
  Future<Map<String, dynamic>?> mutation({
    required String stringMutation,
    required Map<String, dynamic> variables,
  }) async {
    var token = await tokenInterface?.getToken();
    if (token != null) headers![headerToken!] = token;
    final client = GraphQLClient(
      cache: GraphQLCache(),
      link: AuthLink(
        getToken: () async => token,
      ).concat(
        HttpLink(baseUrl, defaultHeaders: headers!),
      ),
    );
    final result = await client.mutate(
      MutationOptions(
        document: gql(stringMutation),
        variables: variables,
      ),
    );
    if (result.exception != null) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        for (var error in result.exception!.graphqlErrors) {
          debugPrint('Graphql error: ${error.message}');
        }
        throw BaseNetworkException(
          message: result.exception!.graphqlErrors.first.message,
        );
      } else {
        result.exception!.linkException;
        var exception = result.exception!.linkException;
        try {
          switch (result.exception!.linkException.runtimeType) {
            case ServerException:
              throw BaseNetworkException(
                message: 'Ops! Verifique sua conexão com a internet.',
              );
            case HttpLinkServerException:
              var server = (exception as HttpLinkServerException);
              ExceptionBuilder.builderByStatus(server.response.statusCode);
              break;
            default:
              throw BaseNetworkException();
          }
        } catch (error) {
          rethrow;
        }
      }
    }
    return result.data;
  }
}
