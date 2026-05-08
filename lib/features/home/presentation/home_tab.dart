import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/core/services/prediction_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:cloud_burst/features/alerts/presentation/alert_detail_screen.dart';
import 'package:cloud_burst/shared/widgets/section_title.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String message = '';
  String risk = 'Loading...';
  String rainfall = '--';
  String humidity = '--';
  String wind = '--';
  String probability = '--';
  String temperature = '--';
  String condition = '';
  Map<String, dynamic>? _forecastData;
  Map<String, dynamic>? _currentWeatherData;
  List<dynamic> forecastList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final state = AppStateScope.of(context);
      final data = await WeatherService.fetchWeather(
        state.latitude,
        state.longitude,
      );
      final current = await WeatherService.fetchCurrentWeather(
        state.latitude,
        state.longitude,
      );

      setState(() {
        message = PredictionService.getMessage(data);
        final prediction = PredictionService.predict(data);

        risk = prediction['risk'] as String;
        probability = '${prediction['confidence']}%';
        temperature =
            (current['main']['feels_like'] as num).toDouble().toStringAsFixed(0);
        condition = current['weather'][0]['main'] as String;
        humidity = '${(current['main']['humidity'] as num).toInt()}%';
        wind =
            '${(current['wind']['speed'] as num).toDouble().toStringAsFixed(1)} m/s';

        final first = data['list'][0];
        rainfall = '${(((first['pop'] ?? 0) as num) * 100).toStringAsFixed(0)}%';

        _forecastData = data;
        _currentWeatherData = current;
        forecastList = data['list'] as List<dynamic>;
      });
    } catch (e) {
      print('ERROR: $e');
    }
  }

  String getRiskFromItem(Map<String, dynamic> item) {
    final humidity = (item['main']['humidity'] as num).toDouble();
    final pressure = (item['main']['pressure'] as num).toDouble();
    final wind = (item['wind']['speed'] as num).toDouble();
    final clouds = (item['clouds']['all'] as num).toDouble();
    final rain = ((item['pop'] ?? 0) as num).toDouble() * 100;

    int score = 0;

    if (humidity > 75) score += 2;
    if (clouds > 70) score += 2;
    if (pressure < 1005) score += 3;
    if (wind > 8) score += 2;
    if (rain > 50) score += 3;

    if (score >= 8) return 'HIGH';
    if (score >= 5) return 'MODERATE';
    return 'LOW';
  }

  Color getRiskColor() {
    if (risk.contains('HIGH')) return const Color(0xFFEF4444);
    if (risk.contains('MODERATE')) return Colors.orange;
    return Colors.green;
  }

  String normalizeRiskLabel(String value) {
    if (value.contains('HIGH')) return 'HIGH';
    if (value.contains('MODERATE')) return 'MODERATE';
    if (value.contains('LOW')) return 'LOW';
    return value;
  }

  String formatHour(DateTime dateTime) {
    final hour = dateTime.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour $period';
  }

  String formatCurrentTime(int timezoneOffsetSeconds) {
    final localTime = DateTime.now()
        .toUtc()
        .add(Duration(seconds: timezoneOffsetSeconds));
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  String formatForecastTime(int timestamp, int timezoneOffsetSeconds) {
    final localTime = DateTime.fromMillisecondsSinceEpoch(
      (timestamp + timezoneOffsetSeconds) * 1000,
      isUtc: true,
    );
    return formatHour(localTime);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final forecastTimezone =
        ((_forecastData?['city'] as Map<String, dynamic>?)?['timezone'] as num?)
            ?.toInt() ??
        0;
    final currentTimeLabel = _currentWeatherData == null
        ? '--'
        : formatCurrentTime(forecastTimezone);

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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary.withOpacity(0.22),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.place_rounded, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.selectedCity,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.search_rounded,
                          color: cs.primary,
                          size: 20,
                        ),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getRiskColor().withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: getRiskColor(),
                            ),
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
                      const Text(
                        'Live',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current conditions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$temperature C',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed:
                          (_forecastData == null || _currentWeatherData == null)
                          ? null
                          : () => Navigator.pushNamed(
                              context,
                              Routes.alertDetail,
                              arguments: AlertDetailData.fromWeatherData(
                                forecastData: _forecastData!,
                                currentWeatherData: _currentWeatherData!,
                              ),
                            ),
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
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.water_drop_rounded,
                  title: 'Rain',
                  value: rainfall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.opacity_rounded,
                  title: 'Humidity',
                  value: humidity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.air_rounded,
                  title: 'Wind',
                  value: wind,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const SectionTitle('Upcoming conditions'),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ForecastChip(
                    time: currentTimeLabel,
                    icon: getWeatherIcon(condition),
                    temp: temperature == '--' ? '--' : '$temperature\u00B0C',
                    rain: rainfall == '--' ? '--' : 'Rain $rainfall',
                    risk:
                        risk == 'Loading...' ? '--' : normalizeRiskLabel(risk),
                  );
                }

                final forecastIndex = index - 1;
                if (forecastList.length <= forecastIndex) {
                  return const _ForecastChip(
                    time: '--',
                    icon: Icons.wb_cloudy_rounded,
                    temp: '--',
                    rain: '--',
                    risk: '--',
                  );
                }

                final item = forecastList[forecastIndex] as Map<String, dynamic>;
                final temp =
                    (item['main']['temp'] as num).toDouble().toStringAsFixed(0);
                final rain =
                    '${((((item['pop'] ?? 0) as num).toDouble()) * 100).toStringAsFixed(0)}%';
                final itemRisk = getRiskFromItem(item);
                final weather =
                    ((item['weather'] as List).first as Map<String, dynamic>)['main']
                        as String;

                return _ForecastChip(
                  time: formatForecastTime(
                    (item['dt'] as num).toInt(),
                    forecastTimezone,
                  ),
                  icon: getWeatherIcon(weather),
                  temp: '$temp\u00B0C',
                  rain: 'Rain $rain',
                  risk: itemRisk,
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
  final IconData icon;
  final String temp;
  final String rain;
  final String risk;

  const _ForecastChip({
    required this.time,
    required this.icon,
    required this.temp,
    required this.rain,
    required this.risk,
  });

  Color _riskColor() {
    if (risk.contains('HIGH')) return const Color(0xFFEF4444);
    if (risk.contains('MODERATE')) return const Color(0xFFF59E0B);
    if (risk.contains('LOW')) return const Color(0xFF22C55E);
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor();

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: riskColor, size: 26),
          const SizedBox(height: 10),
          Text(
            temp,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            rain,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              risk,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: riskColor,
                fontWeight: FontWeight.w800,
              ),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
