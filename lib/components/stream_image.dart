import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visus_core_player/helpers/period_stream.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/models/playback/image/image_transformations_parameters_model.dart';
import 'package:visus_core_player/models/stream_details_model.dart';

typedef ImageLoadedCallback = void Function(int? timestampUtc);
typedef ImageLoadErrorCallback = void Function(int? timestampUtc);

class StreamImage extends StatefulWidget {
  final IPlaybackImageService playbackImageService;
  final String streamId;
  final double? height;
  final double? width;
  final double? scale;
  final int? timestampUtc;
  final ImageLoadedCallback? onImageLoaded;
  final ImageLoadErrorCallback? onImageLoadError;
  final bool autoRefrest;

  const StreamImage(
      {required this.playbackImageService,
      required this.streamId,
      this.height,
      this.width,
      this.scale,
      this.timestampUtc,
      this.onImageLoaded,
      this.onImageLoadError,
      this.autoRefrest = true,
      super.key});

  @override
  State<StatefulWidget> createState() => _StreamImageState();
}

class _StreamImageState extends State<StreamImage> {
  final GlobalKey _imageKey = GlobalKey();
  bool _disposed = false;
  StreamSubscription? _periodicSubscription;
  Uint8List? _imageData;
  StreamDetailsModel? _streamDetails;

  @override
  void initState() {
    super.initState();

    if (widget.timestampUtc == null && widget.autoRefrest) {
      _startPeriodicUpdate();
    } else {
      _updateImage();
    }
  }

  @override
  void didUpdateWidget(StreamImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    var needUpdate = widget.timestampUtc != oldWidget.timestampUtc;
    needUpdate |= widget.scale != oldWidget.scale;

    if ((_periodicSubscription != null && widget.timestampUtc != null) ||
        !widget.autoRefrest) {
      _periodicSubscription?.cancel();
      _periodicSubscription = null;
    } else if (_periodicSubscription == null &&
        widget.timestampUtc == null &&
        widget.autoRefrest) {
      _startPeriodicUpdate();
    }

    if (needUpdate && widget.timestampUtc != null) {
      _updateImage();
    }
  }

  Future<void> _updateImage() async {
    _streamDetails ??= await widget.playbackImageService
        .getLatestSegmentDetails(widget.streamId);

    Size? size;
    try {
      final renderBox =
          _imageKey.currentContext?.findRenderObject() as RenderBox;
      size = renderBox.size;
    } catch (_) {
      stderr.writeln('Error getting size');
    }

    var scale = 0.1;
    if (size != null && _streamDetails?.height != null) {
      scale = size.height / _streamDetails!.height!;
    }

    var transformations = ImageTransformationsParametersModel()
      ..scale = scale * (widget.scale ?? 1)
      ..quality = 20;
    var start = DateTime.now().millisecondsSinceEpoch;
    try {
      _imageData = widget.timestampUtc == null
          ? await widget.playbackImageService
              .getLatestImage(widget.streamId, transformations)
          : await widget.playbackImageService.getImage(
              widget.streamId, widget.timestampUtc!, false, transformations);
      if (widget.onImageLoaded != null) {
        widget.onImageLoaded!(widget.timestampUtc);
      }
    } catch (_) {
      if (widget.onImageLoadError != null) {
        widget.onImageLoadError!(widget.timestampUtc);
      }
    }
    var end = DateTime.now().millisecondsSinceEpoch;
    stderr.writeln(
        'Image load time: ${end - start}, size: ${_imageData?.lengthInBytes}');

    if (mounted) {
      setState(() {});
    }
  }

  _startPeriodicUpdate() {
    _periodicSubscription =
        PeriodStream(const Duration(seconds: 1)).start().listen((event) async {
      if (_disposed || widget.timestampUtc != null) {
        return;
      }

      await _updateImage();
    });
  }

  Widget _buildImage() {
    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        fit: BoxFit.cover,
        height: widget.height,
        width: widget.width,
        gaplessPlayback: true,
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        key: _imageKey,
        height: widget.height,
        width: widget.width,
        child: _buildImage());
  }

  @override
  void dispose() async {
    _disposed = true;
    super.dispose();
    if (_periodicSubscription != null) {
      await _periodicSubscription!.cancel();
    }
  }
}
