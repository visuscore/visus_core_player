import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

class HubConnectionManager {
  final String _url;
  HubConnection? _hubConnection;
  Future<HubConnection>? _pendingCreateHubConnection;

  HubConnectionManager(this._url) {
    _hubConnection = HubConnectionBuilder()
        .withHubProtocol(MessagePackHubProtocol())
        .withUrl(_url)
        .withAutomaticReconnect()
        .build();
  }

  Future<HubConnection> createHubConnection() {
    return _pendingCreateHubConnection ??= Future(() async {
      if (_hubConnection!.state == HubConnectionState.Connected) {
        return _hubConnection!;
      }

      try {
        await _hubConnection!.start();
      } catch (e) {
        _pendingCreateHubConnection = null;

        rethrow;
      }

      return _hubConnection!;
    });
  }
}
