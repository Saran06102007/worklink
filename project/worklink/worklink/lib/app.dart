import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/tokens.dart';
import 'models/models.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/student/student_shell.dart';
import 'screens/welcome/role_select_screen.dart';
import 'screens/worker/worker_shell.dart';
import 'state/app_state.dart';

class WorkLinkApp extends StatelessWidget {
  const WorkLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'WorkLink',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: state.themeMode,
          scaffoldMessengerKey: state.messengerKey,
          home: _root(state),
        );
      },
    );
  }

  Widget _root(AppState state) {
    if (!state.splashSeen) return const SplashScreen();
    if (state.role == null) return const RoleSelectScreen();
    switch (state.role!) {
      case UserRole.customer:
        return const CustomerShell();
      case UserRole.worker:
        return const WorkerShell();
      case UserRole.student:
        return const StudentShell();
    }
  }
}

/// Shared route helper.
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
}
