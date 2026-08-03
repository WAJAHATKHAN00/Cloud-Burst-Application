import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_burst/app/routing/routes.dart';
import 'package:cloud_burst/app/state/app_state.dart';
import 'package:cloud_burst/app/theme/app_theme.dart';
import 'package:cloud_burst/core/services/device_service.dart';
import 'package:cloud_burst/core/services/location_service.dart';
import 'package:cloud_burst/core/services/supabase_service.dart';
import 'package:cloud_burst/core/services/weather_service.dart';
import 'package:cloud_burst/shared/widgets/cloud_background.dart';
import 'package:cloud_burst/shared/widgets/secondary_button.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  static Future<void> _finishLocationSetup(
    AppState state,
    double lat,
    double lng,
  ) async {
    try {
      final results = await Future.wait([
        DeviceService.getDeviceId(),
        WeatherService.getCityName(lat, lng),
      ]);

      final deviceId = results[0];
      final cityName = results[1];
      if (cityName.isNotEmpty) {
        state.setSelectedCity(cityName);
        state.setDeviceLocation(lat, lng, cityName);
      }

      await SupabaseService.saveDeviceLocation(
        deviceId: deviceId,
        lat: lat,
        lng: lng,
      ).timeout(const Duration(seconds: 10));
    } catch (error) {
      debugPrint('Failed to finish location setup: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Outlined location icon
                Icon(
                  Icons.location_on_outlined,
                  size: 42,
                  color: AppTheme.ink,
                ),
                const SizedBox(height: 16),
                // Tracked heading
                Text(
                  'ENABLE LOCATION ACCESS',
                  style: AppTheme.microLabel(
                    fontSize: 17,
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // Explanatory text
                Text(
                  'Cloudburst risk is calculated from\nyour exact position. Location stays\non-device except when you submit a report.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                        height: 1.5,
                      ),
                ),
                const Spacer(),
                // Allow location button (outlined)
                SecondaryButton(
                  label: 'ALLOW LOCATION ACCESS',
                  onPressed: () async {
                    final state = AppStateScope.of(context);

                    try {
                      final position = await LocationService.getLocation();
                      final lat = position.latitude;
                      final lng = position.longitude;

                      state.setLocation(lat, lng);
                      final defaultCity = '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';
                      state.setSelectedCity(defaultCity);
                      state.setDeviceLocation(lat, lng, defaultCity);
                      state.setLocationGranted(true);

                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, Routes.shell);

                      // Network-only enrichment must not prevent app entry.
                      unawaited(_finishLocationSetup(state, lat, lng));
                    } catch (error) {
                      debugPrint('Error: $error');
                      if (!context.mounted) return;

                      if (error is TimeoutException) {
                        // A first GPS fix can take a long time indoors.  The app
                        // already has a safe default city, so do not trap users
                        // on this screen while the device is still acquiring one.
                        state.setLocationGranted(true);
                        Navigator.pushReplacementNamed(context, Routes.shell);
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                // "Enter city manually" text link
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.citySearch),
                    child: Text(
                      'Enter city manually',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.slate,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.slate,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
