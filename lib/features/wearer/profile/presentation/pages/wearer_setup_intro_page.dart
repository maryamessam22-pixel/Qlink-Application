import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_identity_page.dart';

class WearerSetupIntroPage extends StatelessWidget {
  const WearerSetupIntroPage({super.key});

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
        final bodyHPad = (w * 0.08).clamp(20.0, 34.0);
        final listBottom = mq.padding.bottom + (short * 0.1).clamp(28.0, 46.0);
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey.shade500),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              appState.tr('Qlink Setup', 'إعداد Qlink'),
              style: const TextStyle(
                color: Color(0xFF273469),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: listBottom),
            child: Column(
              children: [
                SizedBox(height: (short * 0.05).clamp(14.0, 22.0)),
                // Hero Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
                    child: Image.asset(
                      'assets/images/setup pic.png',
                      width: double.infinity,
                      height: (short * 0.8).clamp(240.0, 320.0),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
                
                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: bodyHPad),
                  child: Column(
                    children: [
                      Text(
                        appState.tr("Let's Link Your First Bracelet", "لنقم بربط سوارك الأول"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (short * 0.065).clamp(20.0, 26.0),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF273469),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
                      Text(
                        appState.tr(
                          "Follow these simple steps to activate your life-saving device.",
                          "اتبع هذه الخطوات البسيطة لتنشيط جهازك المنقذ للحياة."
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (short * 0.036).clamp(13.0, 15.0),
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                      
                      SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
                      
                      // Steps
                      _buildStep(
                        context: context,
                        icon: LucideIcons.qrCode,
                        title: appState.tr('Enter the code inside the box to pair', 'أدخل الرمز الموجود داخل الصندوق للإقران'),
                        subtitle: appState.tr('QR Code connection', 'اتصال رمز QR'),
                        appState: appState,
                      ),
                      SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),
                      _buildStep(
                        context: context,
                        icon: LucideIcons.shieldCheck,
                        title: appState.tr('Build the safety profile', 'أنشئ ملف السلامة'),
                        subtitle: appState.tr('Medical info and emergency contacts', 'المعلومات الطبية وجهات اتصال الطوارئ'),
                        appState: appState,
                      ),
                      SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),
                      _buildStep(
                        context: context,
                        icon: LucideIcons.radio,
                        title: appState.tr('Ready for emergencies', 'جاهز للطوارئ'),
                        subtitle: appState.tr('One tap to alert responders', 'نقرة واحدة لتنبيه المستجيبين'),
                        appState: appState,
                      ),
                      
                      SizedBox(height: (short * 0.12).clamp(34.0, 52.0)),
                      
                      // Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WearerIdentityPage()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: (short * 0.16).clamp(54.0, 64.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066CC), Color(0xFF273469)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular((short * 0.08).clamp(24.0, 32.0)),
                          ),
                          child: Center(
                            child: Text(
                              appState.tr('Start Linking', 'بدء الربط'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (short * 0.046).clamp(16.0, 20.0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: (short * 0.14).clamp(40.0, 64.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required AppState appState,
  }) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all((short * 0.026).clamp(8.0, 12.0)),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular((w * 0.03).clamp(10.0, 14.0)),
          ),
          child: Icon(icon, color: const Color(0xFF1B64F2), size: (short * 0.05).clamp(18.0, 22.0)),
        ),
        SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: (short * 0.038).clamp(14.0, 16.0),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF273469),
                  height: 1.3,
                ),
              ),
              SizedBox(height: (short * 0.006).clamp(1.0, 4.0)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: (short * 0.033).clamp(12.0, 14.0),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
