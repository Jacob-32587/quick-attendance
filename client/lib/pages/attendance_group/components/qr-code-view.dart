import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Displays a QR code that is 90% of the screen width and
/// has minimum error correction
class QrCodeView extends StatelessWidget {
  final String code;

  const QrCodeView({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: code,
      version: QrVersions.auto,
      backgroundColor: Colors.white,
      size: MediaQuery.of(context).size.width * 0.9,
      errorCorrectionLevel: QrErrorCorrectLevel.L, // minimum
    );
  }
}
