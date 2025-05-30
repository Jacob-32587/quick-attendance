import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_attendance/api/quick_attendance_api.dart';
import 'package:quick_attendance/api/quick_attendance_websocket.dart';
import 'package:quick_attendance/controllers/auth_controller.dart';
import 'package:quick_attendance/controllers/history_controller.dart';
import 'package:quick_attendance/controllers/home_controller.dart';
import 'package:quick_attendance/controllers/profile_controller.dart';
import 'package:quick_attendance/pages/api_address.dart';
import 'package:quick_attendance/pages/attendance_group/camera_page.dart';
import 'package:quick_attendance/pages/attendance_group/group_page_auth.dart';
import 'package:quick_attendance/pages/auth/login.dart';
import 'package:quick_attendance/pages/auth/signup.dart';
import 'package:quick_attendance/pages/home/home.dart';

// Every flutter app starts with the main function.
void main() {
  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(HomeController());
  Get.put(QuickAttendanceApi());
  Get.put(QuickAttendanceWebsocket());
  Get.put(HistoryController());
  runApp(const MyApp());
}

// Everything on the screen is a widget.
// StatelessWidget is used for widgets with no data.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Every widget has a build method that describes the contents of the widget.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quick Attendance',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        // This is where you can configure the light theme of our application.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        // This is where you can configure the dark theme of our application
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => HomePage()),
        GetPage(name: "/signup/", page: () => Signup()),
        GetPage(name: "/login/", page: () => Login()),
        GetPage(name: "/group/:groupId/", page: () => GroupPageAuth()),
        GetPage(name: "/manual-address", page: () => ApiAddress()),
      ],
    );
  }
}
