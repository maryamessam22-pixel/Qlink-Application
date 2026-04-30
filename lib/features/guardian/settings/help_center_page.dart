import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
                            appState.tr('Help Center', 'مركز المساعدة'),
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
                        Text(
                          appState.tr('Common questions', 'الأسئلة الشائعة'),
                          style: TextStyle(
                            fontSize: (w * 0.04).clamp(14.0, 17.0),
                            color: const Color(0xFF273469),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                        _buildFaqItem(
                          context,
                          appState.tr('How do I pair my bracelet?', 'كيف يمكنني ربط سواري؟'),
                          appState.tr('Step-by-step pairing guide', 'دليل الربط خطوة بخطوة'),
                        ),
                        SizedBox(height: (short * 0.03).clamp(10.0, 14.0)),
                        _buildFaqItem(
                          context,
                          appState.tr('How to add a new medical profile?', 'كيف أضيف ملف طبي جديد؟'),
                          appState.tr('Learn how to add family members', 'تعرف على كيفية إضافة أفراد العائلة'),
                        ),
                        SizedBox(height: (short * 0.03).clamp(10.0, 14.0)),
                        _buildFaqItem(
                          context,
                          appState.tr('Who can see my QR data?', 'من يمكنه رؤية بيانات الـ QR الخاصة بي؟'),
                          appState.tr('Understanding privacy and access', 'فهم الخصوصية وصلاحيات الوصول'),
                        ),
                        SizedBox(height: (short * 0.03).clamp(10.0, 14.0)),
                        _buildFaqItem(
                          context,
                          appState.tr('What happens in an emergency?', 'ماذا يحدث في حالات الطوارئ؟'),
                          appState.tr('How alerts and notifications work', 'كيف تعمل التنبيهات والإشعارات'),
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

  Widget _buildFaqItem(BuildContext context, String title, String subtitle) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final w = MediaQuery.sizeOf(context).width;
    final pad = (short * 0.055).clamp(16.0, 26.0);
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: (w * 0.042).clamp(14.0, 18.0),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF273469),
            ),
          ),
          SizedBox(height: (short * 0.02).clamp(6.0, 10.0)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: (w * 0.035).clamp(12.0, 15.0),
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
