import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  superAdmin,
  customerAdmin,
  customerUser;

  factory UserRole.fromString(String value) {
    return switch (value) {
      'super_admin'     => UserRole.superAdmin,
      'customer_admin'  => UserRole.customerAdmin,
      _                 => UserRole.customerUser,
    };
  }

  String get value => switch (this) {
    UserRole.superAdmin    => 'super_admin',
    UserRole.customerAdmin => 'customer_admin',
    UserRole.customerUser  => 'customer_user',
  };
}

class UserModel {
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

  bool get isActive => status == 'active';

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return UserModel(
      uid:        doc.id,
      name:       d['name']       as String? ?? '',
      email:      d['email']      as String? ?? '',
      role:       UserRole.fromString(d['role'] as String? ?? 'customer_user'),
      customerId: d['customerId'] as String?,
      status:     d['status']     as String? ?? 'active',
      language:   d['language']   as String? ?? 'en',
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
}
