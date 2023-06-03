import 'package:visus_core_player/infrastructure/models/i_user_model.dart';
import 'package:visus_core_player/models/authentication_state.dart';

abstract class IAuthenticationService {
  Future<IUserModel?> register(String name, String email, String password);
  Future<IUserModel?> login();
  Future<void> logout();
  Stream<IUserModel?> get currentUser;
  Stream<AuthenticationState?> get currentState;
}