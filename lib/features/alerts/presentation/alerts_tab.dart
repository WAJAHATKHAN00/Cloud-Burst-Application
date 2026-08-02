import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/features/alerts/presentation/alert_detail_screen.dart';
import 'package:cloud_burst/shared/widgets/section_title.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'ACTIVE ALERTS',
            style: AppTheme.microLabel(
              fontSize: 17,
              color: AppTheme.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Warnings generated for nearby risk zones.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.slate),
          ),
          const SizedBox(height: 16),
          const SectionTitle('ACTIVE WARNINGS'),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: SupabaseService.watchApprovedReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _MessageState(
                    icon: Icons.error_outline_rounded,
                    message: 'Unable to load alerts.',
                    detail: '${snapshot.error}',
                  );
                }

                final alerts = (snapshot.data ?? [])
                    .map(_ApprovedAlert.fromMap)
                    .toList();

                if (alerts.isEmpty) {
                  return const _MessageState(
                    icon: Icons.notifications_none_rounded,
                    message: 'No active warnings.',
                    detail: 'Approved reports will appear here as alerts.',
                  );
                }

                return ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];

                    return _AlertRow(
                      severityColor: alert.severityColor,
                      title: alert.title,
                      subtitle: alert.subtitle,
                      timeLabel: alert.timeLabel,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.alertDetail,
                        arguments: alert.toDetailData(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedAlert {
  final String reportType;
  final String location;
  final String risk;
  final int confidence;
  final double? latitude;
  final double? longitude;
  final String description;
  final DateTime? createdAt;

  const _ApprovedAlert({
    required this.reportType,
    required this.location,
    required this.risk,
    required this.confidence,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.createdAt,
  });

  factory _ApprovedAlert.fromMap(Map<String, dynamic> map) {
    final intensity = _readText(map['intensity'], fallback: 'Moderate');
    final risk = _riskFromIntensity(intensity);

    return _ApprovedAlert(
      reportType: _readText(map['reports_type'], fallback: 'Reported Incident'),
      location: _readText(map['location_name'], fallback: 'Unknown location'),
      risk: risk,
      confidence: _confidenceFromRisk(risk),
      latitude: _readDouble(map['latitude']),
      longitude: _readDouble(map['longitude']),
      description: _readText(
        map['discription'],
        fallback: 'Approved user report.',
      ),
      createdAt: _readDate(map['created_at']),
    );
  }

  String get title => '$risk: ${_titleReportType(reportType)}';

  String get subtitle {
    final locationName = location.split(',').first.trim();
    return '$locationName · $description';
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

  Color get severityColor => AppTheme.severityColor(risk);

  AlertDetailData toDetailData() {
    return AlertDetailData(
      risk: risk.toUpperCase(),
      confidence: confidence,
      rainfall: 'Reported',
      humidity: 'Reported',
      wind: 'Reported',
      message: description,
      temperature: reportType,
      condition: reportType,
      pressure: 'Reported',
      cloudCover: 'Reported',
      feelsLike: reportType,
      locationName: location,
      latitude: latitude,
      longitude: longitude,
      reportType: reportType,
    );
  }

  static String _readText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _riskFromIntensity(String intensity) {
    final value = intensity.toLowerCase();
    if (value.contains('high')) return 'High Risk';
    if (value.contains('low')) return 'Low Risk';
    return 'Moderate Risk';
  }

  static int _confidenceFromRisk(String risk) {
    if (risk.contains('High')) return 85;
    if (risk.contains('Moderate')) return 60;
    return 35;
  }

  static String _titleReportType(String reportType) {
    if (reportType == 'Cloud Burst') return 'Cloud Burst Reported';
    if (reportType == 'Heavy Rain') return 'Heavy Rainfall';
    if (reportType == 'Landslide') return 'Landslide Reported';
    return reportType;
  }
}

class _AlertRow extends StatelessWidget {
  final Color severityColor;
  final String title;
  final String subtitle;
  final String timeLabel;
  final VoidCallback onTap;

  const _AlertRow({
    required this.severityColor,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.divider, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity bar
            Container(
              width: 3,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeLabel,
              style: AppTheme.mono(
                fontSize: 10,
                color: AppTheme.slate,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppTheme.slate),
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
            Icon(icon, size: 42, color: AppTheme.slate),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.slate),
            ),
          ],
        ),
      ),
    );
  }
}
