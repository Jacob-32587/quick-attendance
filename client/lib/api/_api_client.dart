import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
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

    httpClient.addResponseModifier((request, response) async {
      await Future.delayed(const Duration(seconds: 1));
      if (response.statusCode == 401 && Get.currentRoute != '/login') {
        Get.toNamed("/login");
        if (_authController.jwt.value == null) {
          Get.snackbar(
            "Unauthorized",
            "You must be logged in to do this",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        } else {
          Get.snackbar("Unauthorized", "You have been logged out");
        }
      } else if (response.statusCode == 500) {
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

/// A custom response class model that exposes only the necessary parts of GetxConnect's
/// response object. This model strongly types possible statusCodes, and was
/// created to allow for processing on the json body returned from the
/// api. JSON is not automatically deserialized into the generic type for the body
/// and fromJson() factory method(s) must be called manually in each apiClient method.
class ApiResponse<T> {
  final HttpStatusCode statusCode;
  final T? body;
  // This class model will evolve over time as use-cases increase

  ApiResponse({required this.statusCode, this.body});

  bool get isSuccess => statusCode == HttpStatusCode.ok;
}

enum HttpStatusCode {
  ok(200),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  conflict(409),
  internalServerError(500),
  unrecognizedResponseCode(-1);

  final int value;
  const HttpStatusCode(this.value);

  static HttpStatusCode from(int? code) {
    return HttpStatusCode.values.firstWhere(
      (e) => e.value == code,
      orElse: () => HttpStatusCode.unrecognizedResponseCode,
    );
  }
}
