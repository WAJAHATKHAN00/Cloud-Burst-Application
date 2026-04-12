import 'package:flutter/material.dart';
import '../app_state.dart';
import '../routes.dart';
import '../widgets/cloud_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'package:cloud_burst/services/location_service.dart';
import 'package:cloud_burst/services/firestore_service.dart';
import 'package:cloud_burst/services/device_service.dart';

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
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cs.primary.withOpacity(0.10)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.my_location_rounded, size: 48, color: cs.primary),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
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
                    try {
                      var position = await LocationService.getLocation();

                      double lat = position.latitude;
                      double lng = position.longitude;

                      String deviceId = await DeviceService.getDeviceId();

                      await FirestoreService.saveDeviceLocation(
                        deviceId: deviceId,
                        lat: lat,
                        lng: lng,
                      );

                      print("Saved to Firebase");

                      final state = AppStateScope.of(context);
                      state.setLocationGranted(true);

                      Navigator.pushReplacementNamed(context, Routes.shell);

                    } catch (e) {
                      print("Error: $e");
                    }
                  },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Continue Without Location',
                  onPressed: () {
                    final state = AppStateScope.of(context);
                    state.setLocationGranted(false);
                    Navigator.pushReplacementNamed(context, Routes.shell);
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
