abstract class IStravaRepository{
  authenticate();
  exchangeCodeForTokens(String scope, String code);
  Future<String> getAccessToken();
  Map<String, dynamic> getTokens();
  replaceTokensOnExpiry();
  Future<String> getExpirationDate();
}