import 'package:flutter/material.dart';

import '../auth_gate.dart';
import '../auth_service.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await _runAuthAction(
      () => _authService.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
  }

  Future<void> _signInWithGoogle() {
    return _runAuthAction(_authService.signInWithGoogle);
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    setState(() => isLoading = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AuthService.messageFor(error))));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration customDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Login to continue using NeuroEase.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: customDecoration(
                    hint: "Email",
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password.';
                    }
                    return null;
                  },
                  decoration: customDecoration(
                    hint: "Password",
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 35),
                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}
