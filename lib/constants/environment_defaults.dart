class EnvironmentDefaults {
  static const String openIdClientId = 'net.visuscore.visus_core_player';
  static const String openIdScopes = 'mobile profile email';
  static const String openIdAuthorizationEndpoint = 'https://{}/connect/authorize';
  static const String openIdTokenEndpoint = 'https://{}/connect/token';
  static const String openIdUserInfoEndpoint = 'https://{}/connect/userinfo';
  static const String openIdLogoutEndpoint = 'https://{}/connect/logout';
  static const String openIdRevocationEndpoint = 'https://{}/connect/revoke';
  static const String apiBaseUrl = 'https://{}';
}