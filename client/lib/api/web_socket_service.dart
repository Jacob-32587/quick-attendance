import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get/get.dart';

abstract class WebSocketService extends GetxService {
  late final io.Socket socket;

  final RxBool isConnected = false.obs;

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
      Get.log("Websocket connected");
    });
    socket.onDisconnect((_) {
      isConnected.value = false;
      Get.log("Websocket disconnected");
    });

    // Register listeners before connecting the socket incase we get immediate events
    _registerListeners();
    socket.connect();
  }

  void _registerListeners();

  // Example request
  void sendMessage({required String groupCode}) {
    socket.emit("joinGroup", {"groupCode": groupCode});
  }

  void disconnect() {
    socket.clearListeners();
    socket.disconnect();
  }
}
