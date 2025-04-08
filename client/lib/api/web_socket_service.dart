import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get/get.dart';

enum SocketConnectionState {
  notConnected,
  isConnecting,
  connected,
  failedToConnect,
  disconnected,
}

abstract class WebSocketService extends GetxService {
  late final io.Socket socket;

  final Rx<SocketConnectionState> socketConnectionState =
      SocketConnectionState.notConnected.obs;

  /// Builds default socket options such as timeout and reconnect attempts.
  /// Also adds socket listeners that manage the `socketConnectionState`.
  /// Add your own listeners by overriding `registerListeners`.
  void connectToServer({
    required String url,

    /// Override the default socket options
    io.OptionBuilder Function(io.OptionBuilder defaultOptions)? optionBuilder,
  }) {
    io.OptionBuilder socketOptions = io.OptionBuilder()
        .setTransports(["websocket"])
        .setReconnectionAttempts(3)
        .setReconnectionDelay(500)
        .disableAutoConnect() // we will connect manually after adding listeners
        .setTimeout(5000);
    if (optionBuilder != null) {
      socketOptions = optionBuilder(socketOptions);
    }
    socket = io.io(url, socketOptions.build());
    socket.onConnect((_) {
      socketConnectionState.value = SocketConnectionState.connected;
      Get.log("Websocket connected");
    });
    socket.onConnectError((err) {
      socketConnectionState.value = SocketConnectionState.failedToConnect;
      Get.log("Websocket failed to connect");
    });
    socket.onDisconnect((_) {
      socketConnectionState.value = SocketConnectionState.disconnected;
      Get.log("Websocket disconnected");
    });

    // Register listeners before connecting the socket incase we get immediate events
    registerListeners();
    socket.connect();
  }

  /// Add message listeners to the socket. This method is invoked before the socket
  /// attempts to connect. You can reference the socket in sub-classes using `socket`
  void registerListeners();

  // Example request
  void sendMessage({required String groupCode}) {
    socket.emit("joinGroup", {"groupCode": groupCode});
  }

  void disconnect() {
    socket.clearListeners();
    socket.disconnect();
  }
}
