abstract class NetworkGrapqhQlInterface {
  Future<Map<String, dynamic>?> mutation({
    required String stringMutation,
    required Map<String, dynamic> variables,
  });
}
