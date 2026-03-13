import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/section_title.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alerts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'Warnings generated for nearby risk zones (demo).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const SectionTitle('Active warnings'),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _AlertCard(
                  severityColor: const Color(0xFFEF4444),
                  title: 'High Risk: Heavy Rainfall',
                  subtitle: 'Islamabad • 32 mm/hr • 10 min ago',
                  icon: Icons.warning_amber_rounded,
                  unread: true,
                  onTap: () => Navigator.pushNamed(context, Routes.alertDetail),
                ),
                _AlertCard(
                  severityColor: const Color(0xFFF59E0B),
                  title: 'Moderate Risk: River Overflow',
                  subtitle: 'Rawalpindi • Rising level • 18 min ago',
                  icon: Icons.water_drop_rounded,
                  unread: true,
                  onTap: () => Navigator.pushNamed(context, Routes.alertDetail),
                ),
                _AlertCard(
                  severityColor: const Color(0xFFEF4444),
                  title: 'High Risk: Landslide Reported',
                  subtitle: 'Murree • Slope unstable • 25 min ago',
                  icon: Icons.landscape_rounded,
                  unread: false,
                  onTap: () => Navigator.pushNamed(context, Routes.alertDetail),
                ),
                _AlertCard(
                  severityColor: const Color(0xFF22C55E),
                  title: 'Low Risk: Light Rain',
                  subtitle: 'Abbottabad • Light rain • 40 min ago',
                  icon: Icons.cloud_rounded,
                  unread: false,
                  onTap: () => Navigator.pushNamed(context, Routes.alertDetail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  color: severityColor.withOpacity(0.12),
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
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
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
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
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
