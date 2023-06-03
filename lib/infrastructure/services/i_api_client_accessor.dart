import 'package:dio/dio.dart';

abstract class IApiClientAccessor {
  Future<Dio> getClient();
}