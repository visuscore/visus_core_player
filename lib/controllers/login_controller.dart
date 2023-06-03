import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/infrastructure/services/i_credentials_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';

class LoginController extends ChangeNotifier {
  final IAuthenticationService _authenticationService;
  final ICredentialsAccessor _credentialsAccessor;
  final IHostAccessor _hostAccessor;
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signInController = MaterialStatesController();
  final Loggy _loggy = Loggy('LoginController');
  bool _isPasswordVisible = false;
  Timer? _debounceTimer;

  LoginController(
    this._authenticationService,
    this._credentialsAccessor,
    this._hostAccessor) {
    _hostAccessor.rollback().then((value) async {
      _hostController.text = await _hostAccessor.getHost() ?? '';
    });

    _credentialsAccessor.rollback().then((value) async {
      _emailController.text = await _credentialsAccessor.getEmail() ?? '';
      _passwordController.text = await _credentialsAccessor.getPassword() ?? '';
    });

    _hostController.addListener(() {
      _hostAccessor.setHost(_hostController.text)
        .then((value) => notifyListeners());
    });

    _emailController.addListener(() {
      _credentialsAccessor.setEmail(_emailController.text)
        .then((value) => notifyListeners());
    });

    _passwordController.addListener(() {
      _credentialsAccessor.setPassword(_passwordController.text)
        .then((value) => notifyListeners());
    });
  }

  get isPasswordVisible => _isPasswordVisible;

  get formKey => _formKey;

  get hostController => _hostController;

  get emailController => _emailController;

  get passwordController => _passwordController;

  get signInController => _signInController;

  get isValid => (_formKey.currentState?.validate() ?? false);

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;

    notifyListeners();
  }

  Future<List<String>> filterHostList(String value) async {
    var hosts = await _hostAccessor.getHosts();

    var x = hosts.where(
      (element) => element.toLowerCase().contains(value))
      .toList();
    
    return x;
  }

  Future<void> login() async {
    try {
      await _authenticationService.login();

      await _credentialsAccessor.commit();
      await _hostAccessor.commit();
    } catch (exception, stackTrace) {
      _loggy.error('Login error', exception, stackTrace);
    }
  }

  @override
  void notifyListeners() {
    if (_debounceTimer?.isActive ?? false) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _debounceTimer?.cancel();

      _signInController.update(MaterialState.disabled, !isValid);

      super.notifyListeners();
    });
  }
}
