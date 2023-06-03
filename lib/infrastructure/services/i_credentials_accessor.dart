import 'package:visus_core_player/infrastructure/services/i_persistable.dart';

abstract class ICredentialsAccessor extends IPersistable {
  Future<String?> getEmail();
  Future<void> setEmail(String value);
  Future<String?> getPassword();
  Future<void> setPassword(String value);
  Future<bool> hasCredentials();
}