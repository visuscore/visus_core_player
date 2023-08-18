import 'package:visus_core_player/models/e_media_type_model.dart';
import 'package:visus_core_player/models/rational_model.dart';

class StreamDetailsModel {
  int index = 0;
  EMediaTypeModel mediaType = EMediaTypeModel.unknown;
  String? codecName;
  String? codecLongName;
  String? profile;
  String? mediaTypeName;
  int? width;
  int? height;
  String? pixelFormatName;
  String? sampleFormatName;
  int? sampleRate;
  int? channels;
  RationalModel? frameRate;
  RationalModel? avgFrameRate;
  RationalModel? timeBase;
  int? bitRate;

  static StreamDetailsModel? fromMap(Map<dynamic, dynamic>? value) {
    if (value == null) {
      return null;
    }

    StreamDetailsModel model = StreamDetailsModel();
    model.index = value['Index'];
    model.mediaType = EMediaTypeModel.values.firstWhere((element) =>
        element.name.toLowerCase() ==
        value['MediaType']?.toString().toLowerCase());
    model.codecName = value['CodecName'];
    model.codecLongName = value['CodecLongName'];
    model.profile = value['Profile'];
    model.mediaTypeName = value['MediaTypeName'];
    model.width = value['Width'];
    model.height = value['Height'];
    model.pixelFormatName = value['PixelFormatName'];
    model.sampleFormatName = value['SampleFormatName'];
    model.sampleRate = value['SampleRate'];
    model.channels = value['Channels'];
    model.frameRate = RationalModel.fromMap(value['FrameRate']);
    model.avgFrameRate = RationalModel.fromMap(value['AvgFrameRate']);
    model.timeBase = RationalModel.fromMap(value['TimeBase']);
    model.bitRate = value['SampleRate'];

    return model;
  }

  static Map<dynamic, dynamic>? toMap(StreamDetailsModel? model) {
    if (model == null) {
      return null;
    }

    var map = <dynamic, dynamic>{};
    map['Index'] = model.index;
    map['MediaType'] = model.mediaType.index;
    map['CodecName'] = model.codecName;
    map['CodecLongName'] = model.codecLongName;
    map['Profile'] = model.profile;
    map['MediaTypeName'] = model.mediaTypeName;
    map['Width'] = model.width;
    map['Height'] = model.height;
    map['PixelFormatName'] = model.pixelFormatName;
    map['SampleFormatName'] = model.sampleFormatName;
    map['SampleRate'] = model.sampleRate;
    map['Channels'] = model.channels;
    map['FrameRate'] = RationalModel.toMap(model.frameRate);
    map['AvgFrameRate'] = RationalModel.toMap(model.avgFrameRate);
    map['TimeBase'] = RationalModel.toMap(model.timeBase);
    map['BitRate'] = model.bitRate;

    return map;
  }
}
