import 'dart:async';

import 'package:visus_core_player/constants/local_storage_keys.dart';
import 'package:visus_core_player/extensions/local_storage_service_extensions.dart';
import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';
import 'package:visus_core_player/infrastructure/services/i_credentials_accessor.dart';

class CredentialsAccessor implements ICredentialsAccessor {
  final ILocalStorageService _localStorageService;
  bool _isDirty = false;
  bool _isLoaded = false;
  String? _email;
  String? _password;

  CredentialsAccessor(this._localStorageService);

  @override
  Future<String?> getEmail() async {
    await _ensureLoaded();

    return _email;
  }

  @override
  Future<void> setEmail(String value) =>
    _setValue(
      value,
      (value) => value == _email,
      (value) => _email = value,
    );

  @override
  Future<String?> getPassword() async {
    await _ensureLoaded();

    return _password;
  }

  @override
  Future<void> setPassword(String value) =>
    _setValue(
      value,
      (value) => value == _password,
      (value) => _password = value,
    );
  
  @override
  Future<bool> hasCredentials() async {
    await _ensureLoaded();

    return _email != null && _email!.isNotEmpty && _password != null && _password!.isNotEmpty;
  }

  @override
  Future<void> commit() async {
    if (!_isDirty) {
      return;
    }

    _email == null
        ? await _localStorageService.deleteIfExists(LocalStorageKeys.email)
        : await _localStorageService.set(LocalStorageKeys.email, _email!);
    _password == null
        ? await _localStorageService.deleteIfExists(LocalStorageKeys.password)
        : await _localStorageService.set(LocalStorageKeys.password, _password!);

    _isDirty = false;
  }

  @override
  Future<void> rollback() => _loadFromStorage();

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    await _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _email = await _localStorageService.get(LocalStorageKeys.email);
    _password = await _localStorageService.get(LocalStorageKeys.password);

    _isLoaded = true;
    _isDirty = false;
  }

  Future<void> _setValue(
      String? value,
      FutureOr<bool> Function(String?) comparer,
      FutureOr<void> Function(String?) setter) async {
    await _ensureLoaded();

    if (await comparer(value)) {
      return;
    }

    await setter(value);
    _isDirty = true;
  }
}