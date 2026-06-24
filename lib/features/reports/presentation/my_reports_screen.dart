import 'package:flutter/material.dart';

import 'package:cloud_burst/core/services/device_service.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late final Future<String> _deviceIdFuture = DeviceService.getDeviceId();

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('My Reports')),
        body: SafeArea(
          child: FutureBuilder<String>(
            future: _deviceIdFuture,
            builder: (context, deviceSnapshot) {
              if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (deviceSnapshot.hasError || deviceSnapshot.data == null) {
                return _MessageState(
                  icon: Icons.error_outline_rounded,
                  message: 'Unable to load your reports.',
                  detail: '${deviceSnapshot.error ?? ''}',
                );
              }

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: SupabaseService.watchReportsForDevice(
                  deviceId: deviceSnapshot.data!,
                ),
                builder: (context, reportsSnapshot) {
                  if (reportsSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !reportsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (reportsSnapshot.hasError) {
                    return _MessageState(
                      icon: Icons.error_outline_rounded,
                      message: 'Unable to load your reports.',
                      detail: '${reportsSnapshot.error}',
                    );
                  }

                  final reports = reportsSnapshot.data ?? [];

                  if (reports.isEmpty) {
                    return const _MessageState(
                      icon: Icons.menu_book_rounded,
                      message: 'No reports submitted yet.',
                      detail: 'Reports you submit will appear here.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = _UserReport.fromMap(reports[index]);

                      return _ReportCard(
                        type: report.type,
                        location: report.location,
                        time: report.timeLabel,
                        status: report.status,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UserReport {
  final String type;
  final String location;
  final String status;
  final DateTime? createdAt;

  const _UserReport({
    required this.type,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  factory _UserReport.fromMap(Map<String, dynamic> map) {
    return _UserReport(
      type: _readText(map['reports_type'], fallback: 'Report'),
      location: _readText(map['location_name'], fallback: 'Unknown location'),
      status: _readText(map['status'], fallback: 'Pending'),
      createdAt: _readDate(map['created_at']),
    );
  }

  String get timeLabel {
    final date = createdAt;
    if (date == null) return 'Unknown time';

    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hour ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  static String _readText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class _ReportCard extends StatelessWidget {
  final String type;
  final String location;
  final String time;
  final String status;

  const _ReportCard({
    required this.type,
    required this.location,
    required this.time,
    required this.status,
  });

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
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$type - $location',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$time - $status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
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

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String detail;

  const _MessageState({
    required this.icon,
    required this.message,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.black45),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
