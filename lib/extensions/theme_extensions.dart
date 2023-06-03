import 'package:flutter/material.dart';

extension ThemesExtensions on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get primaryColorLight => Theme.of(this).primaryColorLight;
  Color get highlightColor => Theme.of(this).highlightColor;
  Color get hintColor => Theme.of(this).hintColor;
  Color get cardColor => Theme.of(this).cardColor;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
