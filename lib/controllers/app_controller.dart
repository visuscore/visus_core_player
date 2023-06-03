import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visus_core_player/constants/route_names.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/models/e_authentication_state.dart';
import 'package:visus_core_player/services/navigator_service.dart';

class AppController extends ChangeNotifier {
  final IAuthenticationService _authenticationService;
  final NavigatorService _navigatorService;
  StreamSubscription? _authenticationStateSubscription;
  bool _showLoader = false;

  AppController(this._authenticationService, this._navigatorService) {
    _authenticationStateSubscription = _authenticationService.currentState.listen((state) {
      if (state?.state == EAuthenticationState.unauthenticated) {
        _navigatorService.pushNamedAndClearStack(RouteNames.login);
      }

      _showLoader = state?.state == EAuthenticationState.authenticating;
      notifyListeners();
    });
  }

  get showLoader => _showLoader;

  @override
  void dispose() async {
    await _authenticationStateSubscription?.cancel();
    super.dispose();
  }
}