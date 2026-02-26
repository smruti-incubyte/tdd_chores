import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
          return const ChoresListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
