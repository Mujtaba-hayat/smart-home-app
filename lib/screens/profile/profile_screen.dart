import 'package:flutter/material.dart';

import '../wifi_setup/wifi_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Icons.home,
                size: 45,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              "Smart Home",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
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

                  applicationName: "Smart Home",

                  applicationVersion: "1.0.0",

                  applicationIcon: const Icon(
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
        ],
      ),
    );
  }
}