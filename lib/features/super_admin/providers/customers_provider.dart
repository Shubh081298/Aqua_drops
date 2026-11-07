import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _webApiKey = 'AIzaSyAqu2OC0zNgPjaVfYQmoIw2U-qudMeAJkM';
final _db = FirebaseFirestore.instance;

// Live stream of all customer admins
final customersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db
      .collection('users')
      .where('role', isEqualTo: 'customer_admin')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

// Search query state
final customerSearchProvider = StateProvider<String>((ref) => '');

// Filtered list
final filteredCustomersProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final query  = ref.watch(customerSearchProvider).toLowerCase();
  final stream = ref.watch(customersStreamProvider);
  if (query.isEmpty) return stream;
  return stream.whenData((list) => list.where((c) {
    final name  = (c['name']  as String? ?? '').toLowerCase();
    final email = (c['email'] as String? ?? '').toLowerCase();
    final company = (c['company'] as String? ?? '').toLowerCase();
    return name.contains(query) || email.contains(query) || company.contains(query);
  }).toList());
});

// Add customer notifier
final addCustomerProvider = StateNotifierProvider<AddCustomerNotifier, AddCustomerState>((ref) {
  return AddCustomerNotifier();
});

class AddCustomerState {
  const AddCustomerState({this.isLoading = false, this.error, this.success = false});
  final bool isLoading;
  final String? error;
  final bool success;

  AddCustomerState copyWith({bool? isLoading, String? error, bool? success}) =>
      AddCustomerState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
      );
}

class AddCustomerNotifier extends StateNotifier<AddCustomerState> {
  AddCustomerNotifier() : super(const AddCustomerState());

  Future<bool> addCustomer({
    required String name,
    required String email,
    required String password,
    required String company,
    String phone = '',
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      // Create Firebase Auth user via REST API (doesn't sign out current admin)
      final authRes = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_webApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password, 'returnSecureToken': false}),
      );

      final authBody = jsonDecode(authRes.body) as Map<String, dynamic>;
      if (authRes.statusCode != 200) {
        final msg = authBody['error']?['message'] as String? ?? 'Failed to create user.';
        throw Exception(_mapAuthError(msg));
      }

      final uid = authBody['localId'] as String;

      // Write Firestore profile
      await _db.collection('users').doc(uid).set({
        'name':      name.trim(),
        'email':     email.trim(),
        'company':   company.trim(),
        'phone':     phone.trim(),
        'role':      'customer_admin',
        'status':    'active',
        'language':  'en',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> toggleStatus(String uid, String currentStatus) async {
    try {
      final next = currentStatus == 'active' ? 'inactive' : 'active';
      await _db.collection('users').doc(uid).update({'status': next, 'updatedAt': FieldValue.serverTimestamp()});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCustomer(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() => state = const AddCustomerState();

  String _mapAuthError(String code) => switch (code) {
    'EMAIL_EXISTS'            => 'An account with this email already exists.',
    'WEAK_PASSWORD'           => 'Password must be at least 6 characters.',
    'INVALID_EMAIL'           => 'Please enter a valid email address.',
    'TOO_MANY_ATTEMPTS_TRY_LATER' => 'Too many attempts. Try again later.',
    _ => 'Failed to create account. Please try again.',
  };
}
