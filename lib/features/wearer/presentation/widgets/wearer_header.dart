import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/pages/notifications_page.dart';

class WearerHeader extends StatelessWidget {
  const WearerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final unread = appState.unreadNotificationCount;
        final imagePath = appState.currentUser.imagePath;

        return Row(
          children: [
            VideoLogoWidget(),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE6F0FE),
              backgroundImage: imagePath.isNotEmpty
                  ? getUserAvatarProvider(imagePath)
                  : null,
              onBackgroundImageError:
                  imagePath.isNotEmpty ? (_, __) {} : null,
              child: imagePath.isEmpty
                  ? Text(
                      appState.currentUser.name.isNotEmpty
                          ? appState.currentUser.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B64F2)),
                    )
                  : null,
            ),
            const Spacer(),
            const LanguageToggle(),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_none,
                      color: Color(0xFF1E3A8A), size: 28),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
