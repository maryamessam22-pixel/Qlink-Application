import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final bool isWearer;
  const PrivacyPolicyPage({super.key, this.isWearer = true});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, appState),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  appState.tr('Data Collection', 'جمع البيانات'),
                  appState.tr(
                    'QR Guard collects only essential medical and emergency contact information necessary for emergency response.',
                    'يجمع QR Guard فقط المعلومات الطبية ومعلومات الاتصال في حالات الطوارئ الضرورية للاستجابة لحالات الطوارئ.'
                  ),
                ),
                const SizedBox(height: 32),
                _buildSection(
                  appState.tr('Security', 'الأمان'),
                  appState.tr(
                    'All data is encrypted using industry-standard 256-bit encryption.',
                    'يتم تشفير جميع البيانات باستخدام تشفير 256 بت المعياري في الصناعة.'
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: isWearer 
            ? WearerBottomNav(currentIndex: 3, onTap: (_) => Navigator.pop(context))
            : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState appState) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        appState.tr('Privacy Policy', 'سياسة الخصوصية'),
        style: const TextStyle(
          color: Color(0xFF273469),
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
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
            fontWeight: FontWeight.w900,
            color: Color(0xFF273469),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF273469).withValues(alpha: 0.7),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
