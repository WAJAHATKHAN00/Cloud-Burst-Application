import 'dart:async';

import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/location_service.dart';
import 'package:cloud_burst/core/services/prediction_service.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final GlobalKey _headerKey = GlobalKey();
  static const String _appUserAgent = 'cloud_burst/1.0';
  static const Color _exactAreaColor = Color(0xFF0EA5E9);
  static const Duration _approvedAlertLifetime = Duration(hours: 24);
  static const double _approvedAlertRadiusMeters = 420;
  late final AnimationController _pulseController;
  late final Stream<List<Map<String, dynamic>>> _approvedReportsStream;
  Timer? _approvedAlertExpiryTimer;

  bool _isLocating = false;
  bool _isAnalyzing = false;
  bool _isMapReady = false;
  bool _tileLoadFailed = false;

  LatLng? _selectedPoint;
  LatLng? _lastSeededLocation;
  _RiskAnalysis? _analysis;
  int _analysisRequestId = 0;

  @override
  void initState() {
    super.initState();
    _approvedReportsStream = SupabaseService.watchApprovedReports();
    _approvedAlertExpiryTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _pulseController.addListener(() {
      if (mounted && _analysis != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _approvedAlertExpiryTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final currentLocation = LatLng(state.latitude, state.longitude);
    final headerHeight = _headerHeight;
    final chipTop = 16 + headerHeight + 12;
    final errorTop = chipTop + 54;

    _syncSeedLocation(currentLocation, state.selectedCity);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _approvedReportsStream,
      builder: (context, snapshot) {
        final approvedAlerts = _activeApprovedAlerts(
          snapshot.data ?? const <Map<String, dynamic>>[],
        );

        return Stack(
          children: [
            // ── Map ──
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLocation,
                  initialZoom: 11,
                  onMapReady: () {
                    if (!mounted) return;
                    setState(() => _isMapReady = true);
                  },
                  onTap: (_, point) => _analyzeLocation(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    fallbackUrl:
                        'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.cloud_burst',
                    tileProvider: NetworkTileProvider(
                      headers: {'User-Agent': _appUserAgent},
                      cachingProvider: const DisabledMapCachingProvider(),
                    ),
                    maxNativeZoom: 19,
                    maxZoom: 19,
                    errorTileCallback: (tile, error, stackTrace) {
                      if (!mounted || _tileLoadFailed) return;
                      setState(() => _tileLoadFailed = true);
                    },
                  ),
                  if (approvedAlerts.isNotEmpty)
                    CircleLayer(
                      circles: _buildApprovedAlertCircles(approvedAlerts),
                    ),
                  if (_analysis != null)
                    CircleLayer(circles: _buildRiskCircles(_analysis!)),
                  MarkerLayer(
                    markers: [
                      ...approvedAlerts.map(
                        (alert) => Marker(
                          point: alert.point,
                          width: 18,
                          height: 18,
                          child: _ApprovedAlertMarker(alert: alert),
                        ),
                      ),
                      // Current location dot
                      Marker(
                        point: currentLocation,
                        width: 14,
                        height: 14,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.ink,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.paper,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedPoint != null)
                        Marker(
                          point: _selectedPoint!,
                          width: 24,
                          height: 24,
                          child: _SelectionMarker(
                            color:
                                _analysis?.color ?? AppTheme.ink,
                            isLoading: _isAnalyzing,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Top chrome ──
            SafeArea(
              child: Stack(
                children: [
                  // Header bar
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            key: _headerKey,
                            padding:
                                const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            decoration: BoxDecoration(
                              color: AppTheme.paper,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.divider,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RISK MONITOR',
                                  style: AppTheme.microLabel(
                                    fontSize: 13,
                                    color: AppTheme.ink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap anywhere to analyze risk.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.slate),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _LocateButton(
                          isLocating: _isLocating,
                          onPressed: _locateMe,
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: chipTop,
                    left: 16,
                    right: 16,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _MapBadge(
                        text: _isAnalyzing
                            ? 'Analyzing…'
                            : (_analysis?.riskLabel ?? 'No zone selected'),
                        color: _isAnalyzing ? null : _analysis?.color,
                      ),
                    ),
                  ),

                  // Approved alerts legend
                  if (approvedAlerts.isNotEmpty)
                    Positioned(
                      top: chipTop + 40,
                      right: 16,
                      child:
                          _ApprovedWarningsLegend(alerts: approvedAlerts),
                    ),

                  // Tile load error
                  if (_tileLoadFailed)
                    Positioned(
                      left: 16,
                      right: 16,
                      top: errorTop,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.paper,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.moderateOchre,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Map tiles failed to load. Restart the app so updated internet permissions are applied.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.moderateOchre),
                        ),
                      ),
                    ),

                  // Bottom analysis sheet
                  Positioned.fill(
                    child: _BottomOverlay(
                      analysis: _analysis,
                      isLoading: _isAnalyzing,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double get _headerHeight {
    final context = _headerKey.currentContext;
    if (context == null) return 60;
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.height ?? 60;
  }

  void _syncSeedLocation(LatLng currentLocation, String city) {
    final last = _lastSeededLocation;
    if (last != null &&
        last.latitude == currentLocation.latitude &&
        last.longitude == currentLocation.longitude) {
      return;
    }

    _lastSeededLocation = currentLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isMapReady) {
        _mapController.move(currentLocation, 11);
      }
      _analyzeLocation(currentLocation, cityOverride: city);
    });
  }

  Future<void> _analyzeLocation(LatLng point, {String? cityOverride}) async {
    final requestId = ++_analysisRequestId;

    setState(() {
      _selectedPoint = point;
      _isAnalyzing = true;
      _currentTileRetry();
      _analysis = _analysis?.copyWith(point: point);
    });

    try {
      final weatherFuture = WeatherService.fetchWeather(
        point.latitude,
        point.longitude,
      );
      final cityFuture = cityOverride == null
          ? WeatherService.getCityName(point.latitude, point.longitude)
          : Future<String>.value(cityOverride);

      final results = await Future.wait<dynamic>([weatherFuture, cityFuture]);
      final weather = results[0] as Map<String, dynamic>;
      final city = results[1] as String;

      final prediction = PredictionService.predict(weather);
      final message = PredictionService.getMessage(weather);
      final first = weather['list'][0] as Map<String, dynamic>;
      final weatherList = first['weather'] as List<dynamic>? ?? const [];
      final weatherCondition = weatherList.isNotEmpty
          ? ((weatherList.first as Map<String, dynamic>)['main'] ?? 'Clouds')
                .toString()
          : 'Clouds';

      final rainChance = ((((first['pop'] ?? 0) as num).toDouble()) * 100)
          .round();
      final confidence = prediction['confidence'] as int;
      final riskLabel = prediction['risk'] as String;
      final riskColor = _riskColor(riskLabel);

      if (!mounted || requestId != _analysisRequestId) return;

      setState(() {
        _analysis = _RiskAnalysis(
          point: point,
          locationLabel: _cityLabel(city),
          riskLabel: riskLabel,
          message: message,
          rainChance: rainChance,
          confidence: confidence,
          weatherCondition: weatherCondition,
          color: riskColor,
          exactRadiusMeters: _exactRadiusForRisk(riskLabel),
          radiusMeters: _radiusForRisk(riskLabel, confidence),
        );
      });
    } catch (_) {
      if (!mounted || requestId != _analysisRequestId) return;
      setState(() {
        _analysis = _RiskAnalysis(
          point: point,
          locationLabel: 'Selected Location',
          riskLabel: 'UNAVAILABLE',
          message: 'Forecast could not be loaded for this point.',
          rainChance: 0,
          confidence: 0,
          weatherCondition: 'Unknown',
          color: AppTheme.slate,
          exactRadiusMeters: 180,
          radiusMeters: 500,
        );
      });
    } finally {
      if (mounted && requestId == _analysisRequestId) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _currentTileRetry() {
    if (_tileLoadFailed) {
      _tileLoadFailed = false;
    }
  }

  Future<void> _locateMe() async {
    if (_isLocating) return;

    setState(() => _isLocating = true);

    try {
      final position = await LocationService.getLocation();
      if (!mounted) return;

      final state = AppStateScope.of(context);
      state.setLocation(position.latitude, position.longitude);
      final point = LatLng(position.latitude, position.longitude);

      if (_isMapReady) {
        _mapController.move(point, 13);
      }

      await _analyzeLocation(point);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  String _cityLabel(String city) {
    if (city.trim().isEmpty) return 'Selected Location';
    return city.split(',').first.trim();
  }

  Color _riskColor(String risk) {
    return AppTheme.severityColor(risk);
  }

  double _radiusForRisk(String risk, int confidence) {
    final normalizedConfidence = confidence.clamp(0, 100);
    if (risk.contains('HIGH')) {
      return 800 + (normalizedConfidence * 2);
    }
    if (risk.contains('MODERATE')) {
      return 500 + (normalizedConfidence * 3);
    }
    if (risk.contains('LOW')) {
      return 200 + (normalizedConfidence * 2);
    }
    return 500;
  }

  double _exactRadiusForRisk(String risk) {
    if (risk.contains('HIGH')) return 320;
    if (risk.contains('MODERATE')) return 240;
    if (risk.contains('LOW')) return 180;
    return 180;
  }

  List<CircleMarker> _buildRiskCircles(_RiskAnalysis analysis) {
    final affectedRadius = analysis.radiusMeters;
    final affectedColor = analysis.color;
    final exactRadius = analysis.exactRadiusMeters;
    final pulse = Curves.easeInOut.transform(_pulseController.value);
    final outerPulseRadius = affectedRadius * (1.04 + (pulse * 0.09));
    final exactPulseRadius = exactRadius * (1.02 + (pulse * 0.05));

    return [
      CircleMarker(
        point: analysis.point,
        radius: outerPulseRadius,
        useRadiusInMeter: true,
        color: affectedColor.withValues(alpha: 0.028 - (pulse * 0.010)),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: analysis.point,
        radius: affectedRadius * 0.9,
        useRadiusInMeter: true,
        color: affectedColor.withValues(alpha: 0.040),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: analysis.point,
        radius: affectedRadius * 0.72,
        useRadiusInMeter: true,
        color: affectedColor.withValues(alpha: 0.056),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: analysis.point,
        radius: affectedRadius * 0.54,
        useRadiusInMeter: true,
        color: affectedColor.withValues(alpha: 0.072),
        borderStrokeWidth: 0.8,
        borderColor: affectedColor.withValues(alpha: 0.08),
      ),
      CircleMarker(
        point: analysis.point,
        radius: exactPulseRadius,
        useRadiusInMeter: true,
        color: _exactAreaColor.withValues(alpha: 0.07),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: analysis.point,
        radius: exactRadius * 0.82,
        useRadiusInMeter: true,
        color: _exactAreaColor.withValues(alpha: 0.13),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: analysis.point,
        radius: exactRadius * 0.58,
        useRadiusInMeter: true,
        color: _exactAreaColor.withValues(alpha: 0.22),
        borderStrokeWidth: 1.2,
        borderColor: _exactAreaColor.withValues(alpha: 0.20),
      ),
    ];
  }

  List<_ApprovedMapAlert> _activeApprovedAlerts(
    List<Map<String, dynamic>> reports,
  ) {
    final now = DateTime.now();

    return reports
        .map(_ApprovedMapAlert.fromMap)
        .where((alert) {
          if (!alert.hasCoordinates) return false;

          final createdAt = alert.createdAt;
          if (createdAt == null) return false;

          final age = now.difference(createdAt.toLocal());
          return !age.isNegative && age < _approvedAlertLifetime;
        })
        .toList(growable: false);
  }

  List<CircleMarker> _buildApprovedAlertCircles(
    List<_ApprovedMapAlert> alerts,
  ) {
    return [
      for (final alert in alerts) ...[
        CircleMarker(
          point: alert.point,
          radius: _approvedAlertRadiusMeters * 1.38,
          useRadiusInMeter: true,
          color: alert.color.withValues(alpha: 0.035),
          borderStrokeWidth: 0,
        ),
        CircleMarker(
          point: alert.point,
          radius: _approvedAlertRadiusMeters,
          useRadiusInMeter: true,
          color: alert.color.withValues(alpha: 0.10),
          borderStrokeWidth: 1.2,
          borderColor: alert.color.withValues(alpha: 0.34),
        ),
        CircleMarker(
          point: alert.point,
          radius: _approvedAlertRadiusMeters * 0.48,
          useRadiusInMeter: true,
          color: alert.color.withValues(alpha: 0.18),
          borderStrokeWidth: 0,
        ),
      ],
    ];
  }
}

// ── Data models (unchanged logic) ─────────────────────────────────

class _RiskAnalysis {
  final LatLng point;
  final String locationLabel;
  final String riskLabel;
  final String message;
  final int rainChance;
  final int confidence;
  final String weatherCondition;
  final Color color;
  final double exactRadiusMeters;
  final double radiusMeters;

  const _RiskAnalysis({
    required this.point,
    required this.locationLabel,
    required this.riskLabel,
    required this.message,
    required this.rainChance,
    required this.confidence,
    required this.weatherCondition,
    required this.color,
    required this.exactRadiusMeters,
    required this.radiusMeters,
  });

  _RiskAnalysis copyWith({LatLng? point}) {
    return _RiskAnalysis(
      point: point ?? this.point,
      locationLabel: locationLabel,
      riskLabel: riskLabel,
      message: message,
      rainChance: rainChance,
      confidence: confidence,
      weatherCondition: weatherCondition,
      color: color,
      exactRadiusMeters: exactRadiusMeters,
      radiusMeters: radiusMeters,
    );
  }
}

class _ApprovedMapAlert {
  final LatLng point;
  final String reportType;
  final DateTime? createdAt;
  final bool hasCoordinates;

  const _ApprovedMapAlert({
    required this.point,
    required this.reportType,
    required this.createdAt,
    required this.hasCoordinates,
  });

  factory _ApprovedMapAlert.fromMap(Map<String, dynamic> map) {
    final latitude = _readDouble(map['latitude']);
    final longitude = _readDouble(map['longitude']);

    return _ApprovedMapAlert(
      point: LatLng(latitude ?? 0, longitude ?? 0),
      reportType: _readText(map['reports_type'], fallback: 'Warning'),
      createdAt: _readDate(map['created_at']),
      hasCoordinates:
          latitude != null &&
          longitude != null &&
          latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180,
    );
  }

  Color get color => _approvedReportColor(reportType);

  IconData get icon {
    final type = reportType.toLowerCase();
    if (type.contains('cloud burst') || type.contains('cloudburst')) {
      return Icons.thunderstorm_rounded;
    }
    if (type.contains('flood') || type.contains('overflow')) {
      return Icons.water_drop_rounded;
    }
    if (type.contains('landslide')) return Icons.landscape_rounded;
    if (type.contains('rock')) return Icons.terrain_rounded;
    if (type.contains('snow')) return Icons.ac_unit_rounded;
    return Icons.warning_amber_rounded;
  }

  String get legendLabel {
    final type = reportType.toLowerCase();
    if (type.contains('overflow')) return 'Overflow';
    if (type.contains('landslide')) return 'Landslide';
    if (type.contains('flood')) return 'Flood';
    if (type.contains('cloud burst') || type.contains('cloudburst')) {
      return 'Cloudburst';
    }
    if (type.contains('rain')) return 'Heavy Rain';
    return reportType;
  }

  static String _readText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

// ── Restyled chrome widgets ───────────────────────────────────────

class _ApprovedAlertMarker extends StatelessWidget {
  final _ApprovedMapAlert alert;

  const _ApprovedAlertMarker({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = alert.color;

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.paper, width: 2),
      ),
    );
  }
}

class _ApprovedWarningsLegend extends StatelessWidget {
  final List<_ApprovedMapAlert> alerts;

  const _ApprovedWarningsLegend({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final visibleTypes = <String, Color>{};
    for (final alert in alerts) {
      visibleTypes.putIfAbsent(alert.legendLabel, () => alert.color);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in visibleTypes.entries) ...[
            _ApprovedLegendRow(label: entry.key, color: entry.value),
            if (entry.key != visibleTypes.keys.last)
              const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _ApprovedLegendRow extends StatelessWidget {
  final String label;
  final Color color;

  const _ApprovedLegendRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.microLabel(
              fontSize: 9,
              color: AppTheme.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionMarker extends StatelessWidget {
  final Color color;
  final bool isLoading;

  const _SelectionMarker({required this.color, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.18),
            border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.paper, width: 2),
          ),
        ),
        if (isLoading)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppTheme.ink,
            ),
          ),
      ],
    );
  }
}

class _LocateButton extends StatelessWidget {
  final bool isLocating;
  final VoidCallback onPressed;

  const _LocateButton({required this.isLocating, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocating ? null : onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider, width: 0.5),
        ),
        child: Center(
          child: isLocating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              : const Icon(
                  Icons.my_location_rounded,
                  color: AppTheme.ink,
                  size: 20,
                ),
        ),
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const _MapBadge({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color ?? AppTheme.divider,
          width: 0.5,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTheme.microLabel(
          fontSize: 10,
          color: color ?? AppTheme.slate,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BottomOverlay extends StatelessWidget {
  final _RiskAnalysis? analysis;
  final bool isLoading;

  const _BottomOverlay({required this.analysis, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (analysis == null && !isLoading) {
      return const _BottomHint();
    }

    return _AnalysisSheet(analysis: analysis, isLoading: isLoading);
  }
}

class _BottomHint extends StatelessWidget {
  const _BottomHint();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.divider, width: 0.5),
          ),
          child: Text(
            'TAP MAP TO ANALYZE AREA',
            style: AppTheme.microLabel(
              fontSize: 10,
              color: AppTheme.slate,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisSheet extends StatelessWidget {
  final _RiskAnalysis? analysis;
  final bool isLoading;

  const _AnalysisSheet({required this.analysis, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final color = analysis?.color ?? AppTheme.ink;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.20,
        minChildSize: 0.14,
        maxChildSize: 0.42,
        snap: true,
        snapSizes: const [0.20, 0.42],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.paper,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: const Border(
                top: BorderSide(color: AppTheme.divider, width: 0.5),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading && analysis == null)
                  const SizedBox(
                    height: 82,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else ...[
                  // Location + risk label
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (analysis?.locationLabel ?? 'Analyzing…')
                                  .toUpperCase(),
                              style: AppTheme.microLabel(
                                fontSize: 13,
                                color: AppTheme.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              analysis?.message ??
                                  'Checking live conditions…',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.slate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: color, width: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (analysis?.riskLabel ?? 'LOADING').toUpperCase(),
                          style: AppTheme.microLabel(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Instrument rows
                  _SheetRow(
                    label: 'RAIN CHANCE',
                    value: '${analysis?.rainChance ?? '--'}%',
                  ),
                  _SheetRow(
                    label: 'CONFIDENCE',
                    value: '${analysis?.confidence ?? '--'}%',
                  ),
                  _SheetRow(
                    label: 'CONDITION',
                    value: analysis?.weatherCondition ?? '--',
                  ),
                  _SheetRow(
                    label: 'AFFECTED ZONE',
                    value: analysis == null
                        ? '--'
                        : _zoneLabel(analysis!.radiusMeters),
                  ),
                  _SheetRow(
                    label: 'EXACT AREA',
                    value: analysis == null
                        ? '--'
                        : _zoneLabel(analysis!.exactRadiusMeters),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;

  const _SheetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

// ── Helpers (unchanged logic) ─────────────────────────────────────

String _zoneLabel(double radiusMeters) {
  if (radiusMeters >= 1000) {
    return '${(radiusMeters / 1000).toStringAsFixed(radiusMeters % 1000 == 0 ? 0 : 1)} km';
  }
  return '${radiusMeters.round()} m';
}

Color _approvedReportColor(String reportType) {
  final type = reportType.toLowerCase();
  if (type.contains('overflow')) return AppTheme.hazardRed;
  if (type.contains('landslide')) return const Color(0xFF2563EB);
  if (type.contains('flood')) return const Color(0xFF2E7D32);
  if (type.contains('cloud burst') || type.contains('cloudburst')) {
    return AppTheme.moderateOchre;
  }
  if (type.contains('rain')) return const Color(0xFF7C3AED);
  if (type.contains('rock')) return const Color(0xFF78716C);
  if (type.contains('snow')) return const Color(0xFF0284C7);
  return AppTheme.hazardRed;
}


