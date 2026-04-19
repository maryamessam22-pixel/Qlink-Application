import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
                opacity: 0.1,
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
                          appState.tr('Help Center', 'مركز المساعدة'),
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
                        Text(
                          appState.tr('Common questions', 'الأسئلة الشائعة'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF273469),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha:0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.tr('How do I pair my bracelet?', 'كيف يمكنني ربط سواري؟'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF273469),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appState.tr('Step-by-step pairing guide', 'دليل الربط خطوة بخطوة'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
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
}
