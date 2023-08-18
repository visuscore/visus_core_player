import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visus_core_player/app_widget.dart';
import 'package:visus_core_player/infrastructure/services/i_authentication_service.dart';
import 'package:visus_core_player/infrastructure/services/i_credentials_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_api_client_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_local_storage_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_image_service.dart';
import 'package:visus_core_player/infrastructure/services/i_playback_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_storage_stream_info_service.dart';
import 'package:visus_core_player/infrastructure/services/i_token_accessor.dart';
import 'package:visus_core_player/services/authentication_service.dart';
import 'package:visus_core_player/services/credentials_accessor.dart';
import 'package:visus_core_player/services/host_accessor.dart';
import 'package:visus_core_player/services/api_client_accessor.dart';
import 'package:visus_core_player/services/local_storage_service.dart';
import 'package:visus_core_player/services/navigator_service.dart';
import 'package:visus_core_player/services/playback_image_service.dart';
import 'package:visus_core_player/services/playback_stream_info_service.dart';
import 'package:visus_core_player/services/storage_stream_info_service.dart';
import 'package:visus_core_player/services/token_accessor.dart';

class AppModule extends StatelessWidget {
  final _navigatorService = NavigatorService();

  AppModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigatorService>(create: (context) => _navigatorService),
        Provider<ILocalStorageService>(create: (_) => LocalStorageService()),
        Provider<IHostAccessor>(
            create: (context) =>
                HostAccessor(context.read<ILocalStorageService>())),
        Provider<ICredentialsAccessor>(
            create: (context) =>
                CredentialsAccessor(context.read<ILocalStorageService>())),
        Provider<ITokenAccessor>(
            create: (context) =>
                TokenAccessor(context.read<ILocalStorageService>())),
        Provider<IApiClientAccessor>(
            create: (context) => ApiClientAccessor(
                context.read<IHostAccessor>(), context.read<ITokenAccessor>())),
        Provider<IAuthenticationService>(
            create: (context) => AuthenticationService(
                context.read<ILocalStorageService>(),
                context.read<IHostAccessor>(),
                context.read<ICredentialsAccessor>(),
                context.read<IApiClientAccessor>())),
        Provider<IPlaybackStreamInfoService>(
            create: (context) => PlaybackStreamInfoService(
                context.read<IHostAccessor>(), context.read<ITokenAccessor>())),
        Provider<IPlaybackImageService>(
            create: (context) => PlaybackImageService(
                context.read<IHostAccessor>(), context.read<ITokenAccessor>())),
        Provider<IStorageStreamInfoService>(
            create: (context) => StorageStreamInfoService(
                context.read<IHostAccessor>(), context.read<ITokenAccessor>())),
      ],
      child: const AppWidget(),
    );
  }
}
