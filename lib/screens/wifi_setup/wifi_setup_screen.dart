import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WifiSetupScreen extends StatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  State<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ssidController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _saveWifi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ssid = _ssidController.text.trim();
    final password = _passwordController.text;

    debugPrint("Wi-Fi Name: $ssid");
    debugPrint("Sending Wi-Fi credentials to ESP32...");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Connecting to ESP32...",
        ),
      ),
    );

    try {
      final uri = Uri.http(
        "192.168.4.1",
        "/save",
        {
          "ssid": ssid,
          "password": password,
        },
      );

      debugPrint("ESP32 URL: $uri");

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      debugPrint(
        "ESP32 Response Code: ${response.statusCode}",
      );

      debugPrint(
        "ESP32 Response: ${response.body}",
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Wi-Fi credentials sent successfully!",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ESP32 returned error: ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("ESP32 Connection Error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not connect to ESP32: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wi-Fi Setup"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // =========================================
                // Header Icon
                // =========================================

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                    ),

                    child: Icon(
                      Icons.wifi,
                      size: 60,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =========================================
                // Title
                // =========================================

                const Center(
                  child: Text(
                    "Connect Your Smart Home",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Enter your home Wi-Fi information "
                        "so the ESP32 can connect to your network.",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // Instructions
                // =========================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),

                  child: const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Before continuing:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "1. Connect your phone to "
                            "SmartHome_Setup Wi-Fi.\n"
                            "2. Enter your home Wi-Fi name "
                            "and password below.\n"
                            "3. Press Save Wi-Fi.",
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =========================================
                // Wi-Fi Name
                // =========================================

                TextFormField(
                  controller: _ssidController,

                  decoration: const InputDecoration(
                    labelText: "Wi-Fi Name",
                    hintText: "Enter your home Wi-Fi name",
                    prefixIcon: Icon(Icons.wifi),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Please enter Wi-Fi name";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =========================================
                // Password
                // =========================================

                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: "Wi-Fi Password",
                    hintText: "Enter your Wi-Fi password",

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                    ),

                    border: const OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Please enter Wi-Fi password";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),
// =========================================
// Connect ESP32 Button
// =========================================

                SizedBox(
                  width: double.infinity,

                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: () {

                      debugPrint(
                        "Connect ESP32 button pressed",
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Connect your phone to SmartHome_Setup first.",
                          ),
                        ),
                      );

                    },

                    icon: const Icon(
                      Icons.wifi_find,
                    ),

                    label: const Text(
                      "Connect ESP32",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

// =========================================
// Save Wi-Fi Button
// =========================================

                SizedBox(
                  width: double.infinity,

                  height: 52,

                  child: OutlinedButton.icon(
                    onPressed: _saveWifi,

                    icon: const Icon(
                      Icons.save,
                    ),

                    label: const Text(
                      "Save Wi-Fi",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}