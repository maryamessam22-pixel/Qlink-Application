import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_setup_intro_page.dart';

class WearerInitialSetupPage extends StatelessWidget {
  const WearerInitialSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.06).clamp(16.0, 28.0);
        final bottomPad = mq.padding.bottom + (short * 0.08).clamp(24.0, 40.0);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, bottomPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                children: [
                  SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
                  
                  // Large circular icon
                  Center(
                    child: Container(
                      width: (short * 0.32).clamp(96.0, 128.0),
                      height: (short * 0.32).clamp(96.0, 128.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B64F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: (short * 0.16).clamp(44.0, 64.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
                  
                  // Title
                  Text(
                    appState.tr('Create Your Profile', 'أنشئ ملفك الشخصي'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (short * 0.075).clamp(24.0, 30.0),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF273469),
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                  
                  // Subtitle
                  Text(
                    appState.tr(
                      'Create your profile and Pair your Qlink bracelet to activate safety features and medical monitoring.',
                      'قم بإنشاء ملفك الشخصي وإقران سوار Qlink الخاص بك لتنشيط ميزات الأمان والمراقبة الطبية.'
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (short * 0.04).clamp(14.0, 17.0),
                      color: Colors.grey.shade500,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.14).clamp(40.0, 64.0)),
                  
                  // Action Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WearerSetupIntroPage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular((w * 0.06).clamp(16.0, 24.0)),
                        border: Border.all(color: Colors.grey.shade100, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all((short * 0.03).clamp(10.0, 14.0)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular((w * 0.04).clamp(12.0, 18.0)),
                            ),
                            child: const Icon(Icons.person_outline, color: Color(0xFF1B64F2), size: 24),
                          ),
                          SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.tr('Create your profile', 'أنشئ ملفك الشخصي'),
                                  style: TextStyle(
                                    fontSize: (short * 0.04).clamp(14.0, 17.0),
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF273469),
                                  ),
                                ),
                                SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
                                Text(
                                  appState.tr('Add your info', 'أضف معلوماتك'),
                                  style: TextStyle(
                                    fontSize: (short * 0.036).clamp(13.0, 15.0),
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),

                  // Device Status
                  Text(
                    appState.tr('DEVICE STATUS', 'حالة الجهاز'),
                    style: TextStyle(
                      fontSize: (short * 0.032).clamp(12.0, 14.0),
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: (short * 0.02).clamp(6.0, 10.0)),
                      Expanded(
                        child: Text(
                        appState.tr('Searching for nearby Qlink devices...', 'البحث عن أجهزة Qlink القريبة...'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (short * 0.036).clamp(13.0, 15.0),
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
                  
                  // Help link
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      appState.tr('Need help setting up?', 'هل تحتاج إلى مساعدة في الإعداد؟'),
                      style: TextStyle(
                        color: const Color(0xFF1B64F2),
                        fontSize: (short * 0.038).clamp(14.0, 16.0),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.05).clamp(14.0, 22.0)),
                ],
              ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
