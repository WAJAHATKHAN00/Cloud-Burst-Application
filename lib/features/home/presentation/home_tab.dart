import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/prediction_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:cloud_burst/features/alerts/presentation/alert_detail_screen.dart';

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
    return AppTheme.severityColor(risk);
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

  double _riskPercent() {
    if (probability == '--') return 0;
    final raw = probability.replaceAll('%', '');
    return (double.tryParse(raw) ?? 0).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final forecastTimezone =
        ((_forecastData?['city'] as Map<String, dynamic>?)?['timezone'] as num?)
                ?.toInt() ??
            0;
    final currentTimeLabel = _currentWeatherData == null
        ? '--'
        : formatCurrentTime(forecastTimezone);

    final riskPct = _riskPercent();
    final riskColor = getRiskColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          // ── Top row: location + synced timestamp ──
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.citySearch),
                  child: Text(
                    state.selectedCity.toUpperCase(),
                    style: AppTheme.microLabel(
                      fontSize: 12,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                'SYNCED ${currentTimeLabel.toUpperCase()}',
                style: AppTheme.mono(
                  fontSize: 10,
                  color: AppTheme.slate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── CLOUDBURST RISK INDEX label ──
          Text(
            'CLOUDBURST RISK INDEX',
            style: AppTheme.microLabel(
              fontSize: 10,
              color: AppTheme.slate,
            ),
          ),
          const SizedBox(height: 12),

          // ── Risk dial ──
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _RiskDialPainter(
                percent: riskPct,
                severityColor: riskColor,
              ),
              size: const Size(double.infinity, 200),
            ),
          ),

          // ── Big mono percentage ──
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  probability == '--'
                      ? '--'
                      : probability.replaceAll('%', ''),
                  style: AppTheme.mono(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    color: riskColor,
                  ),
                ),
                if (probability != '--')
                  Text(
                    ' %',
                    style: AppTheme.mono(
                      fontSize: 16,
                      color: AppTheme.slate,
                    ),
                  ),
              ],
            ),
          ),
          Center(
            child: Text(
              '${normalizeRiskLabel(risk)} · NEXT 3H',
              style: AppTheme.microLabel(
                fontSize: 10,
                color: AppTheme.slate,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Instrument rows ──
          _InstrumentRow(
            label: 'RAINFALL · 1H',
            value: rainfall,
          ),
          _InstrumentRow(
            label: 'SOIL SATURATION',
            value: humidity,
          ),
          _InstrumentRow(
            label: 'RIVER LEVEL',
            value: wind,
          ),

          const SizedBox(height: 20),
          const Divider(height: 0.5, thickness: 0.5, color: AppTheme.divider),
          const SizedBox(height: 16),

          // ── Hourly trend strip ──
          Text(
            'NEXT 8H',
            style: AppTheme.microLabel(
              fontSize: 10,
              color: AppTheme.slate,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: _HourlyTrendStrip(
              forecastList: forecastList,
              forecastTimezone: forecastTimezone,
            ),
          ),

          const SizedBox(height: 20),

          // ── VIEW 6-HOUR OUTLOOK button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
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
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.ink,
                side: const BorderSide(color: AppTheme.ink, width: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'VIEW 6-HOUR OUTLOOK',
                style: AppTheme.microLabel(
                  fontSize: 12,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // ── Field unit ID ──
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'CB·7 FIELD UNIT',
              style: AppTheme.mono(
                fontSize: 9,
                color: AppTheme.slate,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Risk dial painter ─────────────────────────────────────────────
class _RiskDialPainter extends CustomPainter {
  final double percent;
  final Color severityColor;

  _RiskDialPainter({required this.percent, required this.severityColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.82);
    final radius = size.width * 0.38;
    const startAngle = math.pi * 1.15;
    const sweepAngle = math.pi * 0.7;
    const strokeWidth = 10.0;

    // Background arc
    final bgPaint = Paint()
      ..color = AppTheme.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Foreground arc (severity colored)
    if (percent > 0) {
      final fgPaint = Paint()
        ..color = severityColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * (percent / 100).clamp(0.0, 1.0),
        false,
        fgPaint,
      );
    }

    // Tick marks at 0%, 25%, 50%, 75%, 100%
    final tickPaint = Paint()
      ..color = AppTheme.slate
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final frac in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final angle = startAngle + sweepAngle * frac;
      final outerPt = Offset(
        center.dx + (radius + 8) * math.cos(angle),
        center.dy + (radius + 8) * math.sin(angle),
      );
      final innerPt = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      canvas.drawLine(innerPt, outerPt, tickPaint);
    }

    // Needle
    final needleAngle =
        startAngle + sweepAngle * (percent / 100).clamp(0.0, 1.0);
    final needlePaint = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final needleTip = Offset(
      center.dx + (radius - 14) * math.cos(needleAngle),
      center.dy + (radius - 14) * math.sin(needleAngle),
    );
    canvas.drawLine(center, needleTip, needlePaint);

    // Hub dot
    final hubPaint = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, hubPaint);
  }

  @override
  bool shouldRepaint(_RiskDialPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.severityColor != severityColor;
  }
}

// ── Instrument row ────────────────────────────────────────────────
class _InstrumentRow extends StatelessWidget {
  final String label;
  final String value;

  const _InstrumentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.microLabel(
                fontSize: 10,
                color: AppTheme.slate,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.mono(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hourly trend strip ────────────────────────────────────────────
class _HourlyTrendStrip extends StatelessWidget {
  final List<dynamic> forecastList;
  final int forecastTimezone;

  const _HourlyTrendStrip({
    required this.forecastList,
    required this.forecastTimezone,
  });

  String _getRiskFromItem(Map<String, dynamic> item) {
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

  @override
  Widget build(BuildContext context) {
    final barCount = forecastList.length.clamp(0, 8);
    if (barCount == 0) {
      return const SizedBox.shrink();
    }

    // Find max pop for scaling
    double maxPop = 0;
    for (var i = 0; i < barCount; i++) {
      final item = forecastList[i] as Map<String, dynamic>;
      final pop = ((item['pop'] ?? 0) as num).toDouble();
      if (pop > maxPop) maxPop = pop;
    }
    if (maxPop == 0) maxPop = 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < barCount; i++) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final item = forecastList[i] as Map<String, dynamic>;
                final pop = ((item['pop'] ?? 0) as num).toDouble();
                final riskLabel = _getRiskFromItem(item);
                final barHeight = 8 + (pop / maxPop) * 42;
                final isHighest = (pop == maxPop && maxPop > 0);
                final barColor = isHighest
                    ? AppTheme.severityColor(riskLabel)
                    : AppTheme.divider;

                return Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
          if (i < barCount - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
