import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/features/guardian/settings/settings_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:q_link/features/shared/widgets/video_logo_widget.dart';

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
              VideoLogoWidget(),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                backgroundImage: appState.currentUser.imagePath.startsWith('assets')
                    ? AssetImage(appState.currentUser.imagePath)
                    : null, // Update this if file-based images are used
                child: !appState.currentUser.imagePath.startsWith('assets') 
                    ? const Icon(Icons.person, color: Color(0xFF1E3A8A)) 
                    : null,
              ),
              const Spacer(),
              LanguageToggle(),
              const SizedBox(width: 16),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Color(0xFF1E3A8A), size: 28),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
