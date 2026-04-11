// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirestoreService {
//   static Future<void> saveDeviceLocation({
//     required String deviceId,
//     required double lat,
//     required double lng,
//   }) async {
//     await FirebaseFirestore.instance
//         .collection('devices')
//         .doc(deviceId)
//         .set({
//       "deviceId": deviceId,
//       "latitude": lat,
//       "longitude": lng,
//       "timestamp": FieldValue.serverTimestamp(),
//     });
//   }
// }