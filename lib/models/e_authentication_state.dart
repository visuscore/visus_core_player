enum EAuthenticationState {
  /// [EAuthenticationState.unauthenticated] means that the user is not authenticated
  unauthenticated,

  /// [EAuthenticationState.authenticated] means that the user is authenticated
  authenticated,

  /// [EAuthenticationState.authenticating] means that the user is authenticating
  authenticating,

  /// [EAuthenticationState.authenticationError] means that the user authentication resulted in an error
  authenticationError,
}