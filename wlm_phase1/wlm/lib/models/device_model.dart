import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../core/constants/app_constants.dart';

// ── Device metadata ────────────────────────────────────────────────────────────
class DeviceModel extends Equatable {
  const DeviceModel({
    required this.deviceId,
    required this.hardwareId,
    required this.customerId,
    required this.deviceName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.configVersion,
    this.location,
  });

  final String   deviceId;
  final String   hardwareId;
  final String   customerId;
  final String   deviceName;
  final String?  location;
  final String   status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int      configVersion;

  bool get isActive => status == AppConstants.statusActive;

  factory DeviceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return DeviceModel(
      deviceId:      doc.id,
      hardwareId:    d['hardwareId']    as String? ?? '',
      customerId:    d['customerId']    as String? ?? '',
      deviceName:    d['deviceName']    as String? ?? '',
      location:      d['location']      as String?,
      status:        d['status']        as String? ?? AppConstants.statusActive,
      configVersion: d['configVersion'] as int?    ?? 1,
      createdAt:     (d['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:     (d['updatedAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'hardwareId':    hardwareId,
    'customerId':    customerId,
    'deviceName':    deviceName,
    'location':      location,
    'status':        status,
    'configVersion': configVersion,
    'updatedAt':     FieldValue.serverTimestamp(),
  };

  @override
  List<Object?> get props => [deviceId, hardwareId, customerId, deviceName, status];
}

// ── Device current status (live Firestore stream) ──────────────────────────────
class DeviceStatusModel extends Equatable {
  const DeviceStatusModel({
    required this.waterLevelPercent,
    required this.levelValidity,
    required this.inletFlowDetected,
    required this.motorState,
    required this.motorMode,
    required this.controllerState,
    required this.hubStatus,
    required this.activeAlertCount,
    this.motorRunningSince,
    this.motorCurrentAmps,
    this.motorConfirmedRunning = false,
    this.loraStatus,
    this.rssi,
    this.lastSeenAt,
    this.lastReadingAt,
  });

  /// Water level in discrete steps: 0, 25, 50, 75, 100
  final int     waterLevelPercent;
  final String  levelValidity;        // valid | fault | stale | unknown
  final bool    inletFlowDetected;
  final String  motorState;           // idle | requested | running | stopping | cooldown | fault
  final String  motorMode;            // auto | manual
  final String  controllerState;
  final String  hubStatus;            // online | offline
  final int     activeAlertCount;

  /// Motor run start time — only valid if motorState == running/requested
  final DateTime? motorRunningSince;

  /// CT sensor: current draw in Amps — null if CT not yet read
  final double? motorCurrentAmps;

  /// True when CT confirms current > AppConstants.ctRunningThresholdAmps
  final bool motorConfirmedRunning;

  final String?   loraStatus;
  final int?      rssi;
  final DateTime? lastSeenAt;
  final DateTime? lastReadingAt;

  bool get isOnline => hubStatus == 'online';

  bool get isStale {
    if (lastSeenAt == null) return true;
    return DateTime.now().difference(lastSeenAt!) >
        Duration(minutes: AppConstants.staleThresholdMin);
  }

  bool get isLevelValid => levelValidity == AppConstants.levelValid;

  /// Human-readable label for the current level.
  String get levelLabel {
    if (!isLevelValid) return 'Unknown';
    return switch (waterLevelPercent) {
      0        => 'Empty',
      <= 25    => 'Low',
      <= 50    => 'Half',
      <= 75    => 'Good',
      <= 99    => 'High',
      _        => 'Full',
    };
  }

  factory DeviceStatusModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return DeviceStatusModel(
      waterLevelPercent:    (d['waterLevelPercent']    as num?)?.toInt() ?? 0,
      levelValidity:        d['levelValidity']          as String? ?? AppConstants.levelUnknown,
      inletFlowDetected:    d['inletFlowDetected']      as bool?   ?? false,
      motorState:           d['motorState']             as String? ?? AppConstants.motorUnknown,
      motorMode:            d['motorMode']              as String? ?? AppConstants.motorModeAuto,
      controllerState:      d['controllerState']        as String? ?? AppConstants.motorUnknown,
      hubStatus:            d['hubStatus']              as String? ?? 'offline',
      activeAlertCount:     (d['activeAlertCount']      as num?)?.toInt() ?? 0,
      motorRunningSince:    (d['motorRunningSince']     as Timestamp?)?.toDate(),
      motorCurrentAmps:     (d['motorCurrentAmps']      as num?)?.toDouble(),
      motorConfirmedRunning: d['motorConfirmedRunning'] as bool?   ?? false,
      loraStatus:           d['loraStatus']             as String?,
      rssi:                 (d['rssi']                  as num?)?.toInt(),
      lastSeenAt:           (d['lastSeenAt']            as Timestamp?)?.toDate(),
      lastReadingAt:        (d['lastReadingAt']         as Timestamp?)?.toDate(),
    );
  }

  @override
  List<Object?> get props => [
    waterLevelPercent, levelValidity, inletFlowDetected,
    motorState, motorMode, motorConfirmedRunning,
    motorCurrentAmps, hubStatus, activeAlertCount,
  ];
}

// ── Device configuration ───────────────────────────────────────────────────────
class DeviceConfigModel extends Equatable {
  const DeviceConfigModel({
    required this.minLevelPercent,
    required this.maxLevelPercent,
    required this.motorEnabled,
    required this.inletTimeoutMinutes,
    required this.cooldownMinutes,
    required this.configVersion,
    required this.updatedAt,
    this.updatedBy,
  });

  final int      minLevelPercent;
  final int      maxLevelPercent;
  final bool     motorEnabled;
  final int      inletTimeoutMinutes;
  final int      cooldownMinutes;
  final int      configVersion;
  final DateTime updatedAt;
  final String?  updatedBy;

  bool get isValid => minLevelPercent < maxLevelPercent;

  factory DeviceConfigModel.defaults() => DeviceConfigModel(
    minLevelPercent:    AppConstants.defaultMinLevel,
    maxLevelPercent:    AppConstants.defaultMaxLevel,
    motorEnabled:       AppConstants.defaultMotorEnabled,
    inletTimeoutMinutes:AppConstants.defaultInletTimeoutMin,
    cooldownMinutes:    AppConstants.defaultCooldownMin,
    configVersion:      1,
    updatedAt:          DateTime.now(),
  );

  factory DeviceConfigModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return DeviceConfigModel(
      minLevelPercent:     (d['minLevelPercent']      as num?)?.toInt() ?? AppConstants.defaultMinLevel,
      maxLevelPercent:     (d['maxLevelPercent']      as num?)?.toInt() ?? AppConstants.defaultMaxLevel,
      motorEnabled:        d['motorEnabled']           as bool?          ?? AppConstants.defaultMotorEnabled,
      inletTimeoutMinutes: (d['inletTimeoutMinutes']  as num?)?.toInt() ?? AppConstants.defaultInletTimeoutMin,
      cooldownMinutes:     (d['cooldownMinutes']       as num?)?.toInt() ?? AppConstants.defaultCooldownMin,
      configVersion:       (d['configVersion']         as num?)?.toInt() ?? 1,
      updatedAt:           (d['updatedAt']             as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy:           d['updatedBy']              as String?,
    );
  }

  Map<String, dynamic> toFirestore(String updatedByUid) => {
    'minLevelPercent':     minLevelPercent,
    'maxLevelPercent':     maxLevelPercent,
    'motorEnabled':        motorEnabled,
    'inletTimeoutMinutes': inletTimeoutMinutes,
    'cooldownMinutes':     cooldownMinutes,
    'configVersion':       configVersion + 1,
    'updatedAt':           FieldValue.serverTimestamp(),
    'updatedBy':           updatedByUid,
  };

  DeviceConfigModel copyWith({
    int?  minLevelPercent,
    int?  maxLevelPercent,
    bool? motorEnabled,
    int?  inletTimeoutMinutes,
    int?  cooldownMinutes,
  }) {
    return DeviceConfigModel(
      minLevelPercent:     minLevelPercent     ?? this.minLevelPercent,
      maxLevelPercent:     maxLevelPercent     ?? this.maxLevelPercent,
      motorEnabled:        motorEnabled        ?? this.motorEnabled,
      inletTimeoutMinutes: inletTimeoutMinutes ?? this.inletTimeoutMinutes,
      cooldownMinutes:     cooldownMinutes     ?? this.cooldownMinutes,
      configVersion:       configVersion,
      updatedAt:           DateTime.now(),
      updatedBy:           updatedBy,
    );
  }

  @override
  List<Object?> get props => [
    minLevelPercent, maxLevelPercent, motorEnabled,
    inletTimeoutMinutes, cooldownMinutes, configVersion,
  ];
}
