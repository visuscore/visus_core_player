import 'package:visus_core_player/extensions/host_accessor_extensions.dart';
import 'package:visus_core_player/helpers/hub_connection_manager.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_token_accessor.dart';
import 'package:visus_core_player/models/playback/stream_info_model.dart';

class PlaybackStreamInfoService implements IPlaybackStreamInfoService {
  final IHostAccessor _hostAccessor;
  final ITokenAccessor _tokenAccessor;
  HubConnectionManager? _hubConnectionManager;

  PlaybackStreamInfoService(
    this._hostAccessor,
    this._tokenAccessor,
  );

  @override
  Future<Iterable<StreamInfoModel>?> getStreams() async {
    await _ensureHubConnection();

    var result = (await (await _hubConnectionManager!.createHubConnection())
        .invoke('GetStreamsAsync')) as List<dynamic>;

    return result.map((item) => StreamInfoModel.fromMap(item)!);
  }

  @override
  Future<StreamInfoModel?> getStream(String id) async {
    await _ensureHubConnection();

    var result = await (await _hubConnectionManager!.createHubConnection())
        .invoke('GetStreamAsync', args: [id]);

    return StreamInfoModel.fromMap(result as Map<dynamic, dynamic>);
  }

  Future<void> _ensureHubConnection() async {
    if (_hubConnectionManager != null) {
      return;
    }

    var baseUrl = await _hostAccessor.getApiBaseUrl();

    _hubConnectionManager =
        HubConnectionManager('$baseUrl/playback/stream-info');
  }
}
