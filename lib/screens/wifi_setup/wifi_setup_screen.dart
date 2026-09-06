import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/smart_home_service.dart';

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
  bool _isGeneratingCode = false;
  bool _isSaving = false;

  String? _pairingCode;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // =========================================
  // GENERATE PAIRING CODE
  // =========================================

  Future<void> _generatePairingCode() async {
    setState(() {
      _isGeneratingCode = true;
    });

    try {
      final data =
      await SmartHomeService.generatePairingCode();

      if (!mounted) return;

      setState(() {
        _pairingCode =
            data["pairingCode"]?.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pairing code generated successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not generate pairing code: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingCode = false;
        });
      }
    }
  }

  // =========================================
  // SAVE WIFI TO ESP32
  // =========================================

  Future<void> _saveWifi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Pairing code is required
    if (_pairingCode == null ||
        _pairingCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please generate a pairing code first.",
          ),
        ),
      );

      return;
    }

    final ssid = _ssidController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isSaving = true;
    });

    debugPrint("=================================");
    debugPrint("ESP32 WIFI SETUP");
    debugPrint("=================================");
    debugPrint("WiFi Name: $ssid");
    debugPrint("Pairing Code: $_pairingCode");
    debugPrint("Sending credentials to ESP32...");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Sending Wi-Fi information to ESP32...",
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
          "pairingCode": _pairingCode!,
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
              "Wi-Fi information saved. Restarting ESP32...",
            ),
          ),
        );

        await Future.delayed(
          const Duration(seconds: 2),
        );

        if (!mounted) return;

        _showSuccessDialog();
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
      debugPrint(
        "ESP32 Connection Error: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not connect to ESP32: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // =========================================
  // SUCCESS DIALOG
  // =========================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Setup Saved",
          ),

          content: const Text(
            "The Wi-Fi information and pairing code "
                "have been saved to the ESP32.\n\n"
                "Restart the ESP32. It will connect to "
                "your home Wi-Fi and automatically pair "
                "with your Smart Home.",
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                "DONE",
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================
  // UI
  // =========================================

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
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // =========================================
                // HEADER ICON
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
                // TITLE
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
                    "Connect the ESP32 to your home Wi-Fi "
                        "and pair it with your Smart Home.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // INSTRUCTIONS
                // =========================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(12),

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
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "1. Connect your phone to "
                            "SmartHome_Setup Wi-Fi.\n"
                            "2. Generate a pairing code below.\n"
                            "3. Enter your home Wi-Fi name "
                            "and password.\n"
                            "4. Press Save Wi-Fi.\n"
                            "5. Restart the ESP32.",
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =========================================
                // PAIRING CODE
                // =========================================

                Card(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),

                    child: Column(
                      children: [
                        const Text(
                          "ESP32 Pairing Code",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (_pairingCode != null)
                          Text(
                            _pairingCode!,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight:
                              FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          )
                        else
                          const Text(
                            "No pairing code generated",
                          ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                            _isGeneratingCode
                                ? null
                                : _generatePairingCode,

                            icon: _isGeneratingCode
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(
                              Icons.link,
                            ),

                            label: Text(
                              _isGeneratingCode
                                  ? "Generating..."
                                  : "Generate Pairing Code",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =========================================
                // WIFI NAME
                // =========================================

                TextFormField(
                  controller: _ssidController,

                  decoration:
                  const InputDecoration(
                    labelText: "Wi-Fi Name",
                    hintText:
                    "Enter your home Wi-Fi name",
                    prefixIcon:
                    Icon(Icons.wifi),
                    border:
                    OutlineInputBorder(),
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
                // WIFI PASSWORD
                // =========================================

                TextFormField(
                  controller:
                  _passwordController,

                  obscureText:
                  _obscurePassword,

                  decoration:
                  InputDecoration(
                    labelText:
                    "Wi-Fi Password",

                    hintText:
                    "Enter your Wi-Fi password",

                    prefixIcon:
                    const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                    IconButton(
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

                    border:
                    const OutlineInputBorder(),
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
                // SAVE WIFI
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child:
                  ElevatedButton.icon(
                    onPressed:
                    _isSaving
                        ? null
                        : _saveWifi,

                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.save,
                    ),

                    label: Text(
                      _isSaving
                          ? "Saving..."
                          : "Save Wi-Fi",
                      style:
                      const TextStyle(
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