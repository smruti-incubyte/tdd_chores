import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationRepository {
  Future<bool> getNotificationPermission();
  Future<String?> getFcmToken();
  Future<void> saveFcmToken({required String token, required String user});
  Future<String?> getUser();
}

class NotificationService {
  final NotificationRepository notificationRepository;

  NotificationService({required this.notificationRepository});
  Future<void> saveToken() async {
    final permissionGranted = await notificationRepository
        .getNotificationPermission();
    if (permissionGranted) {
      final String? token = await notificationRepository.getFcmToken();
      final String? user = await notificationRepository.getUser();
      if (token != null && user != null) {
        await notificationRepository.saveFcmToken(token: token, user: user);
      }
    }
  }
}

class FirebaseNotificationRepository implements NotificationRepository {
  final messaging = FirebaseMessaging.instance;
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  @override
  Future<String?> getFcmToken() async {
    final token = await messaging.getToken();
    return token;
  }

  @override
  Future<bool> getNotificationPermission() async {
    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return permission.authorizationStatus == AuthorizationStatus.authorized;
  }

  @override
  Future<void> saveFcmToken({required String token, required String user}) async {
    final platform = Platform.operatingSystem;
    final userDoc = db.collection('users').doc(user);

    await userDoc.set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    await userDoc.collection('tokens').doc(token).set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': platform,
    });
  }

  @override
  Future<String?> getUser() async {
    return auth.currentUser?.uid;
  }
}
