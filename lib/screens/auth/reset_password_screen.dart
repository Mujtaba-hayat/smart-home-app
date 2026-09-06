import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  // ====================================================
  // RESET PASSWORD
  // ====================================================

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.resetPassword(
        email: widget.email,
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset successfully. Please login.",
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [
                const SizedBox(height: 35),

                // ==================================================
                // ICON
                // ==================================================

                const Icon(
                  Icons.password,
                  size: 85,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  "Reset Password",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  "Enter the 6-digit reset code sent "
                      "for ${widget.email}",
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // ==================================================
                // RESET CODE
                // ==================================================

                TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,

                  keyboardType:
                  TextInputType.number,

                  textInputAction:
                  TextInputAction.next,

                  maxLength: 6,

                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],

                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(
                      _passwordFocusNode,
                    );
                  },

                  decoration:
                  const InputDecoration(
                    labelText: "Reset Code",
                    hintText: "Enter 6-digit code",

                    prefixIcon:
                    Icon(Icons.pin),

                    border:
                    OutlineInputBorder(),

                    counterText: "",
                  ),

                  validator: (value) {
                    final code =
                        value?.trim() ?? "";

                    if (code.isEmpty) {
                      return "Please enter reset code";
                    }

                    if (code.length != 6) {
                      return "Code must be 6 digits";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // NEW PASSWORD
                // ==================================================

                TextFormField(
                  controller:
                  _passwordController,

                  focusNode:
                  _passwordFocusNode,

                  obscureText:
                  _obscurePassword,

                  keyboardType:
                  TextInputType.visiblePassword,

                  textInputAction:
                  TextInputAction.next,

                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(
                      _confirmPasswordFocusNode,
                    );
                  },

                  decoration:
                  InputDecoration(
                    labelText: "New Password",

                    hintText:
                    "Enter your new password",

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
                      return "Please enter new password";
                    }

                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                TextFormField(
                  controller:
                  _confirmPasswordController,

                  focusNode:
                  _confirmPasswordFocusNode,

                  obscureText:
                  _obscureConfirmPassword,

                  keyboardType:
                  TextInputType.visiblePassword,

                  textInputAction:
                  TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _resetPassword();
                    }
                  },

                  decoration:
                  InputDecoration(
                    labelText:
                    "Confirm New Password",

                    hintText:
                    "Re-enter your new password",

                    prefixIcon:
                    const Icon(Icons.lock),

                    border:
                    const OutlineInputBorder(),

                    suffixIcon:
                    IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Please confirm your password";
                    }

                    if (value !=
                        _passwordController.text) {
                      return "Passwords do not match";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // ==================================================
                // RESET BUTTON
                // ==================================================

                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                    _isLoading
                        ? null
                        : _resetPassword,

                    child: _isLoading
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
                      "RESET PASSWORD",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // BACK TO LOGIN
                // ==================================================

                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const LoginScreen(),
                      ),
                    );
                  },

                  child:
                  const Text(
                    "Back to Login",
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