import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

class WearerMainPage extends StatefulWidget {
  const WearerMainPage({super.key});

  @override
  State<WearerMainPage> createState() => _WearerMainPageState();
}

class _WearerMainPageState extends State<WearerMainPage> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            
            // Top QR Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B64F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.qrCode, color: Colors.white, size: 48),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              appState.tr('Create Your Profile', 'أنشئ ملفك الشخصي'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF273469),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                appState.tr(
                  'Create your profile and Pair your Qlink bracelet to activate safety features and medical monitoring.',
                  'أنشئ ملفك الشخصي وقم بإقران سوار Qlink الخاص بك لتنشيط ميزات الأمان والمراقبة الطبية.'
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Action Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.user, color: Color(0xFF1B64F2), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.tr('Create your profile', 'أنشئ ملفك الشخصي'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF273469),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.tr('Add your info', 'أضف معلوماتك'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: Colors.grey.shade300, size: 20),
                  ],
                ),
              ),
            ),
            
            const Spacer(flex: 3),
            
            // Device Status
            Column(
              children: [
                Text(
                  appState.tr('DEVICE STATUS', 'حالة الجهاز').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appState.tr('Searching for nearby Qlink devices...', 'البحث عن أجهزة Qlink القريبة...'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Help Link
            TextButton(
              onPressed: () {},
              child: Text(
                appState.tr('Need help setting up?', 'هل تحتاج إلى مساعدة في الإعداد؟'),
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
    );
  }
}
