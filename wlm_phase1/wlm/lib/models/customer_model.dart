import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../core/constants/app_constants.dart';

class CustomerModel extends Equatable {
  const CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.contactName,
    this.contactEmail,
    this.phone,
    this.address,
    this.deviceCount = 0,
    this.userCount   = 0,
    this.onlineCount = 0,
  });

  final String   customerId;
  final String   customerName;
  final String?  contactName;
  final String?  contactEmail;
  final String?  phone;
  final String?  address;
  final String   status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Computed fields — populated client-side from device queries
  final int deviceCount;
  final int userCount;
  final int onlineCount;

  bool get isActive => status == AppConstants.statusActive;

  factory CustomerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return CustomerModel(
      customerId:   doc.id,
      customerName: d['customerName'] as String? ?? '',
      contactName:  d['contactName']  as String?,
      contactEmail: d['contactEmail'] as String?,
      phone:        d['phone']        as String?,
      address:      d['address']      as String?,
      status:       d['status']       as String? ?? AppConstants.statusActive,
      createdAt:    (d['createdAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:    (d['updatedAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'customerName': customerName,
    'contactName':  contactName,
    'contactEmail': contactEmail,
    'phone':        phone,
    'address':      address,
    'status':       status,
    'updatedAt':    FieldValue.serverTimestamp(),
  };

  CustomerModel copyWith({
    String? customerName,
    String? contactName,
    String? contactEmail,
    String? phone,
    String? address,
    String? status,
    int?    deviceCount,
    int?    userCount,
    int?    onlineCount,
  }) {
    return CustomerModel(
      customerId:   customerId,
      customerName: customerName ?? this.customerName,
      contactName:  contactName  ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      phone:        phone        ?? this.phone,
      address:      address      ?? this.address,
      status:       status       ?? this.status,
      deviceCount:  deviceCount  ?? this.deviceCount,
      userCount:    userCount    ?? this.userCount,
      onlineCount:  onlineCount  ?? this.onlineCount,
      createdAt:    createdAt,
      updatedAt:    DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [customerId, customerName, status, deviceCount, userCount];
}
