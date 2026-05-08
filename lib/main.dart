import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:cloud_burst/app/app.dart';
import 'package:cloud_burst/core/services/device_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final deviceId = await DeviceService.getDeviceId();
  print('Device ID: $deviceId');

  runApp(const CloudBurstApp());
}
