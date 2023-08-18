import 'package:flutter/material.dart';
import 'package:visus_core_player/components/stream_video.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_storage_stream_info_service.dart';
import 'package:visus_core_player/models/playback/stream_info_model.dart';

class VideoStream extends StatefulWidget {
  final IHostAccessor hostAccessor;
  final IPlaybackImageService playbackImageService;
  final IPlaybackStreamInfoService playbackStreamInfoService;
  final IStorageStreamInfoService storageStreamInfoService;
  final String streamId;

  const VideoStream(
      {required this.hostAccessor,
      required this.playbackImageService,
      required this.playbackStreamInfoService,
      required this.storageStreamInfoService,
      required this.streamId,
      super.key});

  @override
  State createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  Future<StreamInfoModel?>? _streamInfo;

  @override
  void initState() {
    super.initState();

    _streamInfo = widget.playbackStreamInfoService.getStream(widget.streamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FutureBuilder(
              future: _streamInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!.name);
                }

                return const Text('');
              }),
        ),
        body: Center(
            child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(children: <Widget>[
            StreamVideo(
                hostAccessor: widget.hostAccessor,
                playbackImageService: widget.playbackImageService,
                playbackStreamInfoService: widget.playbackStreamInfoService,
                storageStreamInfoService: widget.storageStreamInfoService,
                streamId: widget.streamId)
          ]),
        )));
  }
}
