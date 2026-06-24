import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_burst/app/state/app_state.dart';
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
    final state = AppStateScope.of(context);
    final locationName = data.locationName ?? state.selectedCity;
    final hasMapLocation = data.latitude != null && data.longitude != null;
    final mapColor = _incidentColor(data.reportType ?? data.condition);

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
                            color: _getRiskColor(
                              data.risk,
                            ).withValues(alpha: 0.12),
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$locationName | ${data.reportType == null ? 'Live weather data' : 'Approved report'}",
                                style: Theme.of(context).textTheme.bodySmall
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
                if (hasMapLocation) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Map location',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          _AlertLocationMap(
                            locationName: locationName,
                            latitude: data.latitude!,
                            longitude: data.longitude!,
                            reportType: data.reportType ?? data.condition,
                            color: mapColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_incidentIcon(reportType), color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shortLocation(locationName),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
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
              child: SizedBox(
                height: 220,
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
                          _RiskCircleLayer(point: point, color: color),
                          _AlertMarkerLayer(
                            point: point,
                            color: color,
                            icon: _incidentIcon(reportType),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.report_gmailerrorred_rounded,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Reported at ${_shortLocation(locationName)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 66,
                      child: _IncidentMapLegend(
                        activeReportType: reportType,
                        compact: true,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_full_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Open full map',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CoordinateChip(
                label: 'Latitude',
                value: latitude.toStringAsFixed(5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CoordinateChip(
                label: 'Longitude',
                value: longitude.toStringAsFixed(5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _shortLocation(String value) {
    final short = value.split(',').first.trim();
    return short.isEmpty ? 'Reported location' : short;
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
          _shortLocation(locationName),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
              _RiskCircleLayer(point: point, color: color),
              _AlertMarkerLayer(
                point: point,
                color: color,
                icon: _incidentIcon(reportType),
              ),
            ],
          ),
          Positioned(
            right: 16,
            top: 16,
            child: SafeArea(
              bottom: false,
              child: _IncidentMapLegend(activeReportType: reportType),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: _FullMapLocationCard(
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                reportType: reportType,
                color: color,
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

class _RiskCircleLayer extends StatelessWidget {
  final LatLng point;
  final Color color;

  const _RiskCircleLayer({required this.point, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        CircleMarker(
          point: point,
          radius: 180,
          useRadiusInMeter: true,
          color: color.withValues(alpha: 0.16),
          borderColor: color.withValues(alpha: 0.45),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}

class _AlertMarkerLayer extends StatelessWidget {
  final LatLng point;
  final Color color;
  final IconData icon;

  const _AlertMarkerLayer({
    required this.point,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: point,
          width: 54,
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: color, size: 27),
              Icon(Icons.location_on_rounded, color: color, size: 44),
            ],
          ),
        ),
      ],
    );
  }
}

class _FullMapLocationCard extends StatelessWidget {
  final String locationName;
  final double latitude;
  final double longitude;
  final String reportType;
  final Color color;

  const _FullMapLocationCard({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.reportType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_incidentIcon(reportType), color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    locationName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CoordinateChip(
                    label: 'Latitude',
                    value: latitude.toStringAsFixed(5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CoordinateChip(
                    label: 'Longitude',
                    value: longitude.toStringAsFixed(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentMapLegend extends StatelessWidget {
  final String activeReportType;
  final bool compact;

  const _IncidentMapLegend({
    required this.activeReportType,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeLabel = _incidentLegendLabel(activeReportType);
    final items = compact
        ? _incidentLegendItems
              .where((item) => item.label == activeLabel)
              .toList(growable: false)
        : _incidentLegendItems;

    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 154 : 170),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items) ...[
            _IncidentLegendRow(item: item, active: item.label == activeLabel),
            if (item != items.last) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _IncidentLegendRow extends StatelessWidget {
  final _IncidentLegendItem item;
  final bool active;

  const _IncidentLegendRow({required this.item, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: active ? 11 : 10,
          height: active ? 11 : 10,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF334155),
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoordinateChip extends StatelessWidget {
  final String label;
  final String value;

  const _CoordinateChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _IncidentLegendItem {
  final String label;
  final Color color;

  const _IncidentLegendItem(this.label, this.color);
}

const List<_IncidentLegendItem> _incidentLegendItems = [
  _IncidentLegendItem('Cloud Burst', Color(0xFFB7791F)),
  _IncidentLegendItem('Heavy Rain', Color(0xFF7C3AED)),
  _IncidentLegendItem('Flooding', Color(0xFF2E7D32)),
  _IncidentLegendItem('Landslide', Color(0xFF2563EB)),
  _IncidentLegendItem('Rock Falling', Color(0xFF78716C)),
  _IncidentLegendItem('Snowfall', Color(0xFF0284C7)),
  _IncidentLegendItem('River Overflow', Color(0xFFEF4444)),
];

Color _incidentColor(String reportType) {
  final label = _incidentLegendLabel(reportType);
  return _incidentLegendItems
      .firstWhere(
        (item) => item.label == label,
        orElse: () =>
            const _IncidentLegendItem('Cloud Burst', Color(0xFFB7791F)),
      )
      .color;
}

IconData _incidentIcon(String reportType) {
  final type = reportType.toLowerCase();
  if (type.contains('cloud burst') || type.contains('cloudburst')) {
    return Icons.thunderstorm_rounded;
  }
  if (type.contains('rain')) return Icons.cloud_rounded;
  if (type.contains('flood') || type.contains('overflow')) {
    return Icons.water_drop_rounded;
  }
  if (type.contains('landslide')) return Icons.landscape_rounded;
  if (type.contains('rock')) return Icons.terrain_rounded;
  if (type.contains('snow')) return Icons.ac_unit_rounded;
  return Icons.warning_amber_rounded;
}

String _incidentLegendLabel(String reportType) {
  final type = reportType.toLowerCase();
  if (type.contains('cloud burst') || type.contains('cloudburst')) {
    return 'Cloud Burst';
  }
  if (type.contains('heavy rain') || type == 'rain' || type.contains('rain')) {
    return 'Heavy Rain';
  }
  if (type.contains('overflow')) return 'River Overflow';
  if (type.contains('flood')) return 'Flooding';
  if (type.contains('landslide')) return 'Landslide';
  if (type.contains('rock')) return 'Rock Falling';
  if (type.contains('snow')) return 'Snowfall';
  return 'Cloud Burst';
}

Color _getRiskColor(String risk) {
  if (risk.contains('HIGH')) return const Color(0xFFEF4444);
  if (risk.contains('MODERATE')) return Colors.orange;
  return Colors.green;
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
