import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationRepository {
  Future<bool> getNotificationPermission();
  Future<String?> getFcmToken();
  Future<void> saveFcmToken();
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
        await notificationRepository.saveFcmToken();
      }
    }
  }
}

class FirebaseNotificationRepository implements NotificationRepository {
  final messaging = FirebaseMessaging.instance;
  final db = FirebaseFirestore.instance;

  @override
  Future<String?> getFcmToken() async {
    final token = await messaging.getToken();
    return token;
  }

  @override
  Future<bool> getNotificationPermission() async {
    final permission = await messaging.requestPermission();
    return permission.authorizationStatus == AuthorizationStatus.authorized;
  }

  @override
  Future<void> saveFcmToken() async {
    db.collection('users').id;
  }

  @override
  Future<String?> getUser() async {
    return '1';
  }
}
