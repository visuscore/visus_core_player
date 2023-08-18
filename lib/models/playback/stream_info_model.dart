class StreamInfoModel {
  String id = '';
  String name = '';
  bool enabled = false;

  static StreamInfoModel? fromMap(Map<dynamic, dynamic>? value) {
    if (value == null) {
      return null;
    }

    StreamInfoModel model = StreamInfoModel();
    model.id = value['Id'];
    model.name = value['Name'];
    model.enabled = value['Enabled'];

    return model;
  }

  static Map<String, dynamic>? toMap(StreamInfoModel? model) {
    if (model == null) {
      return null;
    }

    var map = <String, dynamic>{};
    map['Id'] = model.id;
    map['Name'] = model.name;
    map['Enabled'] = model.enabled;

    return map;
  }
}
