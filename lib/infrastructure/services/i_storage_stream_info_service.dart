import 'package:visus_core_player/models/video_stream_info_meta_model.dart';

abstract class IStorageStreamInfoService {
  Future<Iterable<VideoStreamInfoMetaModel>?> getSegments(
      String id, int from, int to, int skip, int take);
}
