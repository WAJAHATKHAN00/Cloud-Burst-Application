import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'routes.dart';
import 'theme.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/location_permission_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/city_search_screen.dart';
import 'screens/alert_detail_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/help_support_screen.dart';
import 'services/device_service.dart';

class CloudBurstApp extends StatefulWidget {
  const CloudBurstApp({super.key});

  @override
  State<CloudBurstApp> createState() => _CloudBurstAppState();
}

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String deviceId = await DeviceService.getDeviceId();
  print("Device ID: $deviceId");
  runApp(const CloudBurstApp());
}

class _CloudBurstAppState extends State<CloudBurstApp> {
  final AppState _state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CloudBurst Alert',
        theme: AppTheme.light(),
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (_) => const SplashScreen(),
        /*For the time being Login and sign up screen are not connected.
          Routes.login: (_) => const LoginScreen(),
          Routes.signup: (_) => const SignupScreen(),
          Routes.forgotPassword: (_) => const ForgotPasswordScreen(),
         */
          Routes.locationPermission: (_) => const LocationPermissionScreen(),
          Routes.shell: (_) => const ShellScreen(),
          Routes.citySearch: (_) => const CitySearchScreen(),
          Routes.alertDetail: (_) => const AlertDetailScreen(),
          Routes.myReports: (_) => const MyReportsScreen(),
          Routes.about: (_) => const AboutAppScreen(),
          Routes.help: (_) => const HelpSupportScreen(),
        },
      ),
    );
  }
}
