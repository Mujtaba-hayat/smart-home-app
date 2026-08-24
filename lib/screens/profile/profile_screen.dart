import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../wifi_setup/wifi_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // Clear user + JWT token
    authProvider.logout();

    // Go to Login screen and remove all previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
    Provider.of<AuthProvider>(context);

    final user = authProvider.user;

    final fullName =
        user?["fullName"]?.toString() ??
            "Smart Home User";

    final email =
        user?["email"]?.toString() ??
            "No email available";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // =========================================
          // Profile Header
          // =========================================

          const SizedBox(height: 20),

          const Center(
            child: CircleAvatar(
              radius: 45,

              child: Icon(
                Icons.person,
                size: 45,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // =========================================
          // Wi-Fi Setup
          // =========================================

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.wifi,
              ),

              title: const Text(
                "Wi-Fi Setup",
              ),

              subtitle: const Text(
                "Configure ESP32 Wi-Fi connection",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const WifiSetupScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // =========================================
          // About
          // =========================================

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
              ),

              title: const Text(
                "About",
              ),

              subtitle: const Text(
                "Smart Home Automation System",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

              onTap: () {
                showAboutDialog(
                  context: context,

                  applicationName:
                  "Smart Home",

                  applicationVersion:
                  "1.0.0",

                  applicationIcon:
                  const Icon(
                    Icons.home,
                    size: 40,
                  ),

                  children: const [
                    Text(
                      "IoT-based Smart Home Automation System "
                          "using Flutter, Node.js and ESP32.",
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // =========================================
          // LOGOUT
          // =========================================

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout,
              ),

              title: const Text(
                "Logout",
              ),

              subtitle: const Text(
                "Sign out of your account",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // Logout Confirmation
  // =========================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout",
          ),

          content: const Text(
            "Are you sure you want to logout?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                "CANCEL",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _logout(context);
              },

              child: const Text(
                "LOGOUT",
              ),
            ),
          ],
        );
      },
    );
  }
}