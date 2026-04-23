import 'package:flutter/material.dart';
import '../widgets/cloud_background.dart';
import '../widgets/section_title.dart';
import '../app_state.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = AppStateScope.of(context);

    // 👉 You can later pass these from Home via arguments
    final risk = "LOW RISK";
    final confidence = 27; // replace with real later
    final rainfall = "2%";
    final humidity = "26%";
    final wind = "2.6 m/s";
    final message = "Weather is stable. No immediate risk";

    Color getRiskColor() {
      if (risk.contains("HIGH")) return const Color(0xFFEF4444);
      if (risk.contains("MODERATE")) return Colors.orange;
      return Colors.green;
    }

    String getConfidenceLabel() {
      if (confidence > 70) return "High confidence";
      if (confidence > 40) return "Moderate confidence";
      return "Low confidence";
    }

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Alert Details')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ListView(
              children: [

                /// 🔴 HEADER
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: getRiskColor().withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.warning_amber_rounded,
                              color: getRiskColor()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(risk,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(
                                "${state.selectedCity} • Live data",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 🧠 MESSAGE
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// 📊 REAL METRICS
                const SectionTitle('Current factors'),
                const SizedBox(height: 8),

                _ReasonTile(
                  icon: Icons.water_drop,
                  title: "Rain probability",
                  desc: rainfall,
                ),
                _ReasonTile(
                  icon: Icons.opacity,
                  title: "Humidity",
                  desc: humidity,
                ),
                _ReasonTile(
                  icon: Icons.air,
                  title: "Wind speed",
                  desc: wind,
                ),

                const SizedBox(height: 14),

                /// 📈 CONFIDENCE
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
                            Text('$confidence%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                getConfidenceLabel(),
                                style: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: confidence / 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: cs.primary.withOpacity(0.12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence based on rain, clouds, humidity and wind.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// 🛡 SAFETY
                const SectionTitle('Safety tips'),
                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _Bullet('Stay aware of sudden weather changes'),
                        _Bullet('Avoid flood-prone or low areas'),
                        _Bullet('Keep emergency contacts ready'),
                        _Bullet('Monitor updates regularly'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
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

  const _ReasonTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

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
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
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