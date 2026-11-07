import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../core/constants/app_constants.dart';

// ── Alert ─────────────────────────────────────────────────────────────────────
class AlertModel extends Equatable {
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
    this.resolvedAt,
    this.resolvedBy,
  });

  final String    alertId;
  final String    deviceId;
  final String    customerId;
  final String    alertType;   // see AppConstants.alert*
  final String    severity;    // critical | warning | info
  final String    message;
  final String    status;      // active | acknowledged | resolved | archived
  final DateTime  createdAt;
  final DateTime? acknowledgedAt;
  final String?   acknowledgedBy;
  final DateTime? resolvedAt;
  final String?   resolvedBy;

  bool get isActive       => status == AppConstants.alertActive;
  bool get isAcknowledged => status == AppConstants.alertAcknowledged;
  bool get isResolved     => status == AppConstants.alertResolved;
  bool get isCritical     => severity == 'critical';

  factory AlertModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return AlertModel(
      alertId:         doc.id,
      deviceId:        d['deviceId']       as String,
      customerId:      d['customerId']     as String,
      alertType:       d['alertType']      as String,
      severity:        d['severity']       as String? ?? 'warning',
      message:         d['message']        as String? ?? '',
      status:          d['status']         as String? ?? AppConstants.alertActive,
      createdAt:       (d['createdAt']     as Timestamp).toDate(),
      acknowledgedAt:  (d['acknowledgedAt']as Timestamp?)?.toDate(),
      acknowledgedBy:  d['acknowledgedBy'] as String?,
      resolvedAt:      (d['resolvedAt']    as Timestamp?)?.toDate(),
      resolvedBy:      d['resolvedBy']     as String?,
    );
  }

  @override
  List<Object?> get props => [alertId, deviceId, alertType, status];
}

// ── History reading ───────────────────────────────────────────────────────────
class HistoryModel extends Equatable {
  const HistoryModel({
    required this.readingId,
    required this.deviceId,
    required this.waterLevelPercent,
    required this.inletFlowDetected,
    required this.motorState,
    required this.recordedAt,
    required this.receivedAt,
    required this.quality,
    required this.schemaVersion,
    this.motorCurrentAmps,
    this.motorConfirmedRunning = false,
  });

  final String   readingId;
  final String   deviceId;
  /// Discrete value: 0 | 25 | 50 | 75 | 100
  final int      waterLevelPercent;
  final bool     inletFlowDetected;
  final String   motorState;
  final DateTime recordedAt;   // device timestamp
  final DateTime receivedAt;   // server timestamp (use for ordering)
  final String   quality;      // valid | fault | stale
  final int      schemaVersion;
  final double?  motorCurrentAmps;
  final bool     motorConfirmedRunning;

  factory HistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return HistoryModel(
      readingId:            doc.id,
      deviceId:             d['deviceId']             as String,
      waterLevelPercent:    (d['waterLevelPercent']   as num).toInt(),
      inletFlowDetected:    d['inletFlowDetected']    as bool? ?? false,
      motorState:           d['motorState']            as String,
      recordedAt:           (d['recordedAt']          as Timestamp).toDate(),
      receivedAt:           (d['receivedAt']          as Timestamp).toDate(),
      quality:              d['quality']               as String? ?? 'valid',
      schemaVersion:        (d['schemaVersion']       as num?)?.toInt() ?? 1,
      motorCurrentAmps:     (d['motorCurrentAmps']    as num?)?.toDouble(),
      motorConfirmedRunning: d['motorConfirmedRunning']as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [readingId, deviceId, waterLevelPercent, receivedAt];
}
