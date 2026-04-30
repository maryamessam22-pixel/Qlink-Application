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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.06).clamp(16.0, 28.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF7F9FC),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.035).clamp(8.0, 16.0),
                      vertical: (short * 0.012).clamp(6.0, 10.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Expanded(
                          child: Text(
                            appState.tr('Privacy Policy', 'سياسة الخصوصية'),
                            style: TextStyle(
                              fontSize: (w * 0.05).clamp(17.0, 22.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF273469),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, (short * 0.02).clamp(8.0, 16.0), hPad, bottomPad),
                      children: [
                        _buildSection(
                          context,
                          appState.tr('Data Collection', 'جمع البيانات'),
                          appState.tr(
                              'QR Guard collects only essential medical and emergency contact information necessary for emergency response.',
                              'يجمع QR Guard فقط المعلومات الطبية وجهات اتصال الطوارئ الضرورية للاستجابة لحالات الطوارئ.'),
                        ),
                        SizedBox(height: (short * 0.07).clamp(22.0, 36.0)),
                        _buildSection(
                          context,
                          appState.tr('Security', 'الأمان'),
                          appState.tr(
                              'All data is encrypted using industry-standard 256-bit encryption.',
                              'يتم تشفير جميع البيانات باستخدام تشفير 256 بت القياسي في الصناعة.'),
                        ),
                        SizedBox(height: (short * 0.07).clamp(22.0, 36.0)),
                        _buildSection(
                          context,
                          appState.tr('Data Sharing', 'مشاركة البيانات'),
                          appState.tr(
                              'We do not sell your personal data. It is only shared with authorized medical personnel during an active emergency scan.',
                              'نحن لا نبيع بياناتك الشخصية. تتم مشاركتها فقط مع الطاقم الطبي المعتمد أثناء حالة الطوارئ الفعلية عند مسح الرمز.'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final w = MediaQuery.sizeOf(context).width;
    final short = MediaQuery.sizeOf(context).shortestSide;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: (w * 0.045).clamp(16.0, 19.0),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF273469),
          ),
        ),
        SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
        Text(
          content,
          style: TextStyle(
            fontSize: (w * 0.038).clamp(13.0, 16.0),
            color: const Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
