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

  void connectToServer({required String url}) {
    socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(["websocket"])
          .setReconnectionAttempts(3)
          .setReconnectionDelay(500)
          .setTimeout(5000)
          .build(),
    );
    socket.onConnect((_) {
      isConnected.value = true;
      isConnecting.value = false;
      hasAttemptedConnection.value = true;
      Get.log("Websocket connected");
    });
    socket.onConnectError((err) {
      isConnected.value = false;
      isConnecting.value = false;
      hasAttemptedConnection.value = true;
      Get.log("Websocket failed to connect");
    });
    socket.onDisconnect((_) {
      isConnected.value = false;
      isConnecting.value = false;
      hasAttemptedConnection.value = true;
      Get.log("Websocket disconnected");
    });

    // Register listeners before connecting the socket incase we get immediate events
    registerListeners();
    socket.connect();
  }

  /// Register listeners to the socket. This method is invoked before the socket
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
