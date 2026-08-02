import 'package:flutter/material.dart';

import 'package:cloud_burst/app/theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTheme.microLabel(fontSize: 10, color: AppTheme.slate),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
