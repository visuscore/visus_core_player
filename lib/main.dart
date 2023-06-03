import 'package:flutter/material.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';
import 'package:visus_core_player/app_module.dart';

void main() {
  Loggy.initLoggy(
    logPrinter: const PrettyDeveloperPrinter(),
  );

  runApp(AppModule());
}
