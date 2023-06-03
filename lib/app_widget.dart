import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:visus_core_player/constants/route_names.dart';
import 'package:visus_core_player/controllers/app_controller.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/services/navigator_service.dart';
import 'package:visus_core_player/views/login.dart';
import 'package:visus_core_player/views/splash.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    var navigatorService = context.read<NavigatorService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              AppController(
                context.read<IAuthenticationService>(),
                navigatorService,
              ),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'VisusCore',
        initialRoute: RouteNames.home,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 54, 84, 117)),
          useMaterial3: true,
        ),
        navigatorKey: navigatorService.navigatorKey,
        routes: {
          RouteNames.home: (context) => const Splash(),
          RouteNames.login: (context) => const Login(),
        },
        builder: (context, child) =>
          Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) {
                  context.read<AppController>().addListener(() {
                    if (context.read<AppController>().showLoader) {
                      Loader.show(context);
                    } else {
                      Loader.hide();
                    }
                  });

                  return child!;
                },
              ),
            ],
          ),
      ),
    );
  }
}
