import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/tennis_loading.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isInitialized) {
      await authProvider.initialize();
    }
    
    if (mounted) {
      if (!authProvider.isLoggedIn) {
        final redirectRoute = widget.redirectTo ?? '/login';
        Navigator.pushReplacementNamed(context, redirectRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: TennisLoading(size: 60),
            ),
          );
        }

        if (!authProvider.isLoggedIn) {
          return const SizedBox.shrink(); // Will redirect
        }

        return widget.child;
      },
    );
  }
}
