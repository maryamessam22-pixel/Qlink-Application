import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/shared/home/presentation/pages/home_page.dart';

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
              GestureDetector(
                onTap: () {
                  appState.toggleLanguage();
                },
                child: const Icon(Icons.language, color: Color(0xFF1E3A8A), size: 28),
              ),
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
