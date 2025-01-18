import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_management_service.dart';
import '../models/user_model.dart';
import 'admin_setup_screen.dart';
import 'login_screen.dart';
import 'employee_screen.dart';
import 'janitor_screen.dart';
import 'admin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    if (!mounted) return;

    final authService = context.read<AuthService>();
    final userManagementService = UserManagementService();

    try {
      // First check if any users exist
      final users = await userManagementService.getAllUsers();

      if (!mounted) return;

      if (users.isEmpty) {
        // If no users exist, go to admin setup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminSetupScreen()),
        );
        return;
      }

      // Check if there's an existing session
      await authService.checkAuthStatus();

      if (!mounted) return;

      if (authService.currentUser == null) {
        // No active session, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      // Route based on user role
      if (!mounted) return;

      final userData = authService.userData;
      if (userData == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      switch (userData.role) {
        case UserRole.employee:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => EmployeeScreen(
                      userId: authService.currentUser!.$id,
                      userName: authService.currentUser!.name,
                    )),
          );
          break;
        case UserRole.janitor:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => JanitorScreen(
                      userName: authService.currentUser!.name,
                    )),
          );
          break;
        case UserRole.admin:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
          break;
        default:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_cafe,
              size: 100,
              color: Colors.brown,
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
