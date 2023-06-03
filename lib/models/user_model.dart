import '../infrastructure/models/i_user_model.dart';

class UserModel implements IUserModel {
  String _email;
  String _name;

  UserModel(this._email, this._name);

  @override
  String get email => _email;
  set email(String value) => _email = value;

  @override
  String get name => _name;
  set name(String value) => _name = value;
}