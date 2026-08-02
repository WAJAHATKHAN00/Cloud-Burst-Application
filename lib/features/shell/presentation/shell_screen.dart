import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_burst/app/navigation/nav.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/device_service.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/features/alerts/presentation/alerts_tab.dart';
import 'package:cloud_burst/features/home/presentation/home_tab.dart';
import 'package:cloud_burst/features/map/presentation/map_tab.dart';
import 'package:cloud_burst/features/profile/presentation/profile_tab.dart';
import 'package:cloud_burst/features/reports/presentation/report_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const int _alertsIndex = 2;
  static const int _profileIndex = 4;
  static const String _seenAlertIdsKey = 'seen_alert_ids';
  static const String _seenProfileStatusKeysKey = 'seen_profile_status_keys';

  int _index = 0;
  int _unreadAlertCount = 0;
  int _unreadProfileUpdateCount = 0;
  Set<String> _seenAlertIds = <String>{};
  Set<String> _seenProfileStatusKeys = <String>{};
  Set<String> _currentAlertIds = <String>{};
  Set<String> _currentProfileStatusKeys = <String>{};
  StreamSubscription<List<Map<String, dynamic>>>? _alertsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;

  final List<Widget> _tabs = const [
    HomeTab(),
    MapTab(),
    AlertsTab(),
    ReportTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _startBadgeListeners();
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startBadgeListeners() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await DeviceService.getDeviceId();

    if (!mounted) return;

    _seenAlertIds = prefs.getStringList(_seenAlertIdsKey)?.toSet() ?? <String>{};
    _seenProfileStatusKeys =
        prefs.getStringList(_seenProfileStatusKeysKey)?.toSet() ?? <String>{};

    _alertsSubscription = SupabaseService.watchApprovedReports().listen((
      alerts,
    ) {
      final alertIds = alerts.map(_recordId).whereType<String>().toSet();
      _currentAlertIds = alertIds;

      if (_index == _alertsIndex) {
        _markAlertsSeen();
        return;
      }

      _updateUnreadAlertCount();
    });

    _profileSubscription = SupabaseService.watchReportsForDevice(
      deviceId: deviceId,
    ).listen((reports) {
      final statusKeys = reports
          .map(_profileStatusKey)
          .whereType<String>()
          .toSet();
      _currentProfileStatusKeys = statusKeys;

      if (_index == _profileIndex) {
        _markProfileUpdatesSeen();
        return;
      }

      _updateUnreadProfileUpdateCount();
    });
  }

  void _selectTab(int index) {
    setState(() => _index = index);

    if (index == _alertsIndex) {
      _markAlertsSeen();
    } else if (index == _profileIndex) {
      _markProfileUpdatesSeen();
    }
  }

  Future<void> _markAlertsSeen() async {
    final nextSeenIds = {..._seenAlertIds, ..._currentAlertIds};
    _seenAlertIds = nextSeenIds;

    if (mounted && _unreadAlertCount != 0) {
      setState(() => _unreadAlertCount = 0);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenAlertIdsKey, nextSeenIds.toList());
  }

  Future<void> _markProfileUpdatesSeen() async {
    final nextSeenKeys = {
      ..._seenProfileStatusKeys,
      ..._currentProfileStatusKeys,
    };
    _seenProfileStatusKeys = nextSeenKeys;

    if (mounted && _unreadProfileUpdateCount != 0) {
      setState(() => _unreadProfileUpdateCount = 0);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenProfileStatusKeysKey, nextSeenKeys.toList());
  }

  void _updateUnreadAlertCount() {
    final count = _currentAlertIds.difference(_seenAlertIds).length;
    if (!mounted || count == _unreadAlertCount) return;

    setState(() => _unreadAlertCount = count);
  }

  void _updateUnreadProfileUpdateCount() {
    final count =
        _currentProfileStatusKeys.difference(_seenProfileStatusKeys).length;
    if (!mounted || count == _unreadProfileUpdateCount) return;

    setState(() => _unreadProfileUpdateCount = count);
  }

  String? _recordId(Map<String, dynamic> record) {
    final id = record['id']?.toString().trim();
    return id == null || id.isEmpty ? null : id;
  }

  String? _profileStatusKey(Map<String, dynamic> report) {
    final id = _recordId(report);
    if (id == null) return null;

    final status = report['status']?.toString().trim().toLowerCase();
    if (status != 'approved' && status != 'rejected') return null;

    return '$id:$status';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: IndexedStack(index: _index, children: _tabs),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 0.5px top border
          const Divider(height: 0.5, thickness: 0.5, color: AppTheme.divider),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _selectTab,
            destinations: [
              for (var i = 0; i < navItems.length; i++)
                NavigationDestination(
                  icon: _NavigationBadge(
                    count: _badgeCountForIndex(i),
                    child: Icon(navItems[i].icon),
                  ),
                  label: navItems[i].label,
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _badgeCountForIndex(int index) {
    if (index == _alertsIndex) return _unreadAlertCount;
    if (index == _profileIndex) return _unreadProfileUpdateCount;
    return 0;
  }
}

class _NavigationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const _NavigationBadge({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final label = count > 99 ? '99+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.hazardRed,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.paper,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
