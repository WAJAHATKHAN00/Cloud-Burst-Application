import 'package:flutter/material.dart';

import 'package:cloud_burst/app/navigation/nav.dart';
import 'package:cloud_burst/features/alerts/presentation/alerts_tab.dart';
import 'package:cloud_burst/features/home/presentation/home_tab.dart';
import 'package:cloud_burst/features/map/presentation/map_tab.dart';
import 'package:cloud_burst/features/profile/presentation/profile_tab.dart';
import 'package:cloud_burst/features/reports/presentation/report_tab.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    MapTab(),
    AlertsTab(),
    ReportTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(index: _index, children: _tabs),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final item in navItems)
              NavigationDestination(icon: Icon(item.icon), label: item.label),
          ],
        ),
      ),
    );
  }
}
