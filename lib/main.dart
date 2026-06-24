import 'package:cloud_burst/app/app.dart';
import 'package:cloud_burst/core/services/device_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iuihbxwiyjpyidtnvnyg.supabase.co',
    anonKey: 'sb_publishable_hfwHWr_Vw1SybxeKz4Srlg_1Ox7zvLZ',
  );

  final deviceId = await DeviceService.getDeviceId();
  print('Device ID: $deviceId');

  runApp(const CloudBurstApp());
}
