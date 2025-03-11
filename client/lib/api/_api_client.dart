import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';

class BaseApiClient extends GetConnect {
  late final AuthController _authController = Get.find();
  BaseApiClient(String baseUrl) {
    this.baseUrl = baseUrl;
    defaultContentType = "application/json";

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers["Authorization"] = "Bearer ${_authController.jwt.value}";
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      // TODO: Handle unauthorized (401) status codes navigating to login page.
      if (response.statusCode == 500) {
        Get.snackbar(
          "Request failed",
          "The server was unable to process the request. Please try again later.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
      return response;
    });
  }
}
