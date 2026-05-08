import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';
import 'package:cloud_burst/shared/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Sign Up'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            hintText: 'Full name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                            hintText: 'Email address',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            hintText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'Create Account',
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: () {
                            Navigator.popUntil(context, (r) => r.settings.name == Routes.login || r.isFirst);
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'By continuing, you agree to the app policies.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Back to Login', style: TextStyle(color: cs.primary)),
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
