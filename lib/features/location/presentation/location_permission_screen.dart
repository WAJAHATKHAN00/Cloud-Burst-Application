import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/core/services/device_service.dart';
import 'package:cloud_burst/core/services/location_service.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';
import 'package:cloud_burst/shared/widgets/primary_button.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Location Access')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.10)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 48,
                        color: cs.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enable location for accurate alerts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We use your location to show local weather and cloudburst risk in real time.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Allow Location',
                  icon: Icons.my_location_rounded,
                  onPressed: () async {
                    final state = AppStateScope.of(context);

                    try {
                      final position = await LocationService.getLocation();
                      final lat = position.latitude;
                      final lng = position.longitude;
                      final deviceId = await DeviceService.getDeviceId();

                      state.setLocation(lat, lng);

                      final cityName = await WeatherService.getCityName(lat, lng);
                      state.setSelectedCity(
                        cityName.isEmpty
                            ? '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}'
                            : cityName,
                      );
                      state.setLocationGranted(true);

                      try {
                        await SupabaseService.saveDeviceLocation(
                          deviceId: deviceId,
                          lat: lat,
                          lng: lng,
                        );
                      } catch (error) {
                        debugPrint('Failed to save device location: $error');
                      }

                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, Routes.shell);
                    } catch (error) {
                      debugPrint('Error: $error');
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
