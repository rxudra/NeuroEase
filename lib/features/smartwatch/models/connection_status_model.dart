enum ConnectionStatus { connected, disconnected, connecting }

class ConnectionStatusModel {
  ConnectionStatusModel({this.status = ConnectionStatus.disconnected});

  ConnectionStatus status;
}
