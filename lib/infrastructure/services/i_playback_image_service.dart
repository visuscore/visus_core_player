import 'dart:typed_data';

import 'package:visus_core_player/models/playback/image/image_transformations_parameters_model.dart';
import 'package:visus_core_player/models/stream_details_model.dart';

abstract class IPlaybackImageService {
  Future<Uint8List> getLatestImage(
      String streamId, ImageTransformationsParametersModel? transformations);
  Future<Uint8List> getImage(String streamId, int timestampUtc, bool exact,
      ImageTransformationsParametersModel? transformations);
  Future<StreamDetailsModel?> getLatestSegmentDetails(String streamId);
  Future<StreamDetailsModel?> getSegmentDetails(
      String streamId, int timestampUtc);
}
