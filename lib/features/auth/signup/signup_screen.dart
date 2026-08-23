import 'package:flutter/material.dart';

import '../auth_gate.dart';
import '../auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agree = false;
  bool isLoading = false;
  String _selectedRole = 'patient';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await _authService.signUp(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        role: _selectedRole,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                IconButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create your NeuroEase account.',
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                _buildRoleSelector(),
                const SizedBox(height: 25),
                _buildField(
                  controller: _fullNameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter your full name.'
                      : null,
                ),
                const SizedBox(height: 18),
                _buildField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 18),
                _buildField(
                  controller: _phoneController,
                  hint: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter your phone number.'
                      : null,
                ),
                const SizedBox(height: 18),
                _buildPasswordField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscure: obscurePassword,
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Use at least 8 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  obscure: obscureConfirmPassword,
                  onPressed: () => setState(
                    () => obscureConfirmPassword = !obscureConfirmPassword,
                  ),
                  validator: (value) => value != _passwordController.text
                      ? 'Passwords do not match.'
                      : null,
                ),
                const SizedBox(height: 15),
                CheckboxListTile(
                  value: agree,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: isLoading
                      ? null
                      : (value) => setState(() => agree = value ?? false),
                  title: const Text(
                    'I agree to the Terms & Conditions',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: isLoading ? null : _createAccount,
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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(hint: hint, icon: icon),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onPressed,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: _decoration(
        hint: hint,
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onPressed,
        ),
      ),
    );
  }

  InputDecoration _decoration({
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
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
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

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who is this account for?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                role: 'patient',
                title: 'Patient',
                subtitle: 'Person living with dementia',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                role: 'caregiver',
                title: 'Caregiver',
                subtitle: 'Family member or caregiver',
                icon: Icons.health_and_safety_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    const primaryColor = Colors.blue;

    return InkWell(
      onTap: isLoading ? null : () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : Colors.grey.shade700,
                  size: 22,
                ),
                const Spacer(),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
