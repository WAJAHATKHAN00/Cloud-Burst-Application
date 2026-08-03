import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final state = AppStateScope.of(context);

    if (!state.locationGranted) {
      Navigator.pushReplacementNamed(context, Routes.locationPermission);
      return;
    }
    Navigator.pushReplacementNamed(context, Routes.shell);
  }

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon Mark
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 32,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // CLOUDBURST wordmark
              Text(
                'CLOUDBURST',
                style: AppTheme.microLabel(
                  fontSize: 22,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              // Micro-label
              Text(
                'PREDICTOR · FIELD MONITORING',
                style: AppTheme.microLabel(
                  fontSize: 10,
                  color: AppTheme.slate,
                ),
              ),
              const SizedBox(height: 40),
              // Status text
              Text(
                'INITIALIZING SENSORS…',
                style: AppTheme.microLabel(
                  fontSize: 10,
                  color: AppTheme.slate,
                ),
              ),
              const SizedBox(height: 6),
              // Flat calibration bar progress indicator
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.ink),
                    backgroundColor: AppTheme.divider,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
