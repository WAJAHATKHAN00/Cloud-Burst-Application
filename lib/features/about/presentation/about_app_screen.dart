import 'package:flutter/material.dart';

import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('About App')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.cloud_rounded, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CloudBurst Alert', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('Version 1.0.0 (Demo UI)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'CloudBurst Alert provides cloudburst risk information, real-time warnings, and safety guidance. '
                    'This is a frontend UI demo that will be connected to real data sources in backend.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                  ),
                  Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                Text(widget.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
