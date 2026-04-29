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
        return Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Row(
            children: [
              VideoLogoWidget(),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B64F2),
                        ),
                      )
                    : null,
              ),
              const Spacer(),
              LanguageToggle(),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                },
                child: Stack(
                  children: [
                    const Icon(Icons.notifications_none, color: Color(0xFF1E3A8A), size: 28),
                    if (unread > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
