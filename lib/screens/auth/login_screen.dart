import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/smart_home_provider.dart';

import '../main_navigation_screen.dart';
import '../smart_home/create_smart_home_screen.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ====================================================
  // LOGIN
  // ====================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    // ==================================================
    // LOGIN FAILED
    // ==================================================

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                "Invalid email or password",
          ),
        ),
      );

      return;
    }

    // ==================================================
    // LOGIN SUCCESSFUL
    // ==================================================

    final smartHomeProvider =
    Provider.of<SmartHomeProvider>(
      context,
      listen: false,
    );

    final hasSmartHome =
    await smartHomeProvider.loadSmartHome();

    if (!mounted) return;

    // ==================================================
    // SMART HOME EXISTS
    // ==================================================

    if (hasSmartHome) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MainNavigationScreen(),
        ),
            (route) => false,
      );

      return;
    }

    // ==================================================
    // SMART HOME ERROR
    // ==================================================

    if (smartHomeProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            smartHomeProvider.errorMessage!,
          ),
        ),
      );

      return;
    }

    // ==================================================
    // NO SMART HOME
    // ==================================================

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const CreateSmartHomeScreen(),
      ),
    );

    if (!mounted) return;

    // ==================================================
    // SMART HOME CREATED
    // ==================================================

    if (created == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MainNavigationScreen(),
        ),
            (route) => false,
      );
    }
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final authProvider =
    Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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

                // ==================================================
                // ICON
                // ==================================================

                const Icon(
                  Icons.home_rounded,
                  size: 85,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  "Smart Home",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Login to control your home",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // ==================================================
                // EMAIL
                // ==================================================

                TextFormField(
                  controller: _emailController,

                  keyboardType:
                  TextInputType.emailAddress,

                  textInputAction:
                  TextInputAction.next,

                  decoration:
                  const InputDecoration(
                    labelText: "Email",

                    hintText:
                    "Enter your email",

                    prefixIcon:
                    Icon(Icons.email),

                    border:
                    OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Please enter your email";
                    }

                    if (!value.contains("@")) {
                      return "Please enter a valid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PASSWORD
                // ==================================================

                TextFormField(
                  controller:
                  _passwordController,

                  obscureText:
                  _obscurePassword,

                  textInputAction:
                  TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!authProvider.isLoading) {
                      _login();
                    }
                  },

                  decoration:
                  InputDecoration(
                    labelText: "Password",

                    hintText:
                    "Enter your password",

                    prefixIcon:
                    const Icon(Icons.lock),

                    border:
                    const OutlineInputBorder(),

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
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Please enter your password";
                    }

                    return null;
                  },
                ),

                // ==================================================
                // FORGOT PASSWORD
                // ==================================================

                Align(
                  alignment:
                  Alignment.centerRight,

                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ForgotPasswordScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Forgot Password?",
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // LOGIN BUTTON
                // ==================================================

                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                    authProvider.isLoading
                        ? null
                        : _login,

                    child:
                    authProvider.isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,

                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Text(
                      "LOGIN",

                      style:
                      TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // REGISTER
                // ==================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    const Text(
                      "Don't have an account? ",
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Sign Up",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}