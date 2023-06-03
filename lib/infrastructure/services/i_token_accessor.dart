abstract class ITokenAccessor {
  Future<bool> containsToken();
  Future<String> getToken();
  Future<String> getTokenType();
}