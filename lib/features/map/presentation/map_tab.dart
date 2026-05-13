import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/core/services/location_service.dart';
import 'package:cloud_burst/core/services/prediction_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();
  final GlobalKey _headerKey = GlobalKey();
  static const String _appUserAgent = 'cloud_burst/1.0';
  static const Color _exactAreaColor = Color(0xFF0EA5E9);

  bool _isLocating = false;
  bool _isAnalyzing = false;
  bool _isMapReady = false;
  bool _tileLoadFailed = false;

  LatLng? _selectedPoint;
  LatLng? _lastSeededLocation;
  _RiskAnalysis? _analysis;
  int _analysisRequestId = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppStateScope.of(context);
    final currentLocation = LatLng(state.latitude, state.longitude);
    final headerHeight = _headerHeight;
    final chipTop = 16 + headerHeight + 12;
    final errorTop = chipTop + 54;

    _syncSeedLocation(currentLocation, state.selectedCity);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDFF1FF),
                  Color(0xFFF8FBFF),
                  Color(0xFFE6F5EA),
                ],
              ),
            ),
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  fallbackUrl: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                if (_analysis != null)
                  CircleLayer(
                    circles: _buildRiskCircles(_analysis!),
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation,
                      width: 18,
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedPoint != null)
                      Marker(
                        point: _selectedPoint!,
                        width: 42,
                        height: 42,
                        child: _SelectionMarker(
                          color: _analysis?.color ?? const Color(0xFF0F172A),
                          isLoading: _isAnalyzing,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF031525).withValues(alpha: 0.30),
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF031525).withValues(alpha: 0.22),
                  ],
                  stops: const [0, 0.18, 0.58, 1],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
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
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF031525).withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.20),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cloudburst Risk Monitor',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap anywhere to analyze risk at that location.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox( width: 12),
                    _LocateButton(
                      isLocating: _isLocating,
                      onPressed: _locateMe,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: chipTop,
                left: 16,
                right: 16,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _MapBadge(
                    icon: _isAnalyzing
                        ? Icons.touch_app_rounded
                        : Icons.radar_rounded,
                    text: _isAnalyzing
                        ? 'Analyzing selected point...'
                        : (_analysis?.riskLabel ?? 'No zone selected'),
                    color: _isAnalyzing ? null : _analysis?.color,
                  ),
                ),
              ),
              if (_tileLoadFailed)
                Positioned(
                  left: 16,
                  right: 16,
                  top: errorTop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED).withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Text(
                      'Map tiles failed to load. Restart the app so updated internet permissions are applied.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9A3412),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
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
  }

  double get _headerHeight {
    final context = _headerKey.currentContext;
    if (context == null) return 84;
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.height ?? 84;
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
          color: const Color(0xFF64748B),
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
    if (risk.contains('HIGH')) return const Color(0xFFDC2626);
    if (risk.contains('MODERATE')) return const Color(0xFFF97316);
    if (risk.contains('LOW')) return const Color(0xFF16A34A);
    return const Color(0xFF64748B);
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

    return [
      CircleMarker(
        point: analysis.point,
        radius: affectedRadius,
        useRadiusInMeter: true,
        color: affectedColor.withValues(alpha: 0.08),
        borderStrokeWidth: 2,
        borderColor: affectedColor.withValues(alpha: 0.22),
      ),
      CircleMarker(
        point: analysis.point,
        radius: exactRadius,
        useRadiusInMeter: true,
        color: _exactAreaColor.withValues(alpha: 0.20),
        borderStrokeWidth: 2.5,
        borderColor: _exactAreaColor.withValues(alpha: 0.92),
      ),
    ];
  }

}

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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.22),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

class _LocateButton extends StatelessWidget {
  final bool isLocating;
  final VoidCallback onPressed;

