import 'package:flutter/material.dart';

import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'ABOUT APP',
            style: AppTheme.microLabel(
              fontSize: 13,
              color: AppTheme.slate,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 8),
              Text(
                'CLOUDBURST PREDICTOR',
                style: AppTheme.microLabel(
                  fontSize: 17,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'V1.0.0',
                style: AppTheme.mono(
                  fontSize: 10,
                  color: AppTheme.slate,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CloudBurst Alert provides cloudburst risk information, real-time warnings, and safety guidance. '
                'This is a frontend UI demo that will be connected to real data sources in backend.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.slate, height: 1.5),
              ),
              const SizedBox(height: 20),
              const _Expandable(
                title: 'Terms of Service',
                body:
                    'This app provides advisory information only. Use official sources for emergency decisions. '
                    'You are responsible for your actions based on the information shown.',
              ),
              const _Expandable(
                title: 'Privacy Policy',
                body:
                    'Location is used to show local risk and alerts. We do not sell personal data. '
                    'In the final system, data will be protected using secure authentication and rules.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Expandable extends StatefulWidget {
  final String title;
  final String body;

  const _Expandable({required this.title, required this.body});

  @override
  State<_Expandable> createState() => _ExpandableState();
}

class _ExpandableState extends State<_Expandable> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.divider, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppTheme.slate,
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 8),
              Text(
                widget.body,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.slate, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
