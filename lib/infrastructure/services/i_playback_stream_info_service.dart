import 'package:visus_core_player/models/playback/stream_info_model.dart';

abstract class IPlaybackStreamInfoService {
  Future<Iterable<StreamInfoModel>?> getStreams();
  Future<StreamInfoModel?> getStream(String id);
}
