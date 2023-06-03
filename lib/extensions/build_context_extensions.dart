import 'package:flutter/material.dart';

extension MediaQueryExtensions on BuildContext {
    EdgeInsetsGeometry get paddingAll => const EdgeInsets.all(20);
    EdgeInsetsGeometry get paddingBottom => const EdgeInsets.only(bottom: 20);
}