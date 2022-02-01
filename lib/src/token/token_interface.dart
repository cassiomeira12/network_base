abstract class TokenInterface {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> delete();
}
