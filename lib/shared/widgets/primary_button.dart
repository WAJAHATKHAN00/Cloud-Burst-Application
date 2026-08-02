import 'package:flutter/material.dart';

import 'package:cloud_burst/app/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.ink,
          foregroundColor: AppTheme.paper,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTheme.microLabel(
            fontSize: 12,
            color: AppTheme.paper,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(label.toUpperCase()),
      ),
    );
  }
}
