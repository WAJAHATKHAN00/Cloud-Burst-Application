import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/features/alerts/presentation/alert_detail_screen.dart';
import 'package:cloud_burst/shared/widgets/section_title.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Warnings generated for nearby risk zones.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const SectionTitle('Active warnings'),
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

                    return _AlertCard(
                      severityColor: alert.severityColor,
                      title: alert.title,
                      subtitle: alert.subtitle,
                      icon: alert.icon,
                      unread: index < 2,
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
    return '$locationName - $description - $timeLabel';
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

  Color get severityColor {
    if (risk.contains('High')) return const Color(0xFFEF4444);
    if (risk.contains('Moderate')) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  IconData get icon {
    final type = reportType.toLowerCase();
    if (type.contains('cloud burst') || type.contains('cloudburst')) {
      return Icons.thunderstorm_rounded;
    }
    if (type.contains('flood') || type.contains('river')) {
      return Icons.water_drop_rounded;
    }
    if (type.contains('landslide')) return Icons.landscape_rounded;
    if (type.contains('rock')) return Icons.terrain_rounded;
    if (type.contains('snow')) return Icons.ac_unit_rounded;
    return Icons.warning_amber_rounded;
  }

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

class _AlertCard extends StatelessWidget {
  final Color severityColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool unread;
  final VoidCallback onTap;

  const _AlertCard({
    required this.severityColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: severityColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: severityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
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
