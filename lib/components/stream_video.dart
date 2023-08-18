import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visus_core_player/components/stream_image.dart';
import 'package:visus_core_player/components/video_control.dart';
import 'package:visus_core_player/extensions/build_context_extensions.dart';
import 'package:visus_core_player/extensions/host_accessor_extensions.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_storage_stream_info_service.dart';
import 'package:visus_core_player/models/playback/stream_info_model.dart';
import 'package:visus_core_player/models/video_stream_info_meta_model.dart';

class StreamVideo extends StatefulWidget {
  final IHostAccessor hostAccessor;
  final IPlaybackImageService playbackImageService;
  final IPlaybackStreamInfoService playbackStreamInfoService;
  final IStorageStreamInfoService storageStreamInfoService;
  final String streamId;

  const StreamVideo(
      {required this.hostAccessor,
      required this.playbackImageService,
      required this.playbackStreamInfoService,
      required this.storageStreamInfoService,
      required this.streamId,
      super.key});

  @override
  State createState() => _StreamVideoState();
}

class _StreamVideoState extends State<StreamVideo> {
  late final player = Player();
  late final videoController = VideoController(player);
  final transformationTarget = GlobalKey();
  double _lastGestureScale = 1.0;
  Offset _lastDragOffset = Offset.zero;
  double _scale = 1.0;
  Offset _translate = Offset.zero;
  Matrix4 _transform = Matrix4.identity();
  Future<StreamInfoModel?>? _streamInfo;
  double _currentVideoControl = 0;
  VideoStreamInfoMetaModel? _firstSegment;
  bool _videoPlaying = false;
  bool _videoControl = false;
  bool _imageLoading = false;
  int? _currentTimestampUtc;
  int _lastStreamPosition = 0;

  _dragHandler(Offset localPosition) {
    final diff = (localPosition - _lastDragOffset) * _scale;
    final translate = _translate + diff;

    _translate = _consolidateTranslate(_scale, translate);
    _lastDragOffset = localPosition;

    _updateTransformation();
  }

  _wheelHandler(double dy, Offset localPosition) {
    final scale = max(min(_scale - dy * 0.001, 3), 1).toDouble();
    final translate = Offset(
        _translate.dx - localPosition.dx * (scale - _scale),
        _translate.dy - localPosition.dy * (scale - _scale));
    _translate = _consolidateTranslate(scale, translate);
    _scale = scale;

    _updateTransformation();
  }

  Offset _consolidateTranslate(double scale, Offset translate) {
    final originalSize = transformationTarget.currentContext!.size!;
    final scaledSize = originalSize * scale;
    consolidateDimension(
        double offset, double originalDimension, double scaledDimension) {
      return offset > 0
          ? 0
          : offset < (originalDimension - scaledDimension)
              ? (originalDimension - scaledDimension)
              : offset;
    }

    return Offset(
        consolidateDimension(translate.dx, originalSize.width, scaledSize.width)
            .toDouble(),
        consolidateDimension(
                translate.dy, originalSize.height, scaledSize.height)
            .toDouble());
  }

  _updateTransformation() {
    setState(() {
      _transform = Matrix4.identity()
        ..translate(_translate.dx, _translate.dy, 0.0)
        ..scale(_scale);
    });
  }

