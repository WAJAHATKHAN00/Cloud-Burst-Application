import 'package:flutter/material.dart';

import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('My Reports')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: const [
              _ReportCard(type: 'Landslide', location: 'Murree', time: '25 min ago', status: 'Submitted'),
              _ReportCard(type: 'Flooding', location: 'Rawalpindi', time: '1 hour ago', status: 'Reviewed'),
              _ReportCard(type: 'Heavy Rain', location: 'Islamabad', time: 'Yesterday', status: 'Submitted'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String type;
  final String location;
  final String time;
  final String status;

  const _ReportCard({required this.type, required this.location, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$type • $location', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('$time • $status', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
