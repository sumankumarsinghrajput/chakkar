import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingState {
  final String gender;
  final String avatarId;
  final String username;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.gender = '',
    this.avatarId = '',
    this.username = '',
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    String? gender,
    String? avatarId,
    String? username,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      gender: gender ?? this.gender,
      avatarId: avatarId ?? this.avatarId,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setAvatar(String avatarId) {
    state = state.copyWith(avatarId: avatarId);
  }

  Future<bool> checkUsernameAvailable(String username) async {
    final doc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username.toLowerCase())
        .get();
    return !doc.exists;
  }

  Future<bool> saveProfile(String username) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final isAvailable = await checkUsernameAvailable(username);
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: 'Username already taken',
        );
        return false;
      }

      // Save user profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'username': username.toLowerCase(),
        'displayUsername': username,
        'gender': state.gender,
        'avatarId': state.avatarId,
        'xp': 0,
        'level': 1,
        'coins': 100,
        'wins': 0,
        'losses': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reserve username
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username.toLowerCase())
          .set({'uid': user.uid});

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});