import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'tennis_loading.dart';
import '../screens/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while initializing
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: TennisLoading(
                size: 60,
              ),
            ),
          );
        }

        // Show login screen if not authenticated
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        // Show the protected content if authenticated
        return child;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final Widget loginChild;
  final Widget homeChild;

  const AuthWrapper({
    super.key,
    required this.loginChild,
    required this.homeChild,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('AuthWrapper - isInitialized: ${authProvider.isInitialized}, isLoggedIn: ${authProvider.isLoggedIn}');
        print('AuthWrapper - User: ${authProvider.user?.name}, Token: ${authProvider.token != null ? 'Present' : 'Missing'}');
        
        // Show loading while initializing
        if (!authProvider.isInitialized) {
          print('AuthWrapper - Showing loading screen');
          return const Scaffold(
            body: Center(
              child: TennisLoading(
                size: 60,
              ),
            ),
          );
        }

        // Show login screen if not authenticated
        if (!authProvider.isLoggedIn) {
          print('AuthWrapper - Showing login screen');
          return widget.loginChild;
        }

        // Show the home content if authenticated
        print('AuthWrapper - Showing home screen');
        return widget.homeChild;
      },
    );
  }
}
