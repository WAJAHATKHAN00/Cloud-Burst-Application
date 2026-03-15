import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../routes.dart';
import '../../widgets/section_title.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = AppStateScope.of(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          // Text('Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          // const SizedBox(height: 12),
          // // Card(
          //   child: Padding(
          //     padding: const EdgeInsets.all(14),
               // child: Row(
              //   children: [
              //     Stack(
              //       children: [
              //         CircleAvatar(
              //           radius: 30,
              //           backgroundColor: cs.primary.withOpacity(0.15),
              //           child: Icon(Icons.person_rounded, color: cs.primary, size: 34),
              //         ),
              //         Positioned(
              //           right: -2,
              //           bottom: -2,
              //           child: InkWell(
              //             onTap: () {
              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 const SnackBar(content: Text('Change profile photo (demo).')),
              //               );
              //             },
              //             borderRadius: BorderRadius.circular(999),
              //             child: Container(
              //               padding: const EdgeInsets.all(6),
              //               decoration: BoxDecoration(
              //                 color: cs.primary,
              //                 shape: BoxShape.circle,
              //                 border: Border.all(color: Colors.white, width: 2),
              //               ),
              //               child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text('Ali Raza', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              //           const SizedBox(height: 4),
              //           Text('ali.raza@email.com', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              //           const SizedBox(height: 4),
              //           Text('Current city: ${state.selectedCity}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
          //   ),
          // ),
          const SizedBox(height: 14),
          Text('Menu', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.menu_book_rounded,
            title: 'My Reports',
            subtitle: 'View all incidents you submitted',
            onTap: () => Navigator.pushNamed(context, Routes.myReports),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'About App',
            subtitle: 'App purpose, version, and policies',
            onTap: () => Navigator.pushNamed(context, Routes.about),
          ),
          _MenuTile(
            icon: Icons.support_agent_rounded,
            title: 'Help & Support',
            subtitle: 'FAQs and contact support',
            onTap: () => Navigator.pushNamed(context, Routes.help),
          ),
          const SizedBox(height: 14),
          // SizedBox(
          //   height: 52,
          //   child: OutlinedButton.icon(
          //     onPressed: () {
          //       AppStateScope.of(context).logout();
          //       Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
          //     },
          //     icon: const Icon(Icons.logout_rounded),
          //     label: const Text('Sign Out'),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
