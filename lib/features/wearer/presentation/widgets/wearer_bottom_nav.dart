import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';

class WearerBottomNav extends StatelessWidget {
  const WearerBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final currentIndex = appState.currentWearerIndex;
        
        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, LucideIcons.home, appState.tr('Home', 'الرئيسية'), 0, currentIndex),
              _buildNavItem(context, LucideIcons.heartPulse, appState.tr('Health', 'الصحة'), 1, currentIndex),
              _buildNavItem(context, LucideIcons.layoutGrid, appState.tr('QR Code', 'كود QR'), 2, currentIndex),
              _buildNavItem(context, LucideIcons.settings, appState.tr('Settings', 'الإعدادات'), 3, currentIndex),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final appState = AppState();
        appState.setWearerIndex(index);
        
        if (ModalRoute.of(context)?.settings.name != 'WearerMainPage') {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const WearerMainPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              settings: const RouteSettings(name: 'WearerMainPage'),
            ),
            (route) => false,
          );
        }
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1B64F2) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF1B64F2) : Colors.grey.shade400,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
