import 'package:flutter/material.dart';
import '../app_state.dart';
import '../routes.dart';
import '../widgets/cloud_background.dart';

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

    // if (!state.loggedIn) {
    //   Navigator.pushReplacementNamed(context, Routes.login);
    //   return;
    // }
    if (!state.locationGranted) {
      Navigator.pushReplacementNamed(context, Routes.locationPermission);
      return;
    }
    Navigator.pushReplacementNamed(context, Routes.shell);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      spreadRadius: 2,
                      color: cs.primary.withOpacity(0.12),
                    ),
                  ],
                ),
                child: Icon(Icons.cloud_rounded, size: 52, color: cs.primary),
              ),
              const SizedBox(height: 14),
              Text(
                'CloudBurst Alert',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  backgroundColor: cs.primary.withOpacity(0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
