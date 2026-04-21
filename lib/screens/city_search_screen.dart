import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/cloud_background.dart';

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
    final cs = Theme.of(context).colorScheme;
    final filtered = cityCoordinates.keys
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Search City')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search city...',
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: cs.primary.withOpacity(0.10)),
                        ),
                        child: Center(
                          child: Text(
                            'World map (UI demo)\nSearch and select a city',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: cs.primary.withOpacity(0.10)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 210,
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, i) {
                                    final city = filtered[i];
                                    return ListTile(
                                      leading: Icon(Icons.place_rounded, color: cs.primary),
                                      title: Text(city),
                                      trailing: const Icon(Icons.chevron_right_rounded),
                                      onTap: () {
                                        final coords = cityCoordinates[city]!;

                                        AppStateScope.of(context).setSelectedCity(city);
                                        AppStateScope.of(context).setLocation(coords['lat']!, coords['lon']!);

                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.check_rounded),
                                  label: const Text('Done'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
