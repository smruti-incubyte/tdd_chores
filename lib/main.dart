import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tdd_chores/core/services/notification_service.dart';
import 'package:tdd_chores/features/auth/presentation/login_screen.dart';
import 'package:tdd_chores/features/chores/data/datasources/remote/chore_firebase_service.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/save_photo.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';
import 'package:tdd_chores/firebase_options.dart';

import 'features/chores/presentation/screens/chores_list_screen.dart';

import 'core/services/auth_service.dart';
import 'features/chores/presentation/bloc/chores_bloc.dart';
import 'features/chores/data/repositories/chore_repository_impl.dart';

import 'features/chores/domain/usecases/add_single_chore.dart';
import 'features/chores/domain/usecases/add_group_chore.dart';
import 'features/chores/domain/usecases/delete_photo.dart';
import 'features/chores/domain/usecases/delete_single_chore.dart';
import 'features/chores/domain/usecases/delete_group_chore.dart';

const _androidChannel = AndroidNotificationChannel(
  'chores_notifications',
  'Chores Notifications',
  description: 'Notifications for chore updates',
  importance: Importance.high,
);

final _localNotifications = FlutterLocalNotificationsPlugin();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _setupLocalNotifications();
  _setupFirebaseMessaging();
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

Future<void> _setupLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings(
    '@drawable/ic_stat_notification',
  );
  const darwinSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: darwinSettings,
  );
  await _localNotifications.initialize(settings: initSettings);

  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_androidChannel);
}

void _setupFirebaseMessaging() {
  final messaging = FirebaseMessaging.instance;

  messaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _handleNotificationPayload(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationPayload);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _handleNotificationPayload(message);
    _showLocalNotification(message);
  });
}

void _handleNotificationPayload(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  debugPrint('Notification received:');
  if (notification != null) {
    debugPrint('  title: ${notification.title}');
    debugPrint('  body:  ${notification.body}');
  }
  if (data.isNotEmpty) {
    debugPrint('  data:  $data');
  }
}

void _showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;

  _localNotifications.show(
    id: notification.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_stat_notification',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ChoreRepositoryImpl(
      choreFirebaseService: ChoreFirebaseService(),
    );

    return BlocProvider(
      create: (context) => ChoresBloc(
        getGroupChores: GetGroupChores(repository: repository),
        getSingleChores: GetSingleChores(repository: repository),
        addSingleChore: AddSingleChore(repository: repository),
        addGroupChore: AddGroupChore(repository: repository),
        deleteSingleChore: DeleteSingleChore(repository: repository),
        deletePhoto: DeletePhoto(repository: repository),
        deleteGroupChore: DeleteGroupChore(repository: repository),
        updateSingleChore: UpdateSingleChore(repository: repository),
        updateGroupChore: UpdateGroupChore(repository: repository),
        savePhoto: SavePhoto(repository: repository),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chores App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final notificationService = NotificationService(
      notificationRepository: FirebaseNotificationRepository(),
    );

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show ChoresListScreen if user is signed in, otherwise show LoginScreen
        if (snapshot.hasData) {
          notificationService.saveToken();
          return const ChoresListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
