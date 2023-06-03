import 'package:visus_core_player/models/e_authentication_state.dart';

class AuthenticationState {
  final EAuthenticationState state;
  final String? errorMessage;

  AuthenticationState(this.state, [this.errorMessage]);
}