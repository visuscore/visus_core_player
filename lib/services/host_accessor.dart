import 'dart:async';

import 'package:visus_core_player/constants/local_storage_keys.dart';
import 'package:visus_core_player/extensions/list_extensions.dart';
import 'package:visus_core_player/extensions/local_storage_service_extensions.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';

class HostAccessor implements IHostAccessor {
  final ILocalStorageService _localStorageService;
  bool _isDirty = false;
  bool _isLoaded = false;
  String? _host;
  List<String> _hosts = <String>[];

  HostAccessor(this._localStorageService);

  @override
  Future<String?> getHost() async {
    await _ensureLoaded();

    return _host;
  }

  @override
  Future<void> setHost(String value) =>
    _setValue(
      value,
      (value) => value == _host,
      (value) =>_host = value,
    );
  
  @override
  Future<List<String>> getHosts() async {
    await _ensureLoaded();

    return _hosts.distinct();
  }

  @override
  Future<void> commit() async {
    if (!_isDirty) {
      return;
    }

    _host == null
        ? await _localStorageService.deleteIfExists(LocalStorageKeys.host)
        : await _localStorageService.set(LocalStorageKeys.host, _host!);

    if (_host != null && !_hosts.contains(_host)) {
      _hosts.add(_host!);
    }

    await _localStorageService.set(LocalStorageKeys.hosts, _hosts.distinct().join(','));
    
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
    _host = await _localStorageService.get(LocalStorageKeys.host);

    var hosts = await _localStorageService.get(LocalStorageKeys.hosts);
    _hosts = (hosts ?? '').split(',');

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
