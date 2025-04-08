import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/components/binary_choice.dart';
import 'package:quick_attendance/components/primary_button.dart';

class _GlowingController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController pulseController;
  final RxBool glow = true.obs;
  @override
  void onInit() {
    super.onInit();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  void toggleGlow() {
    glow.toggle();
    if (glow.value) {
      pulseController.repeat(reverse: true);
    } else {
      pulseController.stop();
    }
  }

  @override
  void onClose() {
    pulseController.dispose();
    super.onClose();
  }
}

/// A button that provides a subtle flashing dot on the left hand side
/// indicating some kind of alert to the user.
class AlertButton extends StatelessWidget {
  final _GlowingController _controller = Get.put(_GlowingController());
  final RxBool? isLoading;
  final RxBool? showAlert;
  final String text;
  void Function() onPressed;
  final double fontSize;

  AlertButton({
    super.key,
    this.isLoading,
    this.showAlert,
    required this.text,
    required this.onPressed,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller.pulseController,
            builder: (_, child) {
              final progress = _controller.pulseController.value;
              return Transform.scale(
                scale: 0.3 + 0.2 * progress,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3 + progress * 5,
                        spreadRadius: 1 + progress * 4,
                        color: Theme.of(context).colorScheme.inversePrimary
                            .withAlpha((255 + progress * -80).toInt()),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: fontSize)),
          Obx(
            () => BinaryChoice(
              choice: isLoading?.value == true,
              widget1: const SizedBox(width: 8),
            ),
          ),
          Obx(
            () => BinaryChoice(
              choice: isLoading?.value == true,
              widget1: SizedBox(
                width: fontSize * 0.9,
                height: fontSize * 0.9,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                  strokeWidth: fontSize / 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
