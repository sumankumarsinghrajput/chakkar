import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

final ownedItemsProvider = StreamProvider<Map<String, int>>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value({});

  return _firestore.collection('users').doc(user.uid).snapshots().map(
        (doc) => Map<String, int>.from(doc.data()?['inventory'] ?? {}),
      );
});

class StoreNotifier extends StateNotifier<bool> {
  StoreNotifier() : super(false);

  Future<bool> purchaseItem(String itemId, int price) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final currentCoins = userDoc.data()?['coins'] ?? 0;

    if (currentCoins < price) return false;

    await _firestore.collection('users').doc(user.uid).update({
      'coins': FieldValue.increment(-price),
      'inventory.$itemId': FieldValue.increment(1),
    });

    return true;
  }

  Future<void> useBooster(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'inventory.$itemId': FieldValue.increment(-1),
    });
  }

  Future<void> addCoins(int amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'coins': FieldValue.increment(amount),
    });
  }
}

final storeNotifierProvider =
    StateNotifierProvider<StoreNotifier, bool>((ref) => StoreNotifier());