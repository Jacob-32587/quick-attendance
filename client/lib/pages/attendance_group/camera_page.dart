import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';

class _CameraPageController extends GetxController {
  final QuickAttendanceApi _api = Get.find();
  final RxSet<String> detectedBarcodes = RxSet();

  final String? groupId;

  _CameraPageController({required this.groupId});

  final MobileScannerController cameraController = MobileScannerController(
    autoStart: true,
    cameraResolution: Size(1920, 1080),
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.qrCode],
    detectionTimeoutMs: 250,
  );

  void _handleBarcode(BarcodeCapture barcodes) {
    List<String> scans = [];
    for (Barcode barcode in barcodes.barcodes) {
      String? content = barcode.displayValue;
      if (content == null) {
        continue;
      }
      var newId = detectedBarcodes.add(content);
      if (newId) {
        scans.add(content);
      }
    }
    if (scans.isNotEmpty) {
      _api.putAttendedUsers(groupId, scans);
    }
  }

  @override
  void onInit() {
    super.onInit();
    cameraController.start();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}

class CameraPage extends StatelessWidget {
  final String? groupId;
  late final _CameraPageController _controller = Get.put(
    _CameraPageController(groupId: groupId),
  );
  CameraPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller.cameraController,
              onDetect: _controller._handleBarcode,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 100,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Obx(() {
                      var detectedBarcodes = _controller.detectedBarcodes;
                      if (detectedBarcodes.isNotEmpty) {
                        return Text("${detectedBarcodes.length} codes");
                      }
                      return Text("Scan something!");
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
