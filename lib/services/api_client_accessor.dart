import 'package:dio/dio.dart';
import 'package:visus_core_player/extensions/host_accessor_extensions.dart';
import 'package:visus_core_player/infrastructure/services/i_host_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_api_client_accessor.dart';
import 'package:visus_core_player/infrastructure/services/i_token_accessor.dart';

class ApiClientAccessor implements IApiClientAccessor {
  final ITokenAccessor _tokenAccessor;
  final IHostAccessor _hostAccessor;

  ApiClientAccessor(this._hostAccessor, this._tokenAccessor);

  @override
  Future<Dio> getClient() async {
    var dio = Dio(
      BaseOptions(
        baseUrl: await _hostAccessor.getApiBaseUrl(),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (await _tokenAccessor.containsToken()) {
            options.headers['Authorization'] = '${await _tokenAccessor.getTokenType()} ${await _tokenAccessor.getToken()}';
          }
          
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}