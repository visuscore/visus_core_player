import 'dart:async';

import 'package:openidconnect/openidconnect.dart';
import 'package:visus_core_player/constants/environment_defaults.dart';
import 'package:visus_core_player/constants/environment_keys.dart';
import 'package:visus_core_player/constants/local_storage_keys.dart';
import 'package:visus_core_player/extensions/host_accessor_extensions.dart';
import 'package:visus_core_player/extensions/local_storage_service_extensions.dart';
import 'package:visus_core_player/infrastructure/models/i_user_model.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/infrastructure/services/i_credentials_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_api_client_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';
import 'package:visus_core_player/models/authentication_state.dart';
import 'package:visus_core_player/models/e_authentication_state.dart';
import 'package:visus_core_player/models/user_model.dart';

class AuthenticationService implements IAuthenticationService {
  final ILocalStorageService _localStorageService;
  final IHostAccessor _hostAccessor;
  final ICredentialsAccessor _credentialsAccessor;
  final IApiClientAccessor _apiClientAccessor;
  final StreamController<IUserModel?> _currentUser = StreamController<IUserModel?>();
  final StreamController<AuthenticationState> _authenticationState = StreamController<AuthenticationState>();
  
  AuthenticationService(
    this._localStorageService,
    this._hostAccessor,
    this._credentialsAccessor,
    this._apiClientAccessor) {
    _currentUser.add(null);
    _authenticationState.add(AuthenticationState(EAuthenticationState.unauthenticated));
  }

  @override
  Stream<IUserModel?> get currentUser => _currentUser.stream;

  @override
  Stream<AuthenticationState?> get currentState => _authenticationState.stream;

  @override
  Future<IUserModel?> login() async {
    _authenticationState.add(AuthenticationState(EAuthenticationState.authenticating));

    try {
      if (! await _credentialsAccessor.hasCredentials()) {
        throw Exception('No credentials found');
      }

      var clientSecret = const String.fromEnvironment(EnvironmentKeys.openIdClientSecret);
      var authorizationResponse = await OpenIdConnect.authorizePassword(
        request: PasswordAuthorizationRequest(
          clientId: const String.fromEnvironment(
            EnvironmentKeys.openIdClientId,
            defaultValue: EnvironmentDefaults.openIdClientId
          ),
          scopes: const String.fromEnvironment(
            EnvironmentKeys.openIdScopes,
            defaultValue: EnvironmentDefaults.openIdScopes
          ).split(' '),
          clientSecret: clientSecret.isEmpty ? null : clientSecret,
          userName: (await _credentialsAccessor.getEmail())!,
          password: (await _credentialsAccessor.getPassword())!,
          configuration: await _hostAccessor.getOpenIdConfiguration(),
          autoRefresh: false,
        ),
      );

      await _localStorageService.set(LocalStorageKeys.accessToken, authorizationResponse.accessToken);
      await _localStorageService.set(LocalStorageKeys.accessTokenType, authorizationResponse.tokenType);

      _authenticationState.add(AuthenticationState(EAuthenticationState.authenticated));
    } catch (exception) {
      _authenticationState.add(AuthenticationState(EAuthenticationState.authenticationError, exception.toString()));

      await _cleanUp();

      rethrow;
    }

    return await _updateUserInfo();
  }

  @override
  Future<void> logout() async {
    try {
    await OpenIdConnect.logout(
      request: LogoutRequest(
        configuration: await _hostAccessor.getOpenIdConfiguration(),
        idToken: '',
      ),
    );
    } catch (_) {

    } finally {
      _authenticationState.add(AuthenticationState(EAuthenticationState.unauthenticated));

      await _cleanUp();
    }
  }

  @override
  Future<IUserModel?> register(String name, String email, String password) {
    // TODO: implement register
    throw UnimplementedError();
  }

  Future<IUserModel?> _updateUserInfo() async {
    var httpClient = await _apiClientAccessor.getClient();
    var response = await httpClient.get(await _hostAccessor.getOpenIdUserInfoEndpoint());

    var user = UserModel(response.data['email'], response.data['name']);
    _currentUser.add(user);

    return user;
  }

  Future<void> _cleanUp() async {
    await _localStorageService.deleteIfExists(LocalStorageKeys.accessToken);
    await _localStorageService.deleteIfExists(LocalStorageKeys.accessTokenType);
    _currentUser.add(null);
  }
}