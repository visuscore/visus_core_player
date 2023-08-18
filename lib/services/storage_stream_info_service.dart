import 'package:visus_core_player/extensions/host_accessor_extensions.dart';
import 'package:visus_core_player/helpers/hub_connection_manager.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_storage_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_token_accessor.dart';
import 'package:visus_core_player/models/video_stream_info_meta_model.dart';

class StorageStreamInfoService implements IStorageStreamInfoService {
  final IHostAccessor _hostAccessor;
  final ITokenAccessor _tokenAccessor;
  HubConnectionManager? _hubConnectionManager;

  StorageStreamInfoService(
    this._hostAccessor,
    this._tokenAccessor,
  );

  @override
  Future<Iterable<VideoStreamInfoMetaModel>?> getSegments(
      String id, int from, int to, int skip, int take) async {
    await _ensureHubConnection();

    var result = (await (await _hubConnectionManager!.createHubConnection())
            .invoke('GetSegmentsAsync', args: [id, from, to, skip, take]))
        as List<dynamic>;

    return result.map((item) =>
        VideoStreamInfoMetaModel.fromMap(item as Map<dynamic, dynamic>)!);
  }

  Future<void> _ensureHubConnection() async {
    if (_hubConnectionManager != null) {
      return;
    }

    var baseUrl = await _hostAccessor.getApiBaseUrl();

    _hubConnectionManager =
        HubConnectionManager('$baseUrl/storage/stream-info');
  }
}
