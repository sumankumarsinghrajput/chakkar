import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('chakkar_prefs');
  }

  Future<UserCredential> signInAsGuest() async {
    final box = Hive.box('chakkar_prefs');
    final savedEmail = box.get('guest_email');
    final savedPassword = box.get('guest_password');

    if (savedEmail != null && savedPassword != null) {
      try {
        final result = await _auth.signInWithEmailAndPassword(
          email: savedEmail,
          password: savedPassword,
        );
        return result;
      } catch (e) {
        // credentials invalid, create new
      }
    }

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final email = 'guest_$uid@chakkar.app';
    final password = 'Guest${uid}Pass';

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await box.put('guest_email', email);
    await box.put('guest_password', password);

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
