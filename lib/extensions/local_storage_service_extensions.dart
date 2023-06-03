import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';

extension LocalStorageServiceExtension on ILocalStorageService {
  Future<void> deleteIfExists(String key) async {
    if (await contains(key)) {
      await delete(key);
    }
  }
}