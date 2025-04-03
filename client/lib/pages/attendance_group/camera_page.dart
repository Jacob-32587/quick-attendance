import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraPage extends StatelessWidget {
  final RxList<Barcode> detectedBarcodes = <Barcode>[].obs;

  final MobileScannerController controller = MobileScannerController(
    autoStart: true,
    cameraResolution: Size(1920, 1080),
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.qrCode],
    detectionTimeoutMs: 250,
  );

  CameraPage({super.key}) {}

  void _handleBarcode(BarcodeCapture barcodes) {
    for (Barcode barcode in barcodes.barcodes) {
      print(barcode.displayValue);
    }
    detectedBarcodes.value = barcodes.barcodes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed("/");
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(controller: controller, onDetect: _handleBarcode),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 100,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Obx(() {
                      if (detectedBarcodes.length > 0) {
                        return Text(
                          "${detectedBarcodes.length} codes" ?? "Unknown",
                        );
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
