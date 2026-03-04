import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tdd_chores/core/services/notification_service.dart';
import 'package:tdd_chores/features/auth/presentation/login_screen.dart';
import 'package:tdd_chores/features/chores/data/datasources/remote/chore_firebase_service.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';
import 'package:tdd_chores/firebase_options.dart';

import 'features/chores/presentation/screens/chores_list_screen.dart';

import 'core/services/auth_service.dart';
import 'features/chores/presentation/bloc/chores_bloc.dart';
import 'features/chores/data/repositories/chore_repository_impl.dart';

import 'features/chores/domain/usecases/add_single_chore.dart';
import 'features/chores/domain/usecases/add_group_chore.dart';
import 'features/chores/domain/usecases/delete_single_chore.dart';
import 'features/chores/domain/usecases/delete_group_chore.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _setupFirebaseMessaging();
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

void _setupFirebaseMessaging() {
  final messaging = FirebaseMessaging.instance;

  // App launched from a terminated state via notification
  messaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _handleNotificationPayload(message);
    }
  });

  // App brought to foreground by tapping a notification
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationPayload);

  // Notification received while app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _handleNotificationPayload(message);
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
        deleteGroupChore: DeleteGroupChore(repository: repository),
        updateSingleChore: UpdateSingleChore(repository: repository),
        updateGroupChore: UpdateGroupChore(repository: repository),
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
