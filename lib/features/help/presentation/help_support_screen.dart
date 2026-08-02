import 'package:flutter/material.dart';

import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'HELP & SUPPORT',
            style: AppTheme.microLabel(
              fontSize: 13,
              color: AppTheme.slate,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: const [
              _Faq(
                title: 'How does the risk score work?',
                body:
                    'The app combines weather intensity and terrain factors to estimate risk (demo UI).',
              ),
              _Faq(
                title: 'Why should I report incidents?',
                body:
                    'Reports help verify real conditions and improve alerts for nearby users.',
              ),
              _Faq(
                title: 'How do I change my city?',
                body:
                    'Go to Home tab and tap the location, or use the Search City button.',
              ),
              SizedBox(height: 20),
              _ContactBlock(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Faq extends StatefulWidget {
  final String title;
  final String body;
  const _Faq({required this.title, required this.body});

  @override
  State<_Faq> createState() => _FaqState();
}

class _FaqState extends State<_Faq> {
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

class _ContactBlock extends StatelessWidget {
  const _ContactBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT SUPPORT',
          style: AppTheme.microLabel(
            fontSize: 10,
            color: AppTheme.slate,
          ),
        ),
        const SizedBox(height: 10),
        _ContactRow(
          icon: Icons.mail_outline,
          value: 'support@cloudburst-alert.demo',
        ),
        _ContactRow(
          icon: Icons.call_outlined,
          value: '+92 300 0000000',
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.slate),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTheme.mono(
              fontSize: 12,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
