import 'package:visus_core_player/constants/local_storage_keys.dart';
import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';
import 'package:visus_core_player/infrastructure/services/i_token_accessor.dart';

class TokenAccessor implements ITokenAccessor {
  final ILocalStorageService _localStorageService;

  TokenAccessor(this._localStorageService);

  @override
  Future<String> getToken() async {
    if (!await _localStorageService.contains(LocalStorageKeys.accessToken)) {
      throw Exception('Token not found');
    }

    return (await _localStorageService.get(LocalStorageKeys.accessToken))!;
  }

  @override
  Future<String> getTokenType() async {
    if (!await _localStorageService.contains(LocalStorageKeys.accessTokenType)) {
      throw Exception('Token type not found');
    }

    return (await _localStorageService.get(LocalStorageKeys.accessTokenType))!;
  }
  
  @override
  Future<bool> containsToken() async =>
    await _localStorageService.contains(LocalStorageKeys.accessToken)
    && await _localStorageService.contains(LocalStorageKeys.accessTokenType);
}