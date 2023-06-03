import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';

class LocalStorageService implements ILocalStorageService {
  final _storage = const FlutterSecureStorage();

  LocalStorageService();
  
  @override
  Future<String?> get(String key) => _storage.read(key: key);

  @override
  Future<void> set(String key, String value) => _storage.write(key: key, value: value);
  
  @override
  Future<bool> contains(String key) => _storage.containsKey(key: key);
  
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}