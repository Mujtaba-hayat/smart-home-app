import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../members/invitation_screen.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../wifi_setup/wifi_setup_screen.dart';
import '../members/members_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // =========================================
  // LOGOUT
  // =========================================

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // =========================================
  // DELETE ACCOUNT
  // =========================================

  Future<void> _deleteAccount(
      BuildContext context,
      String password,
      ) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.deleteAccount(
      password: password,
    );

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                "Unable to delete account",
          ),
        ),
      );

      return;
    }

    // =========================================
    // ACCOUNT SUCCESSFULLY DELETED
    // =========================================

    // Clear local login/token state first.
    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    // Remove the entire authenticated navigation
    // stack and open LoginScreen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // =========================================
  // BUILD
  // =========================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
    );

    final user = authProvider.user;

    final fullName =
        user?["fullName"]?.toString() ??
            "Smart Home User";

    final email =
        user?["email"]?.toString() ??
            "No email available";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // =========================================
          // PROFILE HEADER
          // =========================================

          const SizedBox(
            height: 20,
          ),

          const Center(
            child: CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 45,
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Center(
            child: Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Center(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          // =========================================
          // WI-FI SETUP
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
                    builder: (_) =>
                    const WifiSetupScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 12,
          ),

// =========================================
// MEMBERS
// =========================================

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.people_outline,
              ),

              title: const Text(
                "Members",
              ),

              subtitle: const Text(
                "Manage Smart Home members and permissions",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const MembersScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 12,
          ),


          // =========================================
// INVITATIONS
// =========================================

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.mail_outline,
              ),

              title: const Text(
                "Invitations",
              ),

              subtitle: const Text(
                "View and respond to Smart Home invitations",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const MemberInvitationScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // =========================================
          // ABOUT
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
                      "IoT-based Smart Home Automation "
                          "System using Flutter, Node.js "
                          "and ESP32.",
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // =========================================
          // DELETE ACCOUNT
          // =========================================

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),

              title: const Text(
                "Delete Account",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                "Permanently delete your account and data",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.red,
              ),

              onTap: () {
                _showDeleteAccountDialog(
                  context,
                );
              },
            ),
          ),

          const SizedBox(
            height: 12,
          ),

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
                _showLogoutDialog(
                  context,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // LOGOUT CONFIRMATION
  // =========================================

  void _showLogoutDialog(
      BuildContext context,
      ) {
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
                Navigator.of(
                  dialogContext,
                ).pop();
              },

              child: const Text(
                "CANCEL",
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.of(
                  dialogContext,
                ).pop();

                await Future<void>.delayed(
                  Duration.zero,
                );

                if (!context.mounted) {
                  return;
                }

                await _logout(
                  context,
                );
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

  // =========================================
  // DELETE ACCOUNT DIALOG
  // =========================================

  void _showDeleteAccountDialog(
      BuildContext context,
      ) {
    final passwordController =
    TextEditingController();

    bool obscurePassword = true;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogContext,
              setState,
              ) {
            return AlertDialog(
              title: const Text(
                "Delete Account",
              ),

              content: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  const Text(
                    "This action is permanent. "
                        "Your account, Smart Home and "
                        "all associated devices will be deleted.",
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller:
                    passwordController,

                    obscureText:
                    obscurePassword,

                    decoration:
                    InputDecoration(
                      labelText:
                      "Current Password",

                      border:
                      const OutlineInputBorder(),

                      suffixIcon:
                      IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons
                              .visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            obscurePassword =
                            !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();

                    passwordController.dispose();
                  },

                  child: const Text(
                    "CANCEL",
                  ),
                ),

                ElevatedButton(
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.red,

                    foregroundColor:
                    Colors.white,
                  ),

                  onPressed: () async {
                    final password =
                    passwordController
                        .text
                        .trim();

                    if (password.isEmpty) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter your password",
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop();

                    await Future<void>.delayed(
                      Duration.zero,
                    );

                    if (!context.mounted) {
                      passwordController.dispose();
                      return;
                    }

                    await _deleteAccount(
                      context,
                      password,
                    );

                    passwordController.dispose();
                  },

                  child: const Text(
                    "DELETE ACCOUNT",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}