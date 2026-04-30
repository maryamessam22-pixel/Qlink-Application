import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:q_link/features/auth/presentation/pages/sign_in_page.dart';
import 'package:q_link/features/auth/presentation/pages/create_account_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

class SplashPage extends StatefulWidget {
  final String role;

  const SplashPage({super.key, required this.role});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (widget.role == 'Wearer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAccountPage(role: widget.role),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SignInPage(role: widget.role),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
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
              final blob = (longSide * 0.82).clamp(260.0, 480.0);
              final blurSigma = (shortSide * 0.18).clamp(48.0, 88.0);
              final logoW = (w * 0.52).clamp(160.0, 260.0);
              final titleFs = (w * 0.048).clamp(16.0, 22.0);
              final spin = (shortSide * 0.075).clamp(26.0, 36.0);
              final padBottom = mq.padding.bottom + mq.viewInsets.bottom + 16;

              return Stack(
                children: [
                  Positioned(
                    top: -blob * 0.28,
                    left: -blob * 0.28,
                    child: Container(
                      width: blob,
                      height: blob,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFB81428).withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -blob * 0.28,
                    right: -blob * 0.28,
                    child: Container(
                      width: blob,
                      height: blob,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF015CB7).withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                      child: Container(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, 12, 20, padBottom),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: h - mq.padding.vertical - 8),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/qlink_logo.png',
                                width: logoW,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      appState.qlink,
                                      style: TextStyle(
                                        fontFamily: 'Century Gothic',
                                        fontSize: (titleFs * 1.6).clamp(28.0, 40.0),
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: (shortSide * 0.055).clamp(18.0, 36.0)),
                              Text(
                                appState.smartSafetyEcosystem,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Century Gothic',
                                  fontSize: titleFs,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ),
                              SizedBox(height: (shortSide * 0.08).clamp(28.0, 56.0)),
                              SizedBox(
                                width: spin,
                                height: spin,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }
}
