import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/device_model.dart';
import '../../../models/device_status_model.dart';
import '../../../models/device_config_model.dart';

// Current logged-in user's device (first device found for their customer)
final userDeviceProvider = StreamProvider<DeviceModel?>((ref) async* {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) { yield null; return; }

  final userDoc = await FirebaseFirestore.instance
      .collection('users').doc(uid).get();
  final customerId = userDoc.data()?['customerId'] as String?;
  if (customerId == null) { yield null; return; }

  yield* FirebaseFirestore.instance
      .collection('devices')
      .where('customerId', isEqualTo: customerId)
      .where('status', isEqualTo: 'active')
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isEmpty
          ? null
          : DeviceModel.fromFirestore(
              snap.docs.first as DocumentSnapshot<Map<String, dynamic>>));
});

// Stream device status (live updates every 60s from hub)
final deviceStatusProvider =
    StreamProvider.family<DeviceStatusModel?, String>((ref, deviceId) {
  return FirebaseFirestore.instance
      .collection('devices')
      .doc(deviceId)
      .collection('status')
      .doc('current')
      .snapshots()
      .map((snap) => snap.exists
          ? DeviceStatusModel.fromFirestore(
              snap as DocumentSnapshot<Map<String, dynamic>>)
          : null);
});

// Device config
final deviceConfigProvider =
    StreamProvider.family<DeviceConfigModel, String>((ref, deviceId) {
  return FirebaseFirestore.instance
      .collection('devices')
      .doc(deviceId)
      .collection('config')
      .doc('settings')
      .snapshots()
      .map((snap) => snap.exists
          ? DeviceConfigModel.fromFirestore(
              snap as DocumentSnapshot<Map<String, dynamic>>)
          : DeviceConfigModel.defaults());
});

// Motor command sender
Future<void> sendMotorCommand(String deviceId, String command) async {
  await FirebaseFirestore.instance
      .collection('devices')
      .doc(deviceId)
      .collection('commands')
      .add({
    'commandType':   command,
    'requestedBy':   FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
    'requestedMode': 'manual',
    'status':        'pending',
    'createdAt':     FieldValue.serverTimestamp(),
    'expiresAt':     Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 2))),
  });
}
