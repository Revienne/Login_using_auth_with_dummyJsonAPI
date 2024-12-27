import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_to_dashboard/dashboard_page.dart';
import 'package:login_to_dashboard/login_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Ensure GetStorage is initialized before the app starts.

  final box = GetStorage();
  final String? token = box.read('accessToken'); // Check if accessToken exists.

  runApp(MyApp(initialRoute: token != null ? '/dashboard' : '/login')); // Set initial route based on token.
}


class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage(); // Access GetStorage
    final String? token = box.read('accessToken'); // Check if token exists

    if (token == null && route == '/dashboard') {
      // Redirect to login if not logged in and trying to access dashboard
      return const RouteSettings(name: '/login');
    }

    return null; // Proceed to the intended route
  }
}


// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute}); // Pass initial route dynamically.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/login', page: () => Login()),
        GetPage(
          name: '/dashboard',
          page: () => Dashboard(),
          middlewares: [AuthMiddleware()], // Apply middleware here
        ),
      ],
      initialRoute: initialRoute, // Use the initial route passed to MyApp.
    );
  }
}