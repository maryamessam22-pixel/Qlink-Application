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
        final short = MediaQuery.of(context).size.shortestSide;
        final avatarR = (short * 0.042).clamp(14.0, 18.0);
        final bell = (short * 0.072).clamp(24.0, 30.0);
        final gap = (short * 0.022).clamp(6.0, 12.0);

        return Row(
          children: [
            VideoLogoWidget(),
            SizedBox(width: gap),
            CircleAvatar(
              radius: avatarR,
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
                      style: TextStyle(
                          fontSize: (avatarR * 0.72).clamp(10.0, 14.0),
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B64F2)),
                    )
                  : null,
            ),
            const Spacer(),
            const LanguageToggle(),
            SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none,
                      color: const Color(0xFF1E3A8A), size: bell),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        constraints: BoxConstraints(
                          minWidth: (short * 0.042).clamp(14.0, 18.0),
                          minHeight: (short * 0.042).clamp(14.0, 18.0),
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: (short * 0.024).clamp(8.0, 10.0),
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
