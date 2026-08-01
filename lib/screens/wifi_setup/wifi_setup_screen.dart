import 'package:flutter/material.dart';

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

  void _saveWifi() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint("Wi-Fi Name: ${_ssidController.text}");
    debugPrint("Wi-Fi Password: ${_passwordController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Wi-Fi information entered successfully",
        ),
      ),
    );
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
                // Save Button
                // =========================================

                SizedBox(
                  width: double.infinity,

                  height: 52,

                  child: ElevatedButton.icon(
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