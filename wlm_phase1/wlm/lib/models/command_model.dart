import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../core/constants/app_constants.dart';

class CommandModel extends Equatable {
  const CommandModel({
    required this.commandId,
    required this.deviceId,
    required this.requestedBy,
    required this.commandType,
    required this.requestedMode,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.acknowledgedAt,
    this.completedAt,
    this.failureReason,
  });

  final String    commandId;
  final String    deviceId;
  final String    requestedBy;
  final String    commandType;    // motor_on | motor_off | return_to_auto
  final String    requestedMode;  // manual | auto
  final String    status;
  final DateTime  createdAt;
  final DateTime  expiresAt;
  final DateTime? acknowledgedAt;
  final DateTime? completedAt;
  final String?   failureReason;

  bool get isExpired   => DateTime.now().isAfter(expiresAt);
  bool get isPending   => status == AppConstants.cmdPending;
  bool get isSucceeded => status == AppConstants.cmdSucceeded;
  bool get isFailed    => status == AppConstants.cmdFailed;
  bool get isTerminal  => [
    AppConstants.cmdSucceeded,
    AppConstants.cmdFailed,
    AppConstants.cmdExpired,
    AppConstants.cmdCancelled,
  ].contains(status);

  factory CommandModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return CommandModel(
      commandId:      doc.id,
      deviceId:       d['deviceId']       as String,
      requestedBy:    d['requestedBy']    as String,
      commandType:    d['commandType']    as String,
      requestedMode:  d['requestedMode']  as String,
      status:         d['status']         as String,
      createdAt:      (d['createdAt']     as Timestamp).toDate(),
      expiresAt:      (d['expiresAt']     as Timestamp).toDate(),
      acknowledgedAt: (d['acknowledgedAt']as Timestamp?)?.toDate(),
      completedAt:    (d['completedAt']   as Timestamp?)?.toDate(),
      failureReason:  d['failureReason']  as String?,
    );
  }

  @override
  List<Object?> get props => [commandId, deviceId, commandType, status];
}
