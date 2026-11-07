import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _db = FirebaseFirestore.instance;

// Simplified — no composite index needed
final totalCustomersProvider = StreamProvider<int>((ref) {
  return _db
      .collection('users')
      .where('role', isEqualTo: 'customer_admin')
      .snapshots()
      .map((s) => s.size);
});

final totalDevicesProvider = StreamProvider<int>((ref) {
  return _db.collection('tanks').snapshots().map((s) => s.size);
});

final onlineDevicesProvider = StreamProvider<int>((ref) {
  return _db
      .collection('tanks')
      .where('status', isEqualTo: 'online')
      .snapshots()
      .map((s) => s.size);
});

final activeAlertsProvider = StreamProvider<int>((ref) {
  return _db
      .collection('tanks')
      .where('alert', isEqualTo: true)
      .snapshots()
      .map((s) => s.size);
});

// No orderBy — avoids composite index requirement
final recentCustomersProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db
      .collection('users')
      .where('role', isEqualTo: 'customer_admin')
      .limit(10)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});
