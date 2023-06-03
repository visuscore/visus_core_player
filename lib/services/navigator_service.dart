import 'package:flutter/material.dart';

class NavigatorService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushNamed(String routeName, {Object? arguments}) =>
    navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);

  Future<dynamic> pushNamedAndClearStack(String routeName, {Object? arguments}) =>
    navigatorKey.currentState!.pushNamedAndRemoveUntil(routeName, (_) => false, arguments: arguments);
}