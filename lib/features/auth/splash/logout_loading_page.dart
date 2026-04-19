import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:q_link/features/auth/splash/choose_role_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

class LogoutLoadingPage extends StatefulWidget {
  const LogoutLoadingPage({super.key});

  @override
  State<LogoutLoadingPage> createState() => _LogoutLoadingPageState();
}

class _LogoutLoadingPageState extends State<LogoutLoadingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Simulate logout process - extended to 3s to allow user to see the animation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ChooseRolePage()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Premium Blurred Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -50 + (20 * _controller.value),
                    left: -100 + (10 * _controller.value),
                    child: Container(
                      width: 450,
                      height: 450,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E64F2).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100 + (30 * _controller.value),
                    right: -100 - (20 * _controller.value),
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD7546D).withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200 - (40 * _controller.value),
                    right: -50 + (30 * _controller.value),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1B64F2).withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.white.withValues(alpha: 0.4)),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Branding
                Image.asset(
                  'assets/images/qlink_logo.png',
                  height: 65,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Text(
                    appState.qlink,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.tr('Smart Safety Ecosystem', 'نظام السلامة الذكي'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF558ABA),
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 80),
                
                Text(
                  appState.tr('Logging out', 'تسجيل الخروج'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Modern Loading indicator
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
