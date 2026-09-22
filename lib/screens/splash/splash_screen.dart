import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/smart_home_provider.dart';
import '../../providers/member_provider.dart';

import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';
import '../smart_home/create_smart_home_screen.dart';
import '../members/member_invitation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    while (authProvider.isInitializing) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final smartHomeProvider = Provider.of<SmartHomeProvider>(context, listen: false);
    final hasSmartHome = await smartHomeProvider.loadSmartHome();
    if (!mounted) return;

    if (hasSmartHome || smartHomeProvider.errorMessage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
      return;
    }

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.loadMyInvitations();
    if (!mounted) return;

    if (memberProvider.hasInvitations) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MemberInvitationsScreen()),
      );
      return;
    }

    // Direct replacement prevents hanging on splash if user hits back
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateSmartHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_rounded, size: 90),
            SizedBox(height: 20),
            Text("Smart Home", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Making your home smarter", style: TextStyle(fontSize: 16)),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}