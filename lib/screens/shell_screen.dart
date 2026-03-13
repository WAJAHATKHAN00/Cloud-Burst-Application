import 'package:flutter/material.dart';
import '../nav.dart';
import '../routes.dart';
import '../widgets/cloud_background.dart';

import 'tabs/home_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/report_tab.dart';
import 'tabs/profile_tab.dart';

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
        floatingActionButton: (_index == 0)
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(context, Routes.citySearch),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Search City'),
              )
            : null,
      ),
    );
  }
}
