import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/home/presentation/pages/home_page.dart';
import 'package:q_link/features/shared/settings/presentation/pages/settings_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, child) {
        final appState = AppState();
        return Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Row(
            children: [
              const VideoLogoWidget(),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/mypic.png'),
              ),
              const Spacer(),
              LanguageToggle(),
              const SizedBox(width: 16),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
                child: const Icon(LucideIcons.settings, color: Color(0xFF1E3A8A), size: 26),
              ),
            ],
          ),
        );
      },
    );
  }
}
