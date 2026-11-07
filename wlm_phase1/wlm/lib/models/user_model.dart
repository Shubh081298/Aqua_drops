import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../core/constants/app_constants.dart';

// ── Role ───────────────────────────────────────────────────────────────────────
enum UserRole {
  superAdmin,
  customerAdmin,
  customerUser;

  factory UserRole.fromString(String value) {
    return switch (value) {
      AppConstants.roleSuperAdmin    => UserRole.superAdmin,
      AppConstants.roleCustomerAdmin => UserRole.customerAdmin,
      AppConstants.roleCustomerUser  => UserRole.customerUser,
      _                              => throw ArgumentError('Unknown role: $value'),
    };
  }

  String get value => switch (this) {
    UserRole.superAdmin    => AppConstants.roleSuperAdmin,
    UserRole.customerAdmin => AppConstants.roleCustomerAdmin,
    UserRole.customerUser  => AppConstants.roleCustomerUser,
  };

  bool get isSuperAdmin    => this == UserRole.superAdmin;
  bool get isCustomerAdmin => this == UserRole.customerAdmin;
  bool get isCustomerUser  => this == UserRole.customerUser;
}

// ── Model ──────────────────────────────────────────────────────────────────────
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    this.customerId,
  });

  final String   uid;
  final String   name;
  final String   email;
  final UserRole role;
  final String?  customerId;
  final String   status;
  final String   language;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == AppConstants.statusActive;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return UserModel(
      uid:        doc.id,
      name:       d['name'] as String? ?? '',
      email:      d['email'] as String? ?? '',
      role:       UserRole.fromString(d['role'] as String),
      customerId: d['customerId'] as String?,
      status:     d['status'] as String? ?? AppConstants.statusActive,
      language:   d['language'] as String? ?? 'en',
      createdAt:  (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:  (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':       name,
    'email':      email,
    'role':       role.value,
    'customerId': customerId,
    'status':     status,
    'language':   language,
    'updatedAt':  FieldValue.serverTimestamp(),
  };

  UserModel copyWith({
    String?   name,
    String?   email,
    UserRole? role,
    String?   customerId,
    String?   status,
    String?   language,
  }) {
    return UserModel(
      uid:        uid,
      name:       name       ?? this.name,
      email:      email      ?? this.email,
      role:       role       ?? this.role,
      customerId: customerId ?? this.customerId,
      status:     status     ?? this.status,
      language:   language   ?? this.language,
      createdAt:  createdAt,
      updatedAt:  DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, email, role, customerId, status, language];
}
