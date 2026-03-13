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

  static const _cities = <String>[
    'Islamabad, Pakistan',
    'Rawalpindi, Pakistan',
    'Lahore, Pakistan',
    'Karachi, Pakistan',
    'Murree, Pakistan',
    'Gilgit, Pakistan',
    'Skardu, Pakistan',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _cities.where((c) => c.toLowerCase().contains(_query.toLowerCase())).toList();

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
                                        AppStateScope.of(context).setSelectedCity(city);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Selected: $city')),
                                        );
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
