import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:visus_core_player/constants/route_names.dart';
import 'package:visus_core_player/controllers/app_controller.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_storage_stream_info_service.dart';
import 'package:visus_core_player/services/navigator_service.dart';
import 'package:visus_core_player/views/login.dart';
import 'package:visus_core_player/views/splash.dart';
import 'package:visus_core_player/views/video_streams.dart';
import 'package:visus_core_player/views/video_stream.dart';

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
          create: (context) => AppController(
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
          RouteNames.streams: (context) => const VideoStreams(),
          RouteNames.stream: (context) {
            var streamId = ModalRoute.of(context)?.settings.arguments as String;

            return VideoStream(
                hostAccessor: context.read<IHostAccessor>(),
                playbackImageService: context.read<IPlaybackImageService>(),
                playbackStreamInfoService:
                    context.read<IPlaybackStreamInfoService>(),
                storageStreamInfoService:
                    context.read<IStorageStreamInfoService>(),
                streamId: streamId);
          },
        },
        builder: (context, child) => Overlay(
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
