import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/features/about/presentation/about_app_screen.dart';
import 'package:cloud_burst/features/alerts/presentation/alert_detail_screen.dart';
import 'package:cloud_burst/features/help/presentation/help_support_screen.dart';
import 'package:cloud_burst/features/location/presentation/city_search_screen.dart';
import 'package:cloud_burst/features/location/presentation/location_permission_screen.dart';
import 'package:cloud_burst/features/reports/presentation/my_reports_screen.dart';
import 'package:cloud_burst/features/shell/presentation/shell_screen.dart';
import 'package:cloud_burst/features/splash/presentation/splash_screen.dart';

class CloudBurstApp extends StatefulWidget {
  const CloudBurstApp({super.key});

  @override
  State<CloudBurstApp> createState() => _CloudBurstAppState();
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
          /* For the time being Login and sign up screen are not connected.
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
