import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/pages/notifications_page.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';

ImageProvider getUserAvatarProvider(String path) {
  if (path.startsWith('assets')) return AssetImage(path);
  if (path.startsWith('http') || path.startsWith('blob:')) return NetworkImage(path);
  if (!kIsWeb) return FileImage(File(path));
  return const AssetImage('assets/images/mypic.png');
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, child) {
        final appState = AppState();
        final unread = appState.unreadNotificationCount;
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final bottomPad = (short * 0.072).clamp(18.0, 34.0);
        final gapLogo = (w * 0.02).clamp(6.0, 12.0);
        final avatarR = (short * 0.042).clamp(14.0, 20.0);
        final initialFs = (avatarR * 0.72).clamp(10.0, 14.0);
        final notifIcon = (short * 0.068).clamp(24.0, 30.0);
        final badgeMin = (short * 0.04).clamp(14.0, 18.0);
        final badgeFs = (short * 0.022).clamp(8.0, 10.0);
        final trailingGap = (w * 0.04).clamp(10.0, 18.0);

        return Padding(
          padding: EdgeInsets.only(bottom: bottomPad),
          child: Row(
            children: [
              const VideoLogoWidget(),
              SizedBox(width: gapLogo),
              CircleAvatar(
                radius: avatarR,
                backgroundColor: const Color(0xFFE6F0FE),
                backgroundImage: appState.currentUser.imagePath.trim().isNotEmpty
                    ? getUserAvatarProvider(appState.currentUser.imagePath)
                    : null,
                onBackgroundImageError: appState.currentUser.imagePath.trim().isNotEmpty
                    ? (_, __) {}
                    : null,
                child: appState.currentUser.imagePath.trim().isEmpty
                    ? Text(
                        appState.currentUser.name.isNotEmpty
                            ? appState.currentUser.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: initialFs,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B64F2),
                        ),
                      )
                    : null,
              ),
              const Spacer(),
              const LanguageToggle(),
              SizedBox(width: trailingGap),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_none, color: const Color(0xFF1E3A8A), size: notifIcon),
                    if (unread > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all((short * 0.005).clamp(1.0, 3.0)),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(minWidth: badgeMin, minHeight: badgeMin),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFs,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
}
