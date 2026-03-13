import 'package:flutter/material.dart';

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Risk Map', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const Spacer(),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Locate me (demo).')),
                ),
                icon: const Icon(Icons.my_location_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cs.primary.withOpacity(0.10)),
                  ),
                  child: Center(
                    child: Text(
                      'Map placeholder (no extra dependencies)\nHeatmap + markers (UI demo)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.22,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const RadialGradient(
                            center: Alignment(0.25, -0.15),
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
                ),
                Positioned(
                  left: 36,
                  top: 88,
                  child: _HazardMarker(
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFEF4444),
                    label: 'High risk',
                    onTap: () => _showMarker(context, 'High Risk', 'Heavy rainfall near Murree', '10 min ago'),
                  ),
                ),
                Positioned(
                  right: 48,
                  top: 160,
                  child: _HazardMarker(
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFFF59E0B),
                    label: 'Flood',
                    onTap: () => _showMarker(context, 'Flood Report', 'Water level rising near river', '18 min ago'),
                  ),
                ),
                Positioned(
                  right: 72,
                  bottom: 140,
                  child: _HazardMarker(
                    icon: Icons.landscape_rounded,
                    color: const Color(0xFFEF4444),
                    label: 'Landslide',
                    onTap: () => _showMarker(context, 'Landslide Report', 'Loose rocks reported on slope', '25 min ago'),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    'Tip: Tap markers to view hazard details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showMarker(BuildContext context, String title, String desc, String time) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 8),
              Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HazardMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _HazardMarker({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
