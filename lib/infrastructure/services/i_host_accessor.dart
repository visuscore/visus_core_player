import 'package:visus_core_player/infrastructure/services/i_persistable.dart';

abstract class IHostAccessor extends IPersistable {
  Future<String?> getHost();
  Future<void> setHost(String value);
  Future<List<String>> getHosts();
}