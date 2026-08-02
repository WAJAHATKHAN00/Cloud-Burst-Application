import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/prediction_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';

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
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? reportType;

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
    this.locationName,
    this.latitude,
    this.longitude,
    this.reportType,
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
    final weatherList =
        currentWeatherData["weather"] as List<dynamic>? ?? const [];
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
          return CloudBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return CloudBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  'ALERT DETAILS',
                  style: AppTheme.microLabel(
                    fontSize: 13,
                    color: AppTheme.slate,
                  ),
                ),
              ),
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
    final state = AppStateScope.of(context);
    final locationName = data.locationName ?? state.selectedCity;
    final hasMapLocation = data.latitude != null && data.longitude != null;
    final riskColor = _getRiskColor(data.risk);

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'ALERT DETAILS',
            style: AppTheme.microLabel(
              fontSize: 13,
              color: AppTheme.slate,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: [
                const SizedBox(height: 8),
                // Severity tag + title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: riskColor, width: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.risk,
                        style: AppTheme.microLabel(
                          fontSize: 10,
                          color: riskColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        locationName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data.reportType == null
                      ? 'Live weather data'
                      : 'Approved report · ${data.reportType}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.slate),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  data.message,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.slate, height: 1.5),
                ),
                const SizedBox(height: 16),

                // Instrument rows
                _DetailRow(label: 'TEMPERATURE', value: data.temperature),
                _DetailRow(label: 'FEELS LIKE', value: data.feelsLike),
                _DetailRow(label: 'CONDITION', value: data.condition),
                _DetailRow(label: 'CONFIDENCE', value: '${data.confidence}%'),
                _DetailRow(label: 'RAINFALL', value: data.rainfall),
                _DetailRow(label: 'HUMIDITY', value: data.humidity),
                _DetailRow(label: 'WIND', value: data.wind),
                _DetailRow(label: 'PRESSURE', value: data.pressure),
                _DetailRow(label: 'CLOUD COVER', value: data.cloudCover),

                if (hasMapLocation) ...[
                  const SizedBox(height: 16),
                  Text(
                    'MAP LOCATION',
                    style: AppTheme.microLabel(
                      fontSize: 10,
                      color: AppTheme.slate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AlertLocationMap(
                    locationName: locationName,
                    latitude: data.latitude!,
                    longitude: data.longitude!,
                    reportType: data.reportType ?? data.condition,
                    color: riskColor,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'LAT ${data.latitude!.toStringAsFixed(5)}',
                        style: AppTheme.mono(
                          fontSize: 10,
                          color: AppTheme.slate,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'LON ${data.longitude!.toStringAsFixed(5)}',
                        style: AppTheme.mono(
                          fontSize: 10,
                          color: AppTheme.slate,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'BACK',
                      style: AppTheme.microLabel(
                        fontSize: 12,
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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

class _AlertLocationMap extends StatelessWidget {
  final String locationName;
  final double latitude;
  final double longitude;
  final String reportType;
  final Color color;

  const _AlertLocationMap({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.reportType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider, width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  _MapTileLayer(),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: point,
                        radius: 180,
                        useRadiusInMeter: true,
                        color: color.withValues(alpha: 0.12),
                        borderColor: color.withValues(alpha: 0.35),
                        borderStrokeWidth: 1,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 18,
                        height: 18,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.paper,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tap to expand
            Positioned(
              right: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _FullAlertLocationMapScreen(
                        locationName: locationName,
                        latitude: latitude,
                        longitude: longitude,
                        reportType: reportType,
                        color: color,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    border: Border.all(
                      color: AppTheme.divider,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'EXPAND',
                    style: AppTheme.microLabel(
                      fontSize: 10,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullAlertLocationMapScreen extends StatelessWidget {
  final String locationName;
  final double latitude;
  final double longitude;
  final String reportType;
  final Color color;

  const _FullAlertLocationMapScreen({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.reportType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _shortLocation(locationName).toUpperCase(),
          style: AppTheme.microLabel(
            fontSize: 13,
            color: AppTheme.slate,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 15,
              minZoom: 3,
              maxZoom: 19,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.drag |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.pinchMove |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.scrollWheelZoom,
              ),
            ),
            children: [
              _MapTileLayer(),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: point,
                    radius: 180,
                    useRadiusInMeter: true,
                    color: color.withValues(alpha: 0.12),
                    borderColor: color.withValues(alpha: 0.35),
                    borderStrokeWidth: 1,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 18,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.paper,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bottom card
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.paper,
                  border: Border.all(color: AppTheme.divider, width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'LAT ${latitude.toStringAsFixed(5)}',
                          style: AppTheme.mono(
                            fontSize: 10,
                            color: AppTheme.slate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'LON ${longitude.toStringAsFixed(5)}',
                          style: AppTheme.mono(
                            fontSize: 10,
                            color: AppTheme.slate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortLocation(String value) {
    final short = value.split(',').first.trim();
    return short.isEmpty ? 'Reported location' : short;
  }
}

class _MapTileLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.cloud_burst',
      tileProvider: NetworkTileProvider(
        headers: {'User-Agent': 'cloud_burst/1.0'},
        cachingProvider: const DisabledMapCachingProvider(),
      ),
      maxNativeZoom: 19,
      maxZoom: 19,
    );
  }
}

Color _getRiskColor(String risk) {
  return AppTheme.severityColor(risk);
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