  const _LocateButton({
    required this.isLocating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocating ? null : onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.my_location_rounded, color: Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _MapBadge({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF031525).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    final theme = Theme.of(context);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            'Tap map to analyze area',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
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

  const _AnalysisSheet({
    required this.analysis,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = analysis?.color ?? const Color(0xFF0F172A);

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
              color: Colors.white.withValues(alpha: 0.97),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isLoading && analysis == null)
                      const SizedBox(
                        height: 82,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  analysis?.locationLabel ?? 'Analyzing...',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  analysis?.message ?? 'Checking live conditions...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF475569),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              analysis?.riskLabel ?? 'Loading',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _WeatherSignalCard(
                        analysis: analysis!,
                        color: color,
                      ),
                      const SizedBox(height: 14),
                      _ZoneLegendCard(
                        analysis: analysis!,
                        affectedColor: color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Live metrics',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MetricChip(
                            label: 'Rain chance',
                            value: '${analysis?.rainChance ?? '--'}%',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ConfidenceMeter(
                              value: analysis?.confidence ?? 0,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MetricChip(
                            label: 'Affected zone',
                            value: analysis == null
                                ? '--'
                                : _zoneLabel(analysis!.radiusMeters),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeatherSignalCard extends StatelessWidget {
  final _RiskAnalysis analysis;
  final Color color;

  const _WeatherSignalCard({
    required this.analysis,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _weatherIcon(analysis.weatherCondition),
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weatherHeadline(analysis.weatherCondition),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _weatherSubline(
                    analysis.weatherCondition,
                    analysis.rainChance,
                    analysis.riskLabel,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneLegendCard extends StatelessWidget {
  final _RiskAnalysis analysis;
  final Color affectedColor;

  const _ZoneLegendCard({
    required this.analysis,
    required this.affectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zone guide',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Each map color has one fixed meaning.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _LegendRow(
            color: _MapTabState._exactAreaColor,
            title: 'Exact analysis area',
            description:
                'The current risk calculation is based on this blue core zone.',
            value: _zoneLabel(analysis.exactRadiusMeters),
          ),
          const SizedBox(height: 12),
          _LegendRow(
            color: affectedColor,
            title: 'Affected area',
            description:
                'This outer zone shows how far nearby impact may extend.',
            value: _zoneLabel(analysis.radiusMeters),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String title;
  final String description;
  final String value;

  const _LegendRow({
    required this.color,
    required this.title,
    required this.description,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.90),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title • $value',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  final int value;
  final Color color;

  const _ConfidenceMeter({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0, 100);
    final activeBars = (normalized / 10).ceil().clamp(0, 10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confidence',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(10, (index) {
              final isActive = index < activeBars;
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: index == 9 ? 0 : 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.88)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$normalized%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _zoneLabel(double radiusMeters) {
  if (radiusMeters >= 1000) {
    return '${(radiusMeters / 1000).toStringAsFixed(radiusMeters % 1000 == 0 ? 0 : 1)} km hotspot';
  }
  return '${radiusMeters.round()} m hotspot';
}

IconData _weatherIcon(String condition) {
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

String _weatherHeadline(String condition) {
  switch (condition.toLowerCase()) {
    case 'clear':
      return 'Clear conditions';
    case 'clouds':
      return 'Cloud cover';
    case 'rain':
    case 'drizzle':
      return 'Rain expected';
    case 'thunderstorm':
      return 'Storm risk';
    case 'snow':
      return 'Snow conditions';
    case 'mist':
    case 'fog':
    case 'haze':
      return 'Low visibility';
    default:
      return condition;
  }
}

String _weatherSubline(String condition, int rainChance, String riskLabel) {
  if (condition.toLowerCase() == 'thunderstorm') {
    return 'Volatile cells detected with elevated local risk.';
  }
  if (rainChance >= 60) {
    return 'Rain bands look active near this mountain zone.';
  }
  if (riskLabel.contains('HIGH')) {
    return 'Localized instability warrants close monitoring.';
  }
  if (condition.toLowerCase() == 'clear') {
    return 'Clear skies now, but terrain conditions can shift quickly.';
  }
  return 'Current forecast suggests localized weather development.';
}

