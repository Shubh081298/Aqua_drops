import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceStatusModel {
  const DeviceStatusModel({
    required this.waterLevelPercent,
    required this.levelValidity,
    required this.motorState,
    required this.motorMode,
    required this.hubStatus,
    required this.activeAlertCount,
    required this.inletFlowDetected,
    this.motorRunningSince,
    this.motorCurrentAmps,
    this.motorConfirmedRunning = false,
    this.rssi,
    this.lastSeenAt,
  });

  final int     waterLevelPercent;
  final String  levelValidity;
  final String  motorState;
  final String  motorMode;
  final String  hubStatus;
  final int     activeAlertCount;
  final bool    inletFlowDetected;
  final DateTime? motorRunningSince;
  final double?   motorCurrentAmps;
  final bool      motorConfirmedRunning;
  final int?      rssi;
  final DateTime? lastSeenAt;

  bool get isOnline => hubStatus == 'online';

  bool get isStale {
    if (lastSeenAt == null) return true;
    return DateTime.now().difference(lastSeenAt!) >
        const Duration(minutes: 5);
  }

  String get levelLabel => switch (waterLevelPercent) {
    0        => 'Empty',
    <= 25    => 'Low',
    <= 50    => 'Half',
    <= 75    => 'Good',
    <= 99    => 'High',
    _        => 'Full',
  };

  factory DeviceStatusModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return DeviceStatusModel(
      waterLevelPercent:    (d['waterLevelPercent']    as num?)?.toInt() ?? 0,
      levelValidity:        d['levelValidity']          as String? ?? 'unknown',
      motorState:           d['motorState']             as String? ?? 'unknown',
      motorMode:            d['motorMode']              as String? ?? 'auto',
      hubStatus:            d['hubStatus']              as String? ?? 'offline',
      activeAlertCount:     (d['activeAlertCount']      as num?)?.toInt() ?? 0,
      inletFlowDetected:    d['inletFlowDetected']      as bool?   ?? false,
      motorRunningSince:    (d['motorRunningSince']     as Timestamp?)?.toDate(),
      motorCurrentAmps:     (d['motorCurrentAmps']      as num?)?.toDouble(),
      motorConfirmedRunning: d['motorConfirmedRunning'] as bool?   ?? false,
      rssi:                 (d['rssi']                  as num?)?.toInt(),
      lastSeenAt:           (d['lastSeenAt']            as Timestamp?)?.toDate(),
    );
  }
}
