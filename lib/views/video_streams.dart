import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:visus_core_player/components/stream_image.dart';
import 'package:visus_core_player/constants/route_names.dart';
import 'package:visus_core_player/constants/ui.dart';
import 'package:visus_core_player/controllers/streams_controller.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/services/navigator_service.dart';

class VideoStreams extends StatefulWidget {
  const VideoStreams({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoStreamsState();
}

class _VideoStreamsState extends State<VideoStreams> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<StreamsController>(
              create: (context) => StreamsController(
                  context.read<IAuthenticationService>(),
                  context.read<IPlaybackStreamInfoService>())),
        ],
        builder: (context, child) {
          return Scaffold(
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
            FutureBuilder(
                future: context.read<StreamsController>().streams,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ResponsiveGridRow(
                      children: snapshot.data!.map((stream) {
                        return ResponsiveGridCol(
                            xs: 12,
                            sm: 12,
                            md: 12,
                            lg: 6,
                            xl: 6,
                            child: GestureDetector(
                                onTap: () {
                                  context.read<NavigatorService>().pushNamed(
                                      RouteNames.stream,
                                      arguments: stream.id);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(Ui.padding),
                                    child: Center(
                                        child: Stack(children: <Widget>[
                                      StreamImage(
                                          playbackImageService: context
                                              .read<IPlaybackImageService>(),
                                          streamId: stream.id,
                                          height: Ui.streamPreviewHeight,
                                          width: double.infinity),
                                      Container(
                                          alignment: Alignment.bottomCenter,
                                          height: Ui.streamPreviewHeight,
                                          child: SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                stream.name,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )))
                                    ])))));
                      }).toList(),
                    );
                  }

                  return const Center(
                    child: Text('No stream found.'),
                  );
                })
          ])));
        });
  }
}
