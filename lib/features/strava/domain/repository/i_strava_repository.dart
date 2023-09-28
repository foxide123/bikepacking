abstract class IStravaRepository{
  authenticate();
  exchangeCodeForTokens(String scope, String code);
  getProfile();
  getRoutes(int id);
  downloadRoute(int id, String routeName);
  Future<String> getAccessToken();
  replaceTokensOnExpiry();
  Future<String> getExpirationDate();
}