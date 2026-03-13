import 'package:flutter/material.dart';
import '../widgets/cloud_background.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Help & Support')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: const [
              _Faq(title: 'How does the risk score work?', body: 'The app combines weather intensity and terrain factors to estimate risk (demo UI).'),
              _Faq(title: 'Why should I report incidents?', body: 'Reports help verify real conditions and improve alerts for nearby users.'),
              _Faq(title: 'How do I change my city?', body: 'Go to Home tab and tap the location, or use the Search City button.'),
              _ContactCard(),
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
                  Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900))),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Support', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Email: support@cloudburst-alert.demo'),
            const SizedBox(height: 4),
            const Text('Phone: +92 300 0000000'),
          ],
        ),
      ),
    );
  }
}
