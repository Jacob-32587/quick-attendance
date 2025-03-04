import 'package:flutter/material.dart';
import 'package:get/get.dart';

const int initialHomePageIndex = 2;

/// Provides the state for navigating the home pages
class HomeController extends GetxController {
  // Start the user on the home page
  var currentIndex = initialHomePageIndex.obs;

  @override
  void onClose() {
    super.onClose();
  }
}
