import 'package:flutter/material.dart';
import 'package:q_link/features/auth/presentation/pages/create_account_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB81829), // Reddish top
              Color(0xFF4C3A71), // Purple middle
              Color(0xFF015196), // Deep blue bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/qlink_logo.png',
                    height: 70,
                    color: Colors.white,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Qlink',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Header Texts
                const Text(
                  'Wearer Hub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Century Gothic',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure Access Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Email Field
                _buildTextField(
                  hintText: 'Mohamedsaber22@gmail.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                _buildTextField(
                  hintText: '........',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Forgot password logic
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    // Sign in logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28365B),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.8), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.8), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Social Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      iconWidget: Image.asset('assets/icons/fb.png', width: 24, height: 24),
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white,
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      iconWidget: Image.asset('assets/icons/google.png', width: 24, height: 24),
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white,
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      iconWidget: Image.asset('assets/icons/apple.png', width: 24, height: 24),
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // EMERGENCY Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.8), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('EMERGENCY', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.8), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Emergency Button
                ElevatedButton(
                  onPressed: () {
                    // Emergency action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE223C), // Red color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      const Text(
                        'PUBLIC EMERGENCY SCAN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Create Account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to Qlink? ',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Create Account
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateAccountPage()),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    Color backgroundColor = Colors.transparent,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: Center(
          child: iconWidget ?? Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }


}
