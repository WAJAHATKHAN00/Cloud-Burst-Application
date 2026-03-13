import 'package:flutter/material.dart';
import '../widgets/cloud_background.dart';
import '../widgets/section_title.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Alert Details')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('High Risk Alert', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('Islamabad, Pakistan • Updated 10 min ago', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SizedBox(
                    height: 180,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Container(color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.22,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const RadialGradient(
                                  center: Alignment(0.2, -0.1),
                                  radius: 1.1,
                                  colors: [
                                    Color(0xFFEF4444),
                                    Color(0xFFF59E0B),
                                    Color(0xFF22C55E),
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.25, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Risk map preview (demo)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                          ),
                        ),
                        const Positioned(
                          right: 14,
                          bottom: 14,
                          child: Icon(Icons.place_rounded, color: Color(0xFF2F6BFF), size: 30),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const SectionTitle('Risk factors'),
                const SizedBox(height: 8),
                _ReasonTile(icon: Icons.cloud_rounded, title: 'Heavy Rainfall', desc: '32 mm/hr rainfall detected'),
                _ReasonTile(icon: Icons.landscape_rounded, title: 'Loose Rocks / Landslide Risk', desc: 'Mountain slopes may cause rock falling'),
                _ReasonTile(icon: Icons.terrain_rounded, title: 'Mountain Terrain', desc: 'Steep terrain increases flash flood risk'),
                _ReasonTile(icon: Icons.waves_rounded, title: 'River Overflow Risk', desc: 'Nearby rivers may overflow after sudden rain'),
                _ReasonTile(icon: Icons.ac_unit_rounded, title: 'Snowfall / Meltwater', desc: 'Upper regions may increase water flow'),
                const SizedBox(height: 14),
                const SectionTitle('Confidence level'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('80%', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('High confidence', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.8,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: cs.primary.withOpacity(0.12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Based on rainfall intensity, terrain analysis, and forecast models.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const SectionTitle('Safety tips'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _Bullet('Stay indoors during intense rainfall'),
                        _Bullet('Avoid mountain roads and landslide zones'),
                        _Bullet('Keep distance from rivers and streams'),
                        _Bullet('Follow official emergency instructions'),
                        _Bullet('Keep your phone charged for updates'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss / Back'),
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

class _ReasonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ReasonTile({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
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
        subtitle: Text(desc),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontWeight: FontWeight.w900)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
