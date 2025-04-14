import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlowController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> blur;
  late final Animation<double> spread;
  late final Animation<Color?> color;

  @override
  void onInit() {
    super.onInit();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    blur = Tween<double>(
      begin: 8,
      end: 24,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    spread = Tween<double>(
      begin: 4,
      end: 8,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    color = ColorTween(
      begin: Colors.blue.shade600.withAlpha(125),
      end: Colors.blue.shade500.withAlpha(125),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}

class AnimatedGlowBox extends StatelessWidget {
  final Widget child;
  final GlowController _controller = Get.put(
    GlowController(),
    permanent: false,
  );

  AnimatedGlowBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _controller.color.value ?? Colors.black,
                blurRadius: _controller.blur.value,
                spreadRadius: _controller.spread.value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
