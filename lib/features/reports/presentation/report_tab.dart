import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:cloud_burst/app/state/app_state.dart';
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
    final cs = Theme.of(context).colorScheme;
    final state = AppStateScope.of(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Report Incident',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Share real-world observations and save them to Supabase.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const SectionTitle('Select incident type'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _TypeChip(
                  label: 'Heavy Rain',
                  icon: Icons.cloud_rounded,
                  selected: _type == 'Heavy Rain',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Heavy Rain'),
                ),
                _TypeChip(
                  label: 'Flooding',
                  icon: Icons.water_drop_rounded,
                  selected: _type == 'Flooding',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Flooding'),
                ),
                _TypeChip(
                  label: 'Landslide',
                  icon: Icons.landscape_rounded,
                  selected: _type == 'Landslide',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Landslide'),
                ),
                _TypeChip(
                  label: 'Rock Falling',
                  icon: Icons.terrain_rounded,
                  selected: _type == 'Rock Falling',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Rock Falling'),
                ),
                _TypeChip(
                  label: 'Snowfall',
                  icon: Icons.ac_unit_rounded,
                  selected: _type == 'Snowfall',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'Snowfall'),
                ),
                _TypeChip(
                  label: 'River Overflow',
                  icon: Icons.waves_rounded,
                  selected: _type == 'River Overflow',
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _type = 'River Overflow'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionTitle('Location'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.my_location_rounded, color: cs.primary),
                    title: Text(state.selectedCity),
                    subtitle: Text(
                      'Lat: ${state.latitude.toStringAsFixed(5)}, Lng: ${state.longitude.toStringAsFixed(5)}',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: _ReportLocationMap(
                      latitude: state.latitude,
                      longitude: state.longitude,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionTitle('Intensity'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labelForIntensity(_intensity),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Slider(
                      value: _intensity,
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() => _intensity = value),
                    ),
                    Text(
                      'Low - Moderate - High',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionTitle('Report details'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : _pickPhoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(
                              _selectedImage == null
                                  ? 'Add Photo'
                                  : 'Change Photo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _selectedImage!.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
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
                        prefixIcon: Icon(Icons.notes_rounded),
                        hintText: 'Describe what happened',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _submitReport(context, state),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Report',
                ),
              ),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted: $_type')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick photo: $error')),
      );
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

  const _ReportLocationMap({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 150,
        child: FlutterMap(
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
                  width: 42,
                  height: 42,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFEF4444),
                    size: 38,
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

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.35)
                : cs.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? cs.primary : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? cs.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
