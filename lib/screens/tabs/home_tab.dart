import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../routes.dart';
import '../../widgets/section_title.dart';
import '../../services/weather_service.dart';
import '../../services/prediction_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}
//adfafafafasf
class _HomeTabState extends State<HomeTab> {
  String message = "";
  String risk = "Loading...";
  String rainfall = "--";
  String humidity = "--";
  String wind = "--";
  String probability = "--";
  String temperature = "--";
  String condition = "";

  List forecastList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData(); // 🔥 main trigger
  }

  Future<void> loadData() async {

    try {
      final state = AppStateScope.of(context);

      // 🔵 Forecast (unchanged)
      final data = await WeatherService.fetchWeather(
        state.latitude,
        state.longitude,
      );

      // 🔴 Current weather (NEW)
      final current = await WeatherService.fetchCurrentWeather(
        state.latitude,
        state.longitude,
      );


      setState(() {
        message = PredictionService.getMessage(data);
        final prediction = PredictionService.predict(data);

        risk = prediction["risk"];
        probability = "${prediction["confidence"]}%";


        // 🔴 CURRENT DATA (for metrics)
        temperature =
            (current["main"]["feels_like"] as num).toDouble().toStringAsFixed(0);

        condition = current["weather"][0]["main"];

        humidity = "${(current["main"]["humidity"] as num).toInt()}%";

        wind =
        "${(current["wind"]["speed"] as num).toDouble().toStringAsFixed(1)} m/s";

        // 🔵 FORECAST DATA (for rain + prediction)
        final first = data["list"][0];

        rainfall =
        "${(((first["pop"] ?? 0) as num) * 100).toStringAsFixed(0)}%";


        forecastList = data["list"];
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }
  String getRiskFromItem(Map<String, dynamic> item) {
    double humidity = (item["main"]["humidity"] as num).toDouble();
    double pressure = (item["main"]["pressure"] as num).toDouble();
    double wind = (item["wind"]["speed"] as num).toDouble();
    double clouds = (item["clouds"]["all"] as num).toDouble();
    double rain = ((item["pop"] ?? 0) as num).toDouble() * 100;

    int score = 0;

    if (humidity > 75) score += 2;
    if (clouds > 70) score += 2;
    if (pressure < 1005) score += 3;
    if (wind > 8) score += 2;
    if (rain > 50) score += 3;

    if (score >= 8) return "HIGH";
    if (score >= 5) return "MODERATE";
    return "LOW";
  }

  Color getRiskColor() {
    if (risk.contains("HIGH")) return const Color(0xFFEF4444);
    if (risk.contains("MODERATE")) return Colors.orange;
    return Colors.green;
  }

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
                onPressed: loadData,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔴 RISK CARD
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
                          color: getRiskColor().withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 18, color: getRiskColor()),
                            const SizedBox(width: 6),
                            Text(
                              risk,
                              style: TextStyle(
                                color: getRiskColor(),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('Live', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Current conditions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$temperature°",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        condition,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                       message,
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

          /// 🔵 METRICS
          const SectionTitle('Weather metrics'),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _MetricCard(icon: Icons.water_drop_rounded, title: 'Rain', value: rainfall)),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(icon: Icons.opacity_rounded, title: 'Humidity', value: humidity)),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(icon: Icons.air_rounded, title: 'Wind', value: wind)),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔵 DYNAMIC FORECAST
          const SectionTitle('Next 3 hours forecast'),
          const SizedBox(height: 10),

          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                if (forecastList.isEmpty) {
                  return _ForecastChip(time: '--', temp: '--', risk: '--');
                }

                if (forecastList.length <= index + 1) {
                  return _ForecastChip(time: '--', temp: '--', risk: '--');
                }

                final item = forecastList[index + 1];

                final temp =
                (item["main"]["temp"] as num).toDouble().toStringAsFixed(0);

                final risk = getRiskFromItem(item);

                final time = index == 0 ? "Now" : "+${(index) * 3}h";

                return _ForecastChip(
                  time: time,
                  temp: "$temp°",
                  risk: risk,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastChip extends StatelessWidget {
  final String time;
  final String temp;
  final String risk;

  const _ForecastChip({
    required this.time,
    required this.temp,
    required this.risk,
  });

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
          Text(time,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54)),
          const Spacer(),
          Text(temp,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          Text(risk,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

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
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}