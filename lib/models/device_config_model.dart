import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceConfigModel {
  const DeviceConfigModel({
    required this.minLevelPercent,
    required this.maxLevelPercent,
    required this.motorEnabled,
    required this.inletTimeoutMinutes,
    required this.cooldownMinutes,
  });

  final int  minLevelPercent;
  final int  maxLevelPercent;
  final bool motorEnabled;
  final int  inletTimeoutMinutes;
  final int  cooldownMinutes;

  factory DeviceConfigModel.defaults() => const DeviceConfigModel(
    minLevelPercent:     25,
    maxLevelPercent:     100,
    motorEnabled:        true,
    inletTimeoutMinutes: 5,
    cooldownMinutes:     10,
  );

  factory DeviceConfigModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return DeviceConfigModel(
      minLevelPercent:     (d['minLevelPercent']      as num?)?.toInt() ?? 25,
      maxLevelPercent:     (d['maxLevelPercent']      as num?)?.toInt() ?? 100,
      motorEnabled:        d['motorEnabled']           as bool?          ?? true,
      inletTimeoutMinutes: (d['inletTimeoutMinutes']  as num?)?.toInt() ?? 5,
      cooldownMinutes:     (d['cooldownMinutes']       as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'minLevelPercent':     minLevelPercent,
    'maxLevelPercent':     maxLevelPercent,
    'motorEnabled':        motorEnabled,
    'inletTimeoutMinutes': inletTimeoutMinutes,
    'cooldownMinutes':     cooldownMinutes,
    'updatedAt':           FieldValue.serverTimestamp(),
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
    );
  }
}
