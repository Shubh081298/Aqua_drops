import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  const AlertModel({
    required this.alertId,
    required this.deviceId,
    required this.customerId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  final String    alertId;
  final String    deviceId;
  final String    customerId;
  final String    alertType;
  final String    severity;
  final String    message;
  final String    status;
  final DateTime  createdAt;
  final DateTime? acknowledgedAt;
  final String?   acknowledgedBy;

  bool get isActive    => status == 'active';
  bool get isCritical  => severity == 'critical';

  factory AlertModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return AlertModel(
      alertId:        doc.id,
      deviceId:       d['deviceId']       as String,
      customerId:     d['customerId']     as String,
      alertType:      d['alertType']      as String,
      severity:       d['severity']       as String? ?? 'warning',
      message:        d['message']        as String? ?? '',
      status:         d['status']         as String? ?? 'active',
      createdAt:      (d['createdAt']     as Timestamp).toDate(),
      acknowledgedAt: (d['acknowledgedAt']as Timestamp?)?.toDate(),
      acknowledgedBy: d['acknowledgedBy'] as String?,
    );
  }
}
