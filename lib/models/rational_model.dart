class RationalModel {
  late int numerator;
  late int denominator;

  static RationalModel? fromMap(Map<dynamic, dynamic>? value) {
    if (value == null) {
      return null;
    }

    RationalModel model = RationalModel();
    model.numerator = value['Numerator'];
    model.denominator = value['Denominator'];

    return model;
  }

  static Map<dynamic, dynamic>? toMap(RationalModel? model) {
    if (model == null) {
      return null;
    }

    var map = <dynamic, dynamic>{};
    map['Numerator'] = model.numerator;
    map['Denominator'] = model.denominator;

    return map;
  }
}
