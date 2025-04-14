import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/animation.dart';

class SuccessCheckController extends GetxController
    with GetTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    scale = Tween<double>(begin: 0.4, end: 1.0)
        .chain(CurveTween(curve: Interval(0, 0.7, curve: Curves.easeOutBack)))
        .animate(animationController);

    opacity = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Interval(0, 0.5, curve: Curves.ease)))
        .animate(animationController);

    // animationController.forward();
    animationController.repeat(reverse: true);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class AnimatedCheck extends StatelessWidget {
  final SuccessCheckController controller = Get.put(SuccessCheckController());

  AnimatedCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder:
          (_, child) => Opacity(
            opacity: controller.opacity.value,
            child: Transform.scale(scale: controller.scale.value, child: child),
          ),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 28),
      ),
    );
  }
}
