import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';
import 'package:cloud_burst/shared/widgets/primary_button.dart';
import 'package:cloud_burst/shared/widgets/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _loginAndGoNext() {
    final state = AppStateScope.of(context);
    state.login();
    Navigator.pushReplacementNamed(context, Routes.locationPermission);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 30,
                        spreadRadius: 2,
                        color: cs.primary.withOpacity(0.12),
                      ),
                    ],
                  ),
                  child: Icon(Icons.cloud_rounded, size: 44, color: cs.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log in to get real-time cloudburst alerts.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PrimaryButton(
                          label: 'Continue with Google',
                          icon: Icons.g_mobiledata_rounded,
                          onPressed: _loginAndGoNext,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: _showEmailForm ? 'Hide Email Login' : 'Login with Email',
                          onPressed: () => setState(() => _showEmailForm = !_showEmailForm),
                        ),
                        const SizedBox(height: 14),
                        if (_showEmailForm) ...[
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                              hintText: 'Enter your email',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              hintText: 'Enter your password',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, Routes.forgotPassword),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: 'Login',
                            icon: Icons.login_rounded,
                            onPressed: _loginAndGoNext,
                          ),
                        ],
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, Routes.signup),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
