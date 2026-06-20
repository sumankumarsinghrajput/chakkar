import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/firebase_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final isGuestProvider = Provider<bool>((ref) {
  // Watch auth state so this re-evaluates whenever user data changes
  ref.watch(authStateChangesProvider);
  return AuthService().isGuest;
});

class UpgradeNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService = AuthService();

  UpgradeNotifier() : super(const AsyncValue.data(null));

  Future<bool> upgradeWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.linkWithGoogle();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> upgradeWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.linkWithEmail(email, password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final upgradeNotifierProvider =
    StateNotifierProvider<UpgradeNotifier, AsyncValue<void>>(
      (ref) => UpgradeNotifier(),
    );
