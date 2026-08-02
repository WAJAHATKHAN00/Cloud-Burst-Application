import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          // Radar-ring icon (matching splash)
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.divider, width: 0.5),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.divider, width: 0.5),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'FIELD UNIT',
            style: AppTheme.microLabel(
              fontSize: 10,
              color: AppTheme.slate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Anonymous device profile',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.slate),
          ),
          const SizedBox(height: 24),

          // ── Menu ──
          Text(
            'MENU',
            style: AppTheme.microLabel(
              fontSize: 10,
              color: AppTheme.slate,
            ),
          ),
          const SizedBox(height: 8),
          _MenuRow(
            icon: Icons.menu_book_outlined,
            title: 'My Reports',
            subtitle: 'View all incidents you submitted',
            onTap: () => Navigator.pushNamed(context, Routes.myReports),
          ),
          _MenuRow(
            icon: Icons.info_outline_rounded,
            title: 'About App',
            subtitle: 'App purpose, version, and policies',
            onTap: () => Navigator.pushNamed(context, Routes.about),
          ),
          _MenuRow(
            icon: Icons.support_agent_outlined,
            title: 'Help & Support',
            subtitle: 'FAQs and contact support',
            onTap: () => Navigator.pushNamed(context, Routes.help),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          children: [
            Icon(icon, size: 22, color: AppTheme.slate),
            const SizedBox(width: 12),
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
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.slate),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppTheme.slate),
          ],
        ),
      ),
    );
  }
}
