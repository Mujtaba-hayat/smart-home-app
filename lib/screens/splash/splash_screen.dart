import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/smart_home_provider.dart';
import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';
import '../smart_home/create_smart_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkUser();
  }

  Future<void> _checkUser() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final authProvider =
    Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // =========================================
    // USER NOT LOGGED IN
    // =========================================

    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      return;
    }

    // =========================================
    // USER IS LOGGED IN
    // =========================================

    final smartHomeProvider =
    Provider.of<SmartHomeProvider>(
      context,
      listen: false,
    );

    final hasSmartHome =
    await smartHomeProvider.loadSmartHome();

    if (!mounted) return;

    // =========================================
    // SMART HOME EXISTS
    // =========================================

    if (hasSmartHome) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MainNavigationScreen(),
        ),
      );

      return;
    }

    // =========================================
    // SMART HOME DOES NOT EXIST
    // =========================================

    if (smartHomeProvider.errorMessage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      return;
    }

    // =========================================
    // CREATE SMART HOME
    // =========================================

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const CreateSmartHomeScreen(),
      ),
    );

    if (!mounted) return;

    if (created == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MainNavigationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.home_rounded,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              "Smart Home",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Making your home smarter",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}