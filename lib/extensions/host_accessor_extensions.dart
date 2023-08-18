import 'package:format/format.dart';
import 'package:openidconnect/openidconnect.dart';
import 'package:visus_core_player/constants/environment_defaults.dart';
import 'package:visus_core_player/constants/environment_keys.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';

extension HostServiceExtensions on IHostAccessor {
  Future<OpenIdConfiguration> getOpenIdConfiguration() async {
    return OpenIdConfiguration(
      authorizationEndpoint: const String.fromEnvironment(
        EnvironmentKeys.openIdAuthorizationEndpoint,
        defaultValue: EnvironmentDefaults.openIdAuthorizationEndpoint,
      ).format((await getHost())!),
      tokenEndpoint: const String.fromEnvironment(
        EnvironmentKeys.openIdTokenEndpoint,
        defaultValue: EnvironmentDefaults.openIdTokenEndpoint,
      ).format((await getHost())!),
      userInfoEndpoint: await getOpenIdUserInfoEndpoint(),
      revocationEndpoint: const String.fromEnvironment(
        EnvironmentKeys.openIdAuthorizationEndpoint,
        defaultValue: EnvironmentDefaults.openIdRevocationEndpoint,
      ).format((await getHost())!),
      endSessionEndpoint: const String.fromEnvironment(
        EnvironmentKeys.openIdLogoutEndpoint,
        defaultValue: EnvironmentDefaults.openIdLogoutEndpoint,
      ).format((await getHost())!),
      issuer: '',
      jwksUri: '',
      claimsSupported: [],
      grantTypesSupported: [],
      idTokenSigningAlgValuesSupported: [],
      scopesSupported: [],
      responseTypesSupported: [],
      subjectTypesSupported: [],
      responseModesSupported: [],
      tokenEndpointAuthMethodsSupported: [],
      codeChallengeMethodsSupported: [],
      requestUriParameterSupported: false,
      document: {},
    );
  }

  Future<String> getOpenIdUserInfoEndpoint() async =>
      const String.fromEnvironment(
        EnvironmentKeys.openIdUserInfoEndpoint,
        defaultValue: EnvironmentDefaults.openIdUserInfoEndpoint,
      ).format((await getHost())!);

  Future<String> getApiBaseUrl() async {
    return const String.fromEnvironment(
      EnvironmentKeys.apiBaseUrl,
      defaultValue: EnvironmentDefaults.apiBaseUrl,
    ).format((await getHost())!);
  }
}
