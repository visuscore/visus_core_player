class VideoStreamInfoMetaModel {
  String streamId = '';
  int timestampUtc = 0;
  int duration = 0;
  int? timestampProvided;
  int frameCount = 0;

  static VideoStreamInfoMetaModel? fromMap(Map<dynamic, dynamic>? value) {
    if (value == null) {
      return null;
    }

    VideoStreamInfoMetaModel model = VideoStreamInfoMetaModel();
    model.streamId = value['StreamId'];
    model.timestampUtc = value['TimestampUtc'];
    model.duration = value['Duration'];
    model.timestampProvided = value['TimestampProvided'];
    model.frameCount = value['FrameCount'];

    return model;
  }

  static Map<dynamic, dynamic>? toMap(VideoStreamInfoMetaModel? model) {
    if (model == null) {
      return null;
    }

    var map = <dynamic, dynamic>{};
    map['StreamId'] = model.streamId;
    map['TimestampUtc'] = model.timestampUtc;
    map['Duration'] = model.duration;
    map['TimestampProvided'] = model.timestampProvided;
    map['FrameCount'] = model.frameCount;

    return map;
  }
}
