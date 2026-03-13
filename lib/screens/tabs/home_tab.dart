import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../routes.dart';
import '../../widgets/section_title.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pushNamed(context, Routes.citySearch),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.place_rounded, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.selectedCity,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updated (demo).')),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 6),
                            Text('HIGH RISK', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('Updated 3 min ago', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Heavy rainfall detected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rainfall intensity: 32 mm/hr  •  Confidence: 80%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.alertDetail),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const SectionTitle('Weather metrics'),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _MetricCard(icon: Icons.water_drop_rounded, title: 'Rainfall', value: '32 mm/hr')),
              SizedBox(width: 10),
              Expanded(child: _MetricCard(icon: Icons.opacity_rounded, title: 'Humidity', value: '85%')),
              SizedBox(width: 10),
              Expanded(child: _MetricCard(icon: Icons.air_rounded, title: 'Wind', value: '26 km/h')),
            ],
          ),
          const SizedBox(height: 14),
          const SectionTitle('Next 3 hours forecast'),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _ForecastChip(time: 'Now', temp: '27°', risk: 'High'),
                _ForecastChip(time: '4 PM', temp: '26°', risk: 'High'),
                _ForecastChip(time: '6 PM', temp: '24°', risk: 'Moderate'),
                _ForecastChip(time: '8 PM', temp: '22°', risk: 'Low'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MetricCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(height: 6),
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ForecastChip extends StatelessWidget {
  final String time;
  final String temp;
  final String risk;

  const _ForecastChip({required this.time, required this.temp, required this.risk});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 92,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          const Spacer(),
          Text(temp, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          Text(risk, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }
}
