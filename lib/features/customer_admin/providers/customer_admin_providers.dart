import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _db  = FirebaseFirestore.instance;
final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

// Tanks belonging to this customer
final myTanksProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db
      .collection('tanks')
      .where('customerId', isEqualTo: _uid)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final myTankCountProvider = StreamProvider<int>((ref) {
  return ref.watch(myTanksProvider.stream).map((l) => l.length);
});

final myOnlineTanksProvider = StreamProvider<int>((ref) {
  return ref.watch(myTanksProvider.stream)
      .map((l) => l.where((t) => t['status'] == 'online').length);
});

final myAlertsProvider = StreamProvider<int>((ref) {
  return ref.watch(myTanksProvider.stream)
      .map((l) => l.where((t) => t['alert'] == true).length);
});

// Users under this customer
final myUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db
      .collection('users')
      .where('customerId', isEqualTo: _uid)
      .where('role', isEqualTo: 'customer_user')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final myUserCountProvider = StreamProvider<int>((ref) {
  return ref.watch(myUsersProvider.stream).map((l) => l.length);
});

// Add tank notifier
final addTankProvider = StateNotifierProvider<AddTankNotifier, AddTankState>((ref) {
  return AddTankNotifier();
});

class AddTankState {
  const AddTankState({this.isLoading = false, this.error});
  final bool isLoading;
  final String? error;
  AddTankState copyWith({bool? isLoading, String? error}) =>
      AddTankState(isLoading: isLoading ?? this.isLoading, error: error);
}

class AddTankNotifier extends StateNotifier<AddTankState> {
  AddTankNotifier() : super(const AddTankState());

  Future<bool> addTank({required String name, required String location, required double capacity}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _db.collection('tanks').add({
        'customerId': _uid,
        'name':       name.trim(),
        'location':   location.trim(),
        'capacity':   capacity,
        'level':      0.0,
        'status':     'offline',
        'alert':      false,
        'createdAt':  FieldValue.serverTimestamp(),
        'updatedAt':  FieldValue.serverTimestamp(),
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> deleteTank(String tankId) async {
    await _db.collection('tanks').doc(tankId).delete();
  }

  void reset() => state = const AddTankState();
}
