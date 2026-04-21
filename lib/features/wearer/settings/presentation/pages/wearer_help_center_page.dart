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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF273469),
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
