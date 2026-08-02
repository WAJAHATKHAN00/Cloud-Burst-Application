import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/device_service.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/shared/widgets/section_title.dart';

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  String _type = 'Heavy Rain';
  double _intensity = 0.7;
  bool _isSubmitting = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Text(
              'SUBMIT REPORT',
              style: AppTheme.microLabel(
                fontSize: 17,
                color: AppTheme.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Share real-world observations and save them to Supabase.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.slate),
            ),
            const SizedBox(height: 16),
            const SectionTitle('INCIDENT TYPE'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TypeChip(
                  label: 'Cloud Burst',
                  selected: _type == 'Cloud Burst',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Cloud Burst'),
                ),
                _TypeChip(
                  label: 'Heavy Rain',
                  selected: _type == 'Heavy Rain',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Heavy Rain'),
                ),
                _TypeChip(
                  label: 'Flooding',
                  selected: _type == 'Flooding',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Flooding'),
                ),
                _TypeChip(
                  label: 'Landslide',
                  selected: _type == 'Landslide',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Landslide'),
                ),
                _TypeChip(
                  label: 'Rock Falling',
                  selected: _type == 'Rock Falling',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Rock Falling'),
                ),
                _TypeChip(
                  label: 'Snowfall',
                  selected: _type == 'Snowfall',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Snowfall'),
                ),
                _TypeChip(
                  label: 'River Overflow',
                  selected: _type == 'River Overflow',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'River Overflow'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Location row ──
            const SectionTitle('LOCATION'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: AppTheme.slate),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.selectedCity,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${state.latitude.toStringAsFixed(5)}, ${state.longitude.toStringAsFixed(5)}',
                          style: AppTheme.mono(
                            fontSize: 10,
                            color: AppTheme.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Mini map ──
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.divider, width: 0.5),
                ),
                child: _ReportLocationMap(
                  latitude: state.latitude,
                  longitude: state.longitude,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Intensity ──
            const SectionTitle('INTENSITY'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.divider, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelForIntensity(_intensity).toUpperCase(),
                    style: AppTheme.microLabel(
                      fontSize: 10,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.ink,
                      inactiveTrackColor: AppTheme.divider,
                      thumbColor: AppTheme.ink,
                      overlayColor: AppTheme.ink.withValues(alpha: 0.1),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _intensity,
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() => _intensity = value),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LOW',
                          style: AppTheme.microLabel(
                              fontSize: 9, color: AppTheme.slate)),
                      Text('MODERATE',
                          style: AppTheme.microLabel(
                              fontSize: 9, color: AppTheme.slate)),
                      Text('HIGH',
                          style: AppTheme.microLabel(
                              fontSize: 9, color: AppTheme.slate)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Photo & description ──
            const SectionTitle('REPORT DETAILS'),
            const SizedBox(height: 8),

            // Photo button row
            InkWell(
              onTap: _isSubmitting ? null : _pickPhoto,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.divider, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 18, color: AppTheme.slate),
                    const SizedBox(width: 8),
                    Text(
                      _selectedImage == null
                          ? 'ADD PHOTO'
                          : 'CHANGE PHOTO',
                      style: AppTheme.microLabel(
                        fontSize: 10,
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 18, color: AppTheme.slate),
                  ],
                ),
              ),
            ),

            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  _selectedImageBytes!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (_selectedImage != null) ...[
              const SizedBox(height: 4),
              Text(
                _selectedImage!.name,
                style: AppTheme.mono(fontSize: 10, color: AppTheme.slate),
              ),
            ],

            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 5,
              enabled: !_isSubmitting,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter report details.';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Describe what happened',
              ),
            ),

            const SizedBox(height: 24),

            // Submit button — the one filled button in the app
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _submitReport(context, state),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: AppTheme.paper,
                  disabledBackgroundColor: AppTheme.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.paper,
                        ),
                      )
                    : Text(
                        'SUBMIT REPORT',
                        style: AppTheme.microLabel(
                          fontSize: 12,
                          color: AppTheme.paper,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, AppState state) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final deviceId = await DeviceService.getDeviceId();
      String? imageUrl;

      if (_selectedImageBytes != null) {
        imageUrl = await SupabaseService.uploadReportImage(
          deviceId: deviceId,
          bytes: _selectedImageBytes!,
        );
      }

      await SupabaseService.saveReport(
        deviceId: deviceId,
        reportsType: _type,
        discription: _notesCtrl.text.trim(),
        intensity: _labelForIntensity(_intensity),
        locationName: state.selectedCity,
        latitude: state.latitude,
        longitude: state.longitude,
        imageUrl: imageUrl,
      );

      if (!context.mounted) return;

      _notesCtrl.clear();
      _selectedImage = null;
      _selectedImageBytes = null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Report submitted: $_type')));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick photo: $error')));
    }
  }

  String _labelForIntensity(double value) {
    if (value < 0.34) return 'Low intensity';
    if (value < 0.67) return 'Moderate intensity';
    return 'High intensity';
  }
}

class _ReportLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _ReportLocationMap({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 13,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.cloud_burst',
          tileProvider: NetworkTileProvider(
            headers: {'User-Agent': 'cloud_burst/1.0'},
            cachingProvider: const DisabledMapCachingProvider(),
          ),
          maxNativeZoom: 19,
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 18,
              height: 18,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.hazardRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.paper, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppTheme.ink : AppTheme.divider,
            width: 0.5,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTheme.microLabel(
            fontSize: 10,
            color: selected ? AppTheme.paper : AppTheme.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
