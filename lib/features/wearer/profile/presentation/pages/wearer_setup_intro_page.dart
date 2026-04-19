import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_identity_page.dart';

class WearerSetupIntroPage extends StatelessWidget {
  const WearerSetupIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
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
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Hero Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/setup pic.png',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        appState.tr("Let's Link Your First Bracelet", "لنقم بربط سوارك الأول"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF273469),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appState.tr(
                          "Follow these simple steps to activate your life-saving device.",
                          "اتبع هذه الخطوات البسيطة لتنشيط جهازك المنقذ للحياة."
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Steps
                      _buildStep(
                        icon: LucideIcons.qrCode,
                        title: appState.tr('Enter the code inside the box to pair', 'أدخل الرمز الموجود داخل الصندوق للإقران'),
                        subtitle: appState.tr('QR Code connection', 'اتصال رمز QR'),
                        appState: appState,
                      ),
                      const SizedBox(height: 24),
                      _buildStep(
                        icon: LucideIcons.shieldCheck,
                        title: appState.tr('Build the safety profile', 'أنشئ ملف السلامة'),
                        subtitle: appState.tr('Medical info and emergency contacts', 'المعلومات الطبية وجهات اتصال الطوارئ'),
                        appState: appState,
                      ),
                      const SizedBox(height: 24),
                      _buildStep(
                        icon: LucideIcons.radio,
                        title: appState.tr('Ready for emergencies', 'جاهز للطوارئ'),
                        subtitle: appState.tr('One tap to alert responders', 'نقرة واحدة لتنبيه المستجيبين'),
                        appState: appState,
                      ),
                      
                      const SizedBox(height: 48),
                      
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
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066CC), Color(0xFF273469)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              appState.tr('Start Linking', 'بدء الربط'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Watch Tutorial
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.playCircle, color: Color(0xFF1B64F2), size: 18),
                        label: Text(
                          appState.tr('Watch Tutorial', 'مشاهدة الفيديو التعليمي'),
                          style: const TextStyle(
                            color: Color(0xFF1B64F2),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
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
    required IconData icon,
    required String title,
    required String subtitle,
    required AppState appState,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1B64F2), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF273469),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
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