  @override
  void initState() {
    super.initState();

    _streamInfo = widget.playbackStreamInfoService.getStream(widget.streamId);
    _streamInfo?.then((value) async {
      await _playVideo();

      final segments = await widget.storageStreamInfoService.getSegments(
          widget.streamId, 0, DateTime.now().microsecondsSinceEpoch, 0, 1);
      if (segments != null && segments.isNotEmpty) {
        _firstSegment = segments.first;
      }
    });

    Stream.periodic(const Duration(milliseconds: 100)).listen((_) async {
      if (mounted) {
        if (_imageLoading) {
          return;
        }

        if (_currentVideoControl != 0 && _firstSegment != null) {
          final now = DateTime.now().microsecondsSinceEpoch;
          var currentTimestampUtc = _currentTimestampUtc ?? now;
          double easeInExpo(value) =>
              value == 0 ? 0 : pow(3, 10 * value - 10).toDouble();

          final diff = easeInExpo(_currentVideoControl.abs()) *
              86400000000 *
              _currentVideoControl.sign;
          currentTimestampUtc = currentTimestampUtc + diff.toInt();
          currentTimestampUtc =
              max(min(currentTimestampUtc, now), _firstSegment!.timestampUtc);
          if (_currentTimestampUtc != currentTimestampUtc) {
            player.stop();
            setState(() {
              _videoPlaying = false;
              _videoControl = true;
              _imageLoading = true;
              _currentTimestampUtc = currentTimestampUtc;
            });
          }
        } else if (_videoControl) {
          setState(() {
            _videoControl = false;
          });
        }
      }
    });

    player.stream.position.listen((position) {
      if (_videoPlaying) {
        final diff = position.inMicroseconds - _lastStreamPosition;
        _lastStreamPosition = position.inMicroseconds;

        if (_currentTimestampUtc != null) {
          _currentTimestampUtc = _currentTimestampUtc! + diff;
        }
      }
    });
  }

  _playVideo() async {
    var baseUrl = await widget.hostAccessor.getApiBaseUrl();

    var mediaUrl = _currentTimestampUtc != null
        ? '$baseUrl/playback/hls/${widget.streamId}/playback/playlist/$_currentTimestampUtc'
        : '$baseUrl/playback/hls/${widget.streamId}/live/playlist';
    player.open(Media(mediaUrl), play: false).then((value) async {
      await player.play();

      setState(() {
        _lastStreamPosition = 0;
        _videoPlaying = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _wheelHandler(event.scrollDelta.dy, event.localPosition);
          }
        },
        child: Stack(children: <Widget>[
          Transform(
              transform: _transform,
              child: GestureDetector(
                  onScaleStart: (details) {
                    _lastDragOffset = details.localFocalPoint;
                  },
                  onScaleUpdate: (details) {
                    if (details.scale == _lastGestureScale) {
                      _dragHandler(details.localFocalPoint);
                    } else {
                      _wheelHandler((details.scale - _lastGestureScale) * 100,
                          details.localFocalPoint);
                      _lastGestureScale = details.scale;
                    }
                  },
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_videoControl || !_videoPlaying || _imageLoading) {
                          return StreamImage(
                            playbackImageService: widget.playbackImageService,
                            streamId: widget.streamId,
                            height: double.infinity,
                            width: double.infinity,
                            scale: _scale,
                            timestampUtc: _currentTimestampUtc,
                            onImageLoaded: (_) {
                              _imageLoading = false;
                            },
                            onImageLoadError: (_) {
                              _imageLoading = false;
                            },
                            autoRefrest: _currentTimestampUtc == null,
                          );
                        }

                        return Video(
                          height: double.infinity,
                          width: double.infinity,
                          controller: videoController,
                          controls: null,
                          fit: BoxFit.cover,
                        );
                      },
                      key: transformationTarget))),
          Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: context.paddingAll,
                  child: VideoControl(
                    onChanged: (value) {
                      _currentVideoControl = value;
                    },
                    onDragTapped: () async {
                      if (_videoPlaying) {
                        await player.stop();
                        setState(() {
                          _videoPlaying = false;
                        });
                      } else {
                        await _playVideo();
                      }
                    },
                    onStartTapped: () async {
                      var playing = _videoPlaying;
                      setState(() {
                        _videoPlaying = false;
                        _currentTimestampUtc = _firstSegment?.timestampUtc;
                      });
                      if (playing) {
                        await _playVideo();
                      }
                    },
                    onEndTapped: () async {
                      var playing = _videoPlaying;
                      setState(() {
                        _videoPlaying = false;
                        _currentTimestampUtc = null;
                      });
                      if (playing) {
                        await _playVideo();
                      }
                    },
                    dragChild: Padding(
                        padding: const EdgeInsets.all(9),
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(100.0))),
                            child: Icon(
                                _videoPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Theme.of(context).primaryColor))),
                  ))),
        ]));
  }
}
