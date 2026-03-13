import 'package:flutter/material.dart';
import '../../widgets/section_title.dart';

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  String _type = 'Heavy Rain';
  double _intensity = 0.7;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          Text('Report Incident', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'Share real-world observations to help others (demo UI).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const SectionTitle('Select incident type'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TypeChip(label: 'Heavy Rain', icon: Icons.cloud_rounded, selected: _type == 'Heavy Rain', onTap: () => setState(() => _type = 'Heavy Rain')),
              _TypeChip(label: 'Flooding', icon: Icons.water_drop_rounded, selected: _type == 'Flooding', onTap: () => setState(() => _type = 'Flooding')),
              _TypeChip(label: 'Landslide', icon: Icons.landscape_rounded, selected: _type == 'Landslide', onTap: () => setState(() => _type = 'Landslide')),
              _TypeChip(label: 'Rock Falling', icon: Icons.terrain_rounded, selected: _type == 'Rock Falling', onTap: () => setState(() => _type = 'Rock Falling')),
              _TypeChip(label: 'Snowfall', icon: Icons.ac_unit_rounded, selected: _type == 'Snowfall', onTap: () => setState(() => _type = 'Snowfall')),
              _TypeChip(label: 'River Overflow', icon: Icons.waves_rounded, selected: _type == 'River Overflow', onTap: () => setState(() => _type = 'River Overflow')),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle('Location'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.my_location_rounded, color: cs.primary),
              title: const Text('Current location (demo)'),
              subtitle: const Text('Islamabad, Pakistan'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location picker (demo).')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Intensity'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelForIntensity(_intensity),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Slider(
                    value: _intensity,
                    onChanged: (v) => setState(() => _intensity = v),
                  ),
                  Text(
                    'Low  •  Moderate  •  High',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Optional details'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Add photo (demo).')),
                            );
                          },
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Add Photo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.notes_rounded),
                      hintText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report submitted (demo): $_type')),
                );
                _notesCtrl.clear();
                setState(() => _intensity = 0.7);
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Submit Report'),
            ),
          ),
        ],
      ),
    );
  }

  String _labelForIntensity(double v) {
    if (v < 0.34) return 'Low intensity';
    if (v < 0.67) return 'Moderate intensity';
    return 'High intensity';
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(0.12) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? cs.primary.withOpacity(0.35) : cs.primary.withOpacity(0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? cs.primary : Colors.black54),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? cs.primary : Colors.black87)),
          ],
        ),
      ),
    );
  }
}
