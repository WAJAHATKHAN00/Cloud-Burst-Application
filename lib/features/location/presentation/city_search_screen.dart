import 'package:flutter/material.dart';

import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  static const Map<String, Map<String, double>> cityCoordinates = {
    'Islamabad, Pakistan': {'lat': 33.6844, 'lon': 73.0479},
    'Rawalpindi, Pakistan': {'lat': 33.5651, 'lon': 73.0169},
    'Lahore, Pakistan': {'lat': 31.5204, 'lon': 74.3587},
    'Karachi, Pakistan': {'lat': 24.8607, 'lon': 67.0011},
    'Murree, Pakistan': {'lat': 33.9070, 'lon': 73.3943},
    'Gilgit, Pakistan': {'lat': 35.9208, 'lon': 74.3142},
    'Skardu, Pakistan': {'lat': 35.2971, 'lon': 75.6337},
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = cityCoordinates.keys
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'CITY SEARCH',
            style: AppTheme.microLabel(
              fontSize: 13,
              color: AppTheme.slate,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppTheme.slate,
                      size: 20,
                    ),
                    hintText: 'Search city…',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Results
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final city = filtered[i];
                    final parts = city.split(',');
                    final name = parts.first.trim();
                    final region = parts.length > 1 ? parts[1].trim() : '';

                    return InkWell(
                      onTap: () {
                        final coords = cityCoordinates[city]!;
                        AppStateScope.of(context).setSelectedCity(city);
                        AppStateScope.of(context)
                            .setLocation(coords['lat']!, coords['lon']!);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.divider,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppTheme.slate,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  if (region.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      region,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.slate),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppTheme.slate,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
