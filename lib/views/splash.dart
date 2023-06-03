import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visus_core_player/extensions/theme_extensions.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              height: 200,
            ),
            Text(
              'VisusCore',
              style: context.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}