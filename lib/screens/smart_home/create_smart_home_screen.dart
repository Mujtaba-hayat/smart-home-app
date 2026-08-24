import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/smart_home_provider.dart';

class CreateSmartHomeScreen extends StatefulWidget {
  const CreateSmartHomeScreen({
    super.key,
  });

  @override
  State<CreateSmartHomeScreen> createState() =>
      _CreateSmartHomeScreenState();
}

class _CreateSmartHomeScreenState
    extends State<CreateSmartHomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createHome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<SmartHomeProvider>(
      context,
      listen: false,
    );

    final success = await provider.createSmartHome(
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                "Unable to create smart home",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    Provider.of<SmartHomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Smart Home"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [
                const SizedBox(height: 40),

                const Icon(
                  Icons.home_rounded,
                  size: 90,
                ),

                const SizedBox(height: 25),

                const Text(
                  "Welcome to Smart Home",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "First, create your Smart Home. "
                      "You can connect your ESP32 and "
                      "control your devices afterward.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _nameController,

                  textInputAction:
                  TextInputAction.done,

                  decoration: const InputDecoration(
                    labelText: "Smart Home Name",
                    hintText: "e.g. My Home",
                    prefixIcon: Icon(
                      Icons.home,
                    ),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Please enter your home name";
                    }

                    if (value.trim().length < 2) {
                      return "Home name is too short";
                    }

                    return null;
                  },

                  onFieldSubmitted: (_) {
                    if (!provider.isLoading) {
                      _createHome();
                    }
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : _createHome,

                    child: provider.isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,

                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "CREATE SMART HOME",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
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