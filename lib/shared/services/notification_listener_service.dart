import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class NotificationListenerService {
  static final NotificationListenerService _instance =
      NotificationListenerService._internal();
  factory NotificationListenerService() => _instance;
  NotificationListenerService._internal();

  final _firestore = FirebaseFirestore.instance;
  bool _started = false;
  DateTime? _startTime;

  void start() {
    if (_started) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _started = true;
    _startTime = DateTime.now();

    // Listen for new friend requests
    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friendRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              final sentAt = (data?['sentAt'] as Timestamp?)?.toDate();
              // Only notify for requests that arrived after we started listening
              // (avoids notifying for old pending requests on app launch)
              if (sentAt != null &&
                  _startTime != null &&
                  sentAt.isAfter(_startTime!)) {
                notificationService.showInstant(
                  title: 'New Friend Request',
                  body:
                      '${data?['fromUsername'] ?? 'Someone'} wants to be friends!',
                  id: 200,
                );
              }
            }
          }
        });

    // Listen for new join requests on rooms this user hosts
    _firestore
        .collection('rooms')
        .where('hostId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (final doc in snapshot.docs) {
            final pending = List<String>.from(
              doc.data()['pendingRequests'] ?? [],
            );
            final roomName = doc.data()['roomName'] ?? 'your room';
            if (pending.isNotEmpty) {
              notificationService.showInstant(
                title: 'Join Request',
                body: 'Someone wants to join $roomName!',
                id: 201,
              );
            }
          }
        });

    // Listen for new room invites sent to this user by friends
    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('roomInvites')
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              final sentAt = (data?['sentAt'] as Timestamp?)?.toDate();
              if (sentAt != null &&
                  _startTime != null &&
                  sentAt.isAfter(_startTime!)) {
                notificationService.showInstant(
                  title: 'Room Invite',
                  body:
                      '${data?['fromUsername'] ?? 'A friend'} invited you to play!',
                  id: 202,
                  payload: 'room:${data?['roomId']}',
                );
              }
            }
          }
        });
  }

  void stop() {
    _started = false;
  }
}

final notificationListenerService = NotificationListenerService();
