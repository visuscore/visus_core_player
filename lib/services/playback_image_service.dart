import 'dart:typed_data';

import 'package:visus_core_player/extensions/host_accessor_extensions.dart';
import 'package:visus_core_player/helpers/hub_connection_manager.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/infrastructure/services/i_token_accessor.dart';
import 'package:visus_core_player/models/playback/image/image_transformations_parameters_model.dart';
import 'package:visus_core_player/models/stream_details_model.dart';

class PlaybackImageService implements IPlaybackImageService {
  final IHostAccessor _hostAccessor;
  final ITokenAccessor _tokenAccessor;
  HubConnectionManager? _hubConnectionManager;

  PlaybackImageService(
    this._hostAccessor,
    this._tokenAccessor,
  );

  @override
  Future<Uint8List> getLatestImage(String streamId,
      ImageTransformationsParametersModel? transformations) async {
    await _ensureHubConnection();

    return (await (await _hubConnectionManager!.createHubConnection())
        .invoke('GetLatestImageAsync', args: [
      streamId,
      (transformations == null
              ? null
              : ImageTransformationsParametersModel.toMap(transformations))
          as Object
    ])) as Uint8List;
  }

  @override
  Future<Uint8List> getImage(String streamId, int timestampUtc, bool exact,
      ImageTransformationsParametersModel? transformations) async {
    await _ensureHubConnection();

    return (await (await _hubConnectionManager!.createHubConnection())
        .invoke('GetImageAsync', args: [
      streamId,
      timestampUtc,
      exact,
      (transformations == null
              ? null
              : ImageTransformationsParametersModel.toMap(transformations))
          as Object
    ])) as Uint8List;
  }

  @override
  Future<StreamDetailsModel?> getLatestSegmentDetails(String streamId) async {
    await _ensureHubConnection();

    return StreamDetailsModel.fromMap(
        (await (await _hubConnectionManager!.createHubConnection())
            .invoke('GetLatestSegmentDetailsAsync', args: [
      streamId,
    ])) as Map<dynamic, dynamic>);
  }

  @override
  Future<StreamDetailsModel?> getSegmentDetails(
      String streamId, int timestampUtc) async {
    await _ensureHubConnection();

    return StreamDetailsModel.fromMap((await (await _hubConnectionManager!
                .createHubConnection())
            .invoke('GetSegentDetailsAsync', args: [streamId, timestampUtc]))
        as Map<dynamic, dynamic>);
  }

  Future<void> _ensureHubConnection() async {
    if (_hubConnectionManager != null) {
      return;
    }

    var baseUrl = await _hostAccessor.getApiBaseUrl();

    _hubConnectionManager = HubConnectionManager('$baseUrl/playback/image');
  }
}
