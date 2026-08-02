import 'package:flutter/material.dart';

import 'package:cloud_burst/app/theme/app_theme.dart';

class CloudBackground extends StatelessWidget {
  final Widget child;
  const CloudBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.paper,
      child: child,
    );
  }
}
