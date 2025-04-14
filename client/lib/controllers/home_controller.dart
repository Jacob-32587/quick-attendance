import 'package:get/get.dart';

const int initialHomePageIndex = 1;

/// Provides the state for navigating the home pages
class HomeController extends GetxController {
  // Start the user on the home page
  var currentIndex = initialHomePageIndex.obs;
}
