import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _deviceLocationTable = 'Device_location';
  static const String _reportTable = 'Report';
  static const String _reportImagesBucket = 'image_url';

  static Future<void> _ensureSignedIn() async {
    final auth = Supabase.instance.client.auth;
    if (auth.currentSession != null) return;

    await auth.signInAnonymously();
  }

  static Future<void> saveDeviceLocation({
    required String deviceId,
    required double lat,
    required double lng,
  }) async {
    await _ensureSignedIn();

    await Supabase.instance.client.from(_deviceLocationTable).insert({
      'device_id': deviceId,
      'latitude': lat,
      'longitude': lng,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static Future<void> saveReport({
    required String deviceId,
    required String reportsType,
    required String discription,
    required String intensity,
    required String locationName,
    required double latitude,
    required double longitude,
    String? imageUrl,
    String status = 'Submitted',
  }) async {
    await _ensureSignedIn();

    await Supabase.instance.client.from(_reportTable).insert({
      'reports_type': reportsType,
      'discription': discription,
      'intensity': intensity,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'device_id': deviceId,
      'image_url': imageUrl,
    });
  }

  static Future<String> uploadReportImage({
    required String deviceId,
    required Uint8List bytes,
  }) async {
    await _ensureSignedIn();

    final filePath =
        '$deviceId/${DateTime.now().toUtc().millisecondsSinceEpoch}.jpg';

    await Supabase.instance.client.storage
        .from(_reportImagesBucket)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return Supabase.instance.client.storage
        .from(_reportImagesBucket)
        .getPublicUrl(filePath);
  }
}
