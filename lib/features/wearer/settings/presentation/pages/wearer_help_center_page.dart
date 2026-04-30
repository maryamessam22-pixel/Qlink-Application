import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class WearerHelpCenterPage extends StatelessWidget {
  const WearerHelpCenterPage({super.key});

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
        final bottomPad = mq.padding.bottom + (short * 0.22).clamp(72.0, 104.0);
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              appState.tr('Help Center', 'مركز المساعدة'),
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all((short * 0.06).clamp(16.0, 24.0)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular((w * 0.06).clamp(16.0, 24.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.tr('Common questions', 'الأسئلة الشائعة'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appState.tr('How do I pair my bracelet?', 'كيف أقوم بإقران سواري؟'),
                        style: TextStyle(
                          fontSize: (short * 0.046).clamp(16.0, 20.0),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF273469),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.tr('Step-by-step pairing guide', 'دليل الاقتران خطوة بخطوة'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: const WearerBottomNav(),
        );
      },
    );
  }
}
