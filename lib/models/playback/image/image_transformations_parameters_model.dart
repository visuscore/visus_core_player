class ImageTransformationsParametersModel {
  double? scale;
  double? cropLeft;
  double? cropTop;
  double? cropRight;
  double? cropBottom;
  int? quality;

  static ImageTransformationsParametersModel? fromMap(
      Map<dynamic, dynamic>? value) {
    if (value == null) {
      return null;
    }

    ImageTransformationsParametersModel model =
        ImageTransformationsParametersModel();
    model.scale = value['Scale'];
    model.cropLeft = value['CropLeft'];
    model.cropTop = value['CropTop'];
    model.cropRight = value['CropRight'];
    model.cropBottom = value['CropBottom'];
    model.quality = value['Quality'];

    return model;
  }

  static Map<dynamic, dynamic>? toMap(
      ImageTransformationsParametersModel? model) {
    if (model == null) {
      return null;
    }

    var map = <dynamic, dynamic>{};
    map['Scale'] = model.scale;
    map['CropLeft'] = model.cropLeft;
    map['CropTop'] = model.cropTop;
    map['CropRight'] = model.cropRight;
    map['CropBottom'] = model.cropBottom;
    map['Quality'] = model.quality;

    return map;
  }
}
