import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/smart_home_provider.dart';

import '../../profile/profile_screen.dart';
import '../../wifi_setup/wifi_setup_screen.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider =
    Provider.of<AuthProvider>(context);

    final smartHomeProvider =
    Provider.of<SmartHomeProvider>(context);

    final user = authProvider.user;

    final fullName =
        user?["fullName"]?.toString().trim() ?? "";

    final userName =
    fullName.isNotEmpty ? fullName : "Smart Home User";

    final smartHomeName =
        smartHomeProvider.smartHomeName;

    final isConnected =
        smartHomeProvider.esp32Connected;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // MENU HEADER
            // ====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,

                        backgroundColor:
                        Theme.of(context)
                            .colorScheme
                            .primary,

                        child: const Icon(
                          Icons.home_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        isConnected
                            ? Icons.wifi
                            : Icons.wifi_off,

                        color: isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Smart Home Name

                  Text(
                    smartHomeName.isNotEmpty
                        ? smartHomeName
                        : "My Smart Home",

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // User Name

                  Text(
                    userName,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 15,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Connection Status

                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,

                        decoration:
                        BoxDecoration(
                          shape: BoxShape.circle,

                          color: isConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Text(
                        isConnected
                            ? "ESP32 Connected"
                            : "ESP32 Disconnected",

                        style: TextStyle(
                          fontSize: 13,

                          color: isConnected
                              ? Colors.green
                              : Colors.red,

                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // ====================================================
            // PROFILE
            // ====================================================

            ListTile(
              leading: const Icon(
                Icons.person_outline,
              ),

              title: const Text(
                "Profile",
              ),

              subtitle: const Text(
                "View your profile",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ProfileScreen(),
                  ),
                );
              },
            ),

            // ====================================================
            // WIFI SETUP
            // ====================================================

            ListTile(
              leading: const Icon(
                Icons.wifi,
              ),

              title: const Text(
                "Wi-Fi Setup",
              ),

              subtitle: const Text(
                "Configure ESP32 connection",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const WifiSetupScreen(),
                  ),
                );
              },
            ),

            // ====================================================
            // ABOUT
            // ====================================================

            ListTile(
              leading: const Icon(
                Icons.info_outline,
              ),

              title: const Text(
                "About",
              ),

              subtitle: const Text(
                "About Smart Home",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                Navigator.pop(context);

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
                      "IoT-based Smart Home "
                          "Automation System using "
                          "Flutter, Node.js and ESP32.",
                    ),
                  ],
                );
              },
            ),

            const Spacer(),

            const Divider(),

            // ====================================================
            // CLOSE MENU
            // ====================================================

            ListTile(
              leading: const Icon(
                Icons.close,
              ),

              title: const Text(
                "Close Menu",
              ),

              onTap: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}