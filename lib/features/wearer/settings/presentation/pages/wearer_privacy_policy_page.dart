import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class WearerPrivacyPolicyPage extends StatelessWidget {
  const WearerPrivacyPolicyPage({super.key});

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
        final bottomPad = mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
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
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  appState.tr('Data Collection', 'جمع البيانات'),
                  appState.tr(
                    'QR Guard collects only essential medical and emergency contact information necessary for emergency response.',
                    'يجمع QR Guard فقط المعلومات الطبية ومعلومات الاتصال في حالات الطوارئ الضرورية للاستجابة لحالات الطوارئ.'
                  ),
                ),
                SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),
                _buildSection(
                  context,
                  appState.tr('Security', 'الأمان'),
                  appState.tr(
                    'All data is encrypted using industry-standard 256-bit encryption.',
                    'يتم تشفير جميع البيانات باستخدام تشفير 256 بت المعياري في الصناعة.'
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const WearerBottomNav(),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final short = MediaQuery.of(context).size.shortestSide;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: (short * 0.046).clamp(16.0, 20.0),
            fontWeight: FontWeight.w900,
            color: const Color(0xFF273469),
          ),
        ),
        SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
        Text(
          content,
          style: TextStyle(
            fontSize: (short * 0.038).clamp(14.0, 16.0),
            color: const Color(0xFF273469).withValues(alpha: 0.7),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
