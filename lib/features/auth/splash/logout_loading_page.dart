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

    // Clear user data and log out
    AppState().clearData();

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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final longSide = w > h ? w : h;
          final shortSide = w < h ? w : h;
          final dLarge = (longSide * 0.92).clamp(280.0, 520.0);
          final dMed = (longSide * 0.68).clamp(220.0, 400.0);
          final blurSigma = (shortSide * 0.2).clamp(56.0, 96.0);
          final logoH = (shortSide * 0.17).clamp(52.0, 80.0);
          final taglineFs = (w * 0.035).clamp(12.0, 15.0);
          final logoutFs = (w * 0.05).clamp(17.0, 22.0);
          final spin = (shortSide * 0.075).clamp(26.0, 36.0);
          final gap1 = (shortSide * 0.018).clamp(6.0, 12.0);
          final gap2 = (h * 0.09).clamp(40.0, 96.0);
          final gap3 = (shortSide * 0.065).clamp(22.0, 36.0);

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final v = _controller.value;
                  return Stack(
                    children: [
                      Positioned(
                        top: -dLarge * 0.14 + (dLarge * 0.045 * v),
                        left: -dLarge * 0.24 + (dLarge * 0.022 * v),
                        child: Container(
                          width: dLarge,
                          height: dLarge,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E64F2).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -dLarge * 0.22 + (dLarge * 0.06 * v),
                        right: -dLarge * 0.22 - (dLarge * 0.04 * v),
                        child: Container(
                          width: dLarge * 1.08,
                          height: dLarge * 1.08,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD7546D).withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      Positioned(
                        top: h * 0.22 - (h * 0.08 * v),
                        right: -dMed * 0.18 + (dMed * 0.1 * v),
                        child: Container(
                          width: dMed,
                          height: dMed,
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
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: mq.padding.bottom + mq.viewInsets.bottom + 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h - mq.padding.vertical),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/qlink_logo.png',
                              height: logoH,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  appState.qlink,
                                  style: TextStyle(
                                    fontSize: (logoutFs * 2.8).clamp(40.0, 68.0),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E3A8A),
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: gap1),
                            Text(
                              appState.tr('Smart Safety Ecosystem', 'نظام السلامة الذكي'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: taglineFs,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF558ABA),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: gap2),
                            Text(
                              appState.tr('Logging out', 'تسجيل الخروج'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: logoutFs,
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                              ),
                            ),
                            SizedBox(height: gap3),
                            SizedBox(
                              width: spin,
                              height: spin,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                                strokeWidth: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
