import 'package:flutter/material.dart';

import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/core/services/prediction_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';
import 'package:cloud_burst/shared/widgets/section_title.dart';

class AlertDetailData {
  final String risk;
  final int confidence;
  final String rainfall;
  final String humidity;
  final String wind;
  final String message;
  final String temperature;
  final String condition;
  final String pressure;
  final String cloudCover;
  final String feelsLike;

  const AlertDetailData({
    required this.risk,
    required this.confidence,
    required this.rainfall,
    required this.humidity,
    required this.wind,
    required this.message,
    required this.temperature,
    required this.condition,
    required this.pressure,
    required this.cloudCover,
    required this.feelsLike,
  });

  factory AlertDetailData.fromWeatherData({
    required Map<String, dynamic> forecastData,
    required Map<String, dynamic> currentWeatherData,
  }) {
    final prediction = PredictionService.predict(forecastData);
    final firstForecast = forecastData["list"][0] as Map<String, dynamic>;
    final currentMain =
        (currentWeatherData["main"] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final windData =
        (currentWeatherData["wind"] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final cloudData =
        (currentWeatherData["clouds"] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final weatherList = currentWeatherData["weather"] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};

    return AlertDetailData(
      risk: prediction["risk"] as String,
      confidence: prediction["confidence"] as int,
      rainfall: _formatPercent(((firstForecast["pop"] ?? 0) as num) * 100),
      humidity: _formatPercent(currentMain["humidity"] as num? ?? 0),
      wind: _formatWind(windData["speed"] as num? ?? 0),
      message: PredictionService.getMessage(forecastData),
      temperature: _formatTemperature(currentMain["temp"] as num?),
      condition: _toTitleCase(
        (weather["description"] ?? weather["main"] ?? "Unknown").toString(),
      ),
      pressure: "${(currentMain["pressure"] as num? ?? 0).toInt()} hPa",
      cloudCover: _formatPercent(cloudData["all"] as num? ?? 0),
      feelsLike: _formatTemperature(currentMain["feels_like"] as num?),
    );
  }
}

class AlertDetailScreen extends StatefulWidget {
  const AlertDetailScreen({super.key});

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  Future<AlertDetailData>? _future;
  AlertDetailData? _routeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AlertDetailData) {
      _routeData = args;
      return;
    }

    _future ??= _loadAlertDetailData();
  }

  Future<AlertDetailData> _loadAlertDetailData() async {
    final state = AppStateScope.of(context);
    final forecast = await WeatherService.fetchWeather(
      state.latitude,
      state.longitude,
    );
    final current = await WeatherService.fetchCurrentWeather(
      state.latitude,
      state.longitude,
    );

    return AlertDetailData.fromWeatherData(
      forecastData: forecast,
      currentWeatherData: current,
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeData = _routeData;
    if (routeData != null) {
      return _AlertDetailBody(data: routeData);
    }

    return FutureBuilder<AlertDetailData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CloudBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return CloudBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(title: const Text('Alert Details')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load live alert details right now.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return _AlertDetailBody(data: snapshot.data!);
      },
    );
  }
}

class _AlertDetailBody extends StatelessWidget {
  final AlertDetailData data;

  const _AlertDetailBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = AppStateScope.of(context);

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
                            color: _getRiskColor(data.risk).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: _getRiskColor(data.risk),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.risk,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${state.selectedCity} | Live weather data",
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data.temperature,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Text(
                              'Feels like ${data.feelsLike}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.condition,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.message,
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
                const SectionTitle('Current factors'),
                const SizedBox(height: 8),
                _ReasonTile(
                  icon: Icons.water_drop,
                  title: 'Rain probability',
                  desc: data.rainfall,
                ),
                _ReasonTile(
                  icon: Icons.opacity,
                  title: 'Humidity',
                  desc: data.humidity,
                ),
                _ReasonTile(
                  icon: Icons.air,
                  title: 'Wind speed',
                  desc: data.wind,
                ),
                _ReasonTile(
                  icon: Icons.speed,
                  title: 'Pressure',
                  desc: data.pressure,
                ),
                _ReasonTile(
                  icon: Icons.cloud,
                  title: 'Cloud cover',
                  desc: data.cloudCover,
                ),
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
                            Text(
                              '${data.confidence}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _getConfidenceLabel(data.confidence),
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: data.confidence / 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: cs.primary.withOpacity(0.12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence based on rain, clouds, humidity, wind and pressure.',
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
                const SectionTitle('Safety tips'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final tip in _getSafetyTips(data.risk))
                          _Bullet(tip),
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
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
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
          const Text('- ', style: TextStyle(fontWeight: FontWeight.w900)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

Color _getRiskColor(String risk) {
  if (risk.contains('HIGH')) return const Color(0xFFEF4444);
  if (risk.contains('MODERATE')) return Colors.orange;
  return Colors.green;
}

String _getConfidenceLabel(int confidence) {
  if (confidence > 70) return 'High confidence';
  if (confidence > 40) return 'Moderate confidence';
  return 'Low confidence';
}

List<String> _getSafetyTips(String risk) {
  if (risk.contains('HIGH')) {
    return const [
      'Avoid low-lying areas and flood-prone roads.',
      'Keep your phone charged and emergency contacts ready.',
      'Delay unnecessary travel until conditions improve.',
      'Watch for rapid alerts and weather changes.',
    ];
  }

  if (risk.contains('MODERATE')) {
    return const [
      'Track conditions closely for the next few hours.',
      'Plan safer alternate routes before traveling.',
      'Keep rain protection and essentials nearby.',
      'Check for local alerts before going out.',
    ];
  }

  return const [
    'Conditions are stable, but keep monitoring updates.',
    'Stay aware of sudden weather changes.',
    'Review local alerts before longer trips.',
    'Keep emergency contacts accessible.',
  ];
}

String _formatPercent(num value) => '${value.toStringAsFixed(0)}%';

String _formatWind(num value) => '${value.toStringAsFixed(1)} m/s';

String _formatTemperature(num? value) {
  final safeValue = value ?? 0;
  return '${safeValue.toStringAsFixed(0)} C';
}

String _toTitleCase(String value) {
  if (value.isEmpty) return value;

  return value
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
