import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/court/screens/home_screen.dart';
import 'tennis_loading.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('AuthWrapper: isInitialized: ${authProvider.isInitialized}');
        print('AuthWrapper: isLoading: ${authProvider.isLoading}');
        print('AuthWrapper: isLoggedIn: ${authProvider.isLoggedIn}');
        print('AuthWrapper: user: ${authProvider.user?.name}');
        print('AuthWrapper: token: ${authProvider.token != null ? 'Present' : 'Missing'}');
        
        // Auth provider henüz initialize olmadıysa loading göster
        if (!authProvider.isInitialized) {
          print('AuthWrapper: Showing loading - not initialized');
          return const Scaffold(
            body: Center(
              child: TennisLoading(size: 60),
            ),
          );
        }

        // Auth provider loading durumundaysa loading göster
        if (authProvider.isLoading) {
          print('AuthWrapper: Showing loading - auth provider loading');
          return const Scaffold(
            body: Center(
              child: TennisLoading(size: 60),
            ),
          );
        }

        // Kullanıcı giriş yapmışsa ana sayfaya git
        if (authProvider.isLoggedIn) {
          print('AuthWrapper: User is logged in, showing HomeScreen');
          return const HomeScreen();
        }

        // Kullanıcı giriş yapmamışsa login sayfasına git
        print('AuthWrapper: User not logged in, showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
