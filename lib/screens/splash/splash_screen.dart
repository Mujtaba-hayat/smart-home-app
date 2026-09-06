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
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _checkUser();
  }

  // =========================================
  // CHECK USER
  // =========================================

  Future<void> _checkUser() async {
    // -----------------------------------------
    // Small splash delay
    // -----------------------------------------

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    // -----------------------------------------
    // AUTH PROVIDER
    // -----------------------------------------

    final authProvider =
    Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // -----------------------------------------
    // WAIT FOR SAVED LOGIN
    // -----------------------------------------

    while (authProvider.isInitializing) {
      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      if (!mounted) return;
    }

    // =========================================
    // USER NOT LOGGED IN
    // =========================================

    if (!authProvider.isLoggedIn) {
      debugPrint(
        "SPLASH: No logged-in user",
      );

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

    debugPrint(
      "=================================",
    );

    debugPrint(
      "SPLASH: USER IS LOGGED IN",
    );

    debugPrint(
      "SPLASH USER: "
          "${authProvider.user?["fullName"]}",
    );

    debugPrint(
      "SPLASH EMAIL: "
          "${authProvider.user?["email"]}",
    );

    debugPrint(
      "=================================",
    );

    // =========================================
    // SMART HOME PROVIDER
    // =========================================

    final smartHomeProvider =
    Provider.of<SmartHomeProvider>(
      context,
      listen: false,
    );

    // =========================================
    // LOAD USER SMART HOME
    // =========================================

    final hasSmartHome =
    await smartHomeProvider.loadSmartHome();

    if (!mounted) return;

    // =========================================
    // SMART HOME EXISTS
    // =========================================

    if (hasSmartHome) {
      debugPrint(
        "SPLASH: Smart Home found",
      );

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
    // SMART HOME API ERROR
    // =========================================

    if (smartHomeProvider.errorMessage != null) {
      debugPrint(
        "SPLASH SMART HOME ERROR: "
            "${smartHomeProvider.errorMessage}",
      );

      // User is authenticated.
      // Do NOT send the user to LoginScreen.

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
    // NO SMART HOME
    // =========================================
    //
    // IMPORTANT:
    //
    // Before showing CreateSmartHomeScreen,
    // check whether this user has been invited
    // to another user's Smart Home.
    // =========================================

    debugPrint(
      "SPLASH: User has no Smart Home",
    );

    final memberProvider =
    Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    // =========================================
    // LOAD PENDING INVITATIONS
    // =========================================

    debugPrint(
      "SPLASH: Checking pending invitations...",
    );

    await memberProvider.loadMyInvitations();

    if (!mounted) return;

    // =========================================
    // PENDING INVITATION FOUND
    // =========================================

    if (memberProvider.hasInvitations) {
      debugPrint(
        "SPLASH: Pending invitation found",
      );

      debugPrint(
        "SPLASH: Invitation count = "
            "${memberProvider.invitations.length}",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MemberInvitationsScreen(),
        ),
      );

      return;
    }

    // =========================================
    // NO INVITATION
    // =========================================

    debugPrint(
      "SPLASH: No pending invitations",
    );

    // =========================================
    // CREATE SMART HOME
    // =========================================

    final created =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const CreateSmartHomeScreen(),
      ),
    );

    if (!mounted) return;

    // =========================================
    // SMART HOME CREATED
    // =========================================

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

  // =========================================
  // UI
  // =========================================

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

            const SizedBox(
              height: 20,
            ),

            const Text(
              "Smart Home",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              "Making your home smarter",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 40,
            ),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}