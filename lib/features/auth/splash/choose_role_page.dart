import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:q_link/features/auth/splash/splash_page.dart';
import 'package:q_link/features/auth/presentation/pages/wearer/wearer_create_account_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFF6B728E),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final mq = MediaQuery.of(context);
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final longSide = w > h ? w : h;
              final shortSide = w < h ? w : h;
              final d1 = (longSide * 0.95).clamp(280.0, 560.0);
              final d2 = (longSide * 1.05).clamp(320.0, 640.0);
              final d4 = (longSide * 0.78).clamp(220.0, 440.0);
              final padBottom = mq.padding.bottom + mq.viewInsets.bottom + 20.0;
              final logoH = (shortSide * 0.16).clamp(48.0, 72.0);
              final titleSize = (w * 0.072).clamp(22.0, 30.0);
              final subtitleSize = (w * 0.04).clamp(13.0, 17.0);

              return Stack(
                children: [
                  Positioned(
                    top: -d1 * 0.32,
                    left: -d1 * 0.22,
                    child: Container(
                      width: d1,
                      height: d1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B8DAC).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -d2 * 0.36,
                    left: -d2 * 0.2,
                    child: Container(
                      width: d2,
                      height: d2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCF8F9D).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -d1 * 0.32,
                    right: -d1 * 0.22,
                    child: Container(
                      width: d1,
                      height: d1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF558ABA).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -d4 * 0.28,
                    right: -d4 * 0.28,
                    child: Container(
                      width: d4,
                      height: d4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6A87A6).withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: (shortSide * 0.22).clamp(48.0, 100.0),
                        sigmaY: (shortSide * 0.22).clamp(48.0, 100.0),
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, padBottom),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: h - mq.padding.vertical - 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: (shortSide * 0.02).clamp(8.0, 20.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () => appState.toggleLanguage(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (w * 0.035).clamp(10.0, 16.0),
                                      vertical: (shortSide * 0.018).clamp(5.0, 8.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Text(
                                      appState.isArabic ? 'EN' : 'AR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: (w * 0.032).clamp(11.0, 14.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: (shortSide * 0.02).clamp(6.0, 14.0)),
                              Center(
                                child: Image.asset(
                                  'assets/images/qlink_logo.png',
                                  height: logoH,
                                  color: Colors.white,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        appState.qlink,
                                        style: TextStyle(
                                          fontSize: (titleSize * 1.5).clamp(32.0, 48.0),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: (shortSide * 0.035).clamp(10.0, 20.0)),
                              Text(
                                appState.welcomeToQlink,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Century Gothic',
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: (shortSide * 0.015).clamp(6.0, 10.0)),
                              Text(
                                appState.chooseHowYouWantToUse,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: (shortSide * 0.065).clamp(22.0, 44.0)),
                              _buildRoleCard(
                                context,
                                icon: Icons.gpp_good_outlined,
                                iconColor: const Color(0xFF015CB7),
                                iconBgColor: const Color(0xFFE8F1FC),
                                title: appState.guardian,
                                description: appState.guardianDescription,
                                buttonText: appState.continueAsGuardian,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SplashPage(role: 'Guardian'),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: (shortSide * 0.045).clamp(14.0, 24.0)),
                              _buildRoleCard(
                                context,
                                icon: Icons.watch_outlined,
                                iconColor: const Color(0xFF8A2BE2),
                                iconBgColor: const Color(0xFFF4E8FC),
                                title: appState.wearer,
                                description: appState.wearerDescription,
                                buttonText: appState.continueAsWearer,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const WearerCreateAccountPage(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: (shortSide * 0.02).clamp(8.0, 16.0)),
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

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final shortSide = mq.size.shortestSide;
    final iconCircle = (shortSide * 0.19).clamp(56.0, 78.0);
    final iconSz = (iconCircle * 0.5).clamp(28.0, 40.0);
    final titleFs = (w * 0.055).clamp(18.0, 24.0);
    final descFs = (w * 0.036).clamp(12.0, 15.0);
    final btnH = (shortSide * 0.12).clamp(44.0, 54.0);
    final padH = (shortSide * 0.05).clamp(16.0, 24.0);
    final padV = (shortSide * 0.048).clamp(14.0, 22.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: (shortSide * 0.045).clamp(12.0, 22.0),
            offset: Offset(0, (shortSide * 0.02).clamp(6.0, 12.0)),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconCircle,
            height: iconCircle,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSz, color: iconColor),
          ),
          SizedBox(height: (shortSide * 0.035).clamp(12.0, 18.0)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFs,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: (shortSide * 0.028).clamp(8.0, 14.0)),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descFs,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          SizedBox(height: (shortSide * 0.055).clamp(18.0, 28.0)),
          SizedBox(
            width: double.infinity,
            height: btnH,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22365A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: (w * 0.04).clamp(14.0, 17.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
