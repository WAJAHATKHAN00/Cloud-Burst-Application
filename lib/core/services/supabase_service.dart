import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _deviceLocationTable = 'Device_location';

  static Future<void> saveDeviceLocation({
    required String deviceId,
    required double lat,
    required double lng,
  }) async {
    await Supabase.instance.client.from(_deviceLocationTable).insert({
      'device_id': deviceId,
      'latitude': lat,
      'longitude': lng,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
