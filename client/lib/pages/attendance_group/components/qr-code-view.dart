import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Displays a QR code that is 90% of the screen width and
/// has minimum error correction
class QrCodeView extends StatelessWidget {
  final String code;
  final double? size;

  const QrCodeView({super.key, required this.code, this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: QrImageView(
          data: code,
          version: QrVersions.auto,
          padding: EdgeInsets.all(8),
          backgroundColor: Colors.white,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          size: size,
          errorCorrectionLevel: QrErrorCorrectLevel.L, // minimum
        ),
      ),
    );
  }
}
