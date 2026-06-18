import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/firebase_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signUpWithEmail(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmail(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInAsGuest() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInAsGuest();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});