import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

// Raw Firebase auth stream
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// User role after login
final userRoleProvider = StateProvider<String?>((ref) => null);

// User display name
final userDisplayNameProvider = StateProvider<String?>((ref) => null);

// Login state notifier
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider));
});

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });
  final bool isLoading;
  final String? error;
  final bool success;

  LoginState copyWith({bool? isLoading, String? error, bool? success}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this._repo) : super(const LoginState());

  final AuthRepository _repo;

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _repo.signIn(email, password);
      final uid = credential.user!.uid;
      final profile = await _repo.getUserProfile(uid);
      state = state.copyWith(isLoading: false, success: true);
      return profile;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}
