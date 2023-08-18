import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/models/e_authentication_state.dart';
import 'package:visus_core_player/models/playback/stream_info_model.dart';

import '../infrastructure/services/i_authentication_service.dart';

class StreamsController extends ChangeNotifier {
  final IAuthenticationService _authenticationService;
  final IPlaybackStreamInfoService _playbackStreamInfoService;
  StreamSubscription? _authenticationStateSubscription;
  Iterable<StreamInfoModel>? _streams;

  Future<Iterable<StreamInfoModel>?> get streams async {
    if (_streams == null) {
      await _updateStreams();
    }

    return _streams;
  }

  StreamsController(
      this._authenticationService, this._playbackStreamInfoService) {
    _authenticationStateSubscription =
        _authenticationService.currentState.listen((state) async {
      if (state?.state == EAuthenticationState.authenticated) {
        await _updateStreams();
      } else {
        _streams = null;
      }

      notifyListeners();
    });
  }

  Future<void> _updateStreams() async {
    _streams = await _playbackStreamInfoService.getStreams();
  }

  @override
  void dispose() async {
    await _authenticationStateSubscription?.cancel();

    super.dispose();
  }
}
