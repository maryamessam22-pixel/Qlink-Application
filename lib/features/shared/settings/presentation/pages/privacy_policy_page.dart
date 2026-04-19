import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Text(
                          appState.tr('Privacy Policy', 'سياسة الخصوصية'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF273469),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildSection(
                          appState.tr('Data Collection', 'جمع البيانات'),
                          appState.tr(
                            'QR Guard collects only essential medical and emergency contact information necessary for emergency response.',
                            'يجمع QR Guard فقط المعلومات الطبية وجهات اتصال الطوارئ الضرورية للاستجابة لحالات الطوارئ.'
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSection(
                          appState.tr('Security', 'الأمان'),
                          appState.tr(
                            'All data is encrypted using industry-standard 256-bit encryption.',
                            'يتم تشفير جميع البيانات باستخدام تشفير 256 بت القياسي في الصناعة.'
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF273469),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
