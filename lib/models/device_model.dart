import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  const DeviceModel({
    required this.deviceId,
    required this.customerId,
    required this.deviceName,
    required this.status,
    required this.createdAt,
    this.location,
    this.hardwareId,
  });

  final String   deviceId;
  final String   customerId;
  final String   deviceName;
  final String?  location;
  final String?  hardwareId;
  final String   status;
  final DateTime createdAt;

  bool get isActive => status == 'active';

  factory DeviceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return DeviceModel(
      deviceId:   doc.id,
      customerId: d['customerId'] as String? ?? '',
      deviceName: d['deviceName'] as String? ?? '',
      location:   d['location']   as String?,
      hardwareId: d['hardwareId'] as String?,
      status:     d['status']     as String? ?? 'active',
      createdAt:  (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'customerId': customerId,
    'deviceName': deviceName,
    'location':   location,
    'hardwareId': hardwareId,
    'status':     status,
    'createdAt':  FieldValue.serverTimestamp(),
  };
}
