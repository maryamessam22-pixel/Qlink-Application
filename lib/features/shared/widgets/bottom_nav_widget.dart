import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/features/guardian/map/map_page.dart';
import 'package:q_link/features/guardian/vault/vault_page.dart';
import 'package:q_link/features/guardian/settings/settings_page.dart';
import 'package:q_link/features/guardian/profile/add_profile_identity.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(
                        context,
                        icon: LucideIcons.home,
                        label: appState.tr('Home', 'الرئيسية'),
                        target: const HomePage(),
                      ),
                      _buildNavItem(
                        context,
                        icon: LucideIcons.map,
                        label: appState.tr('Map', 'الخريطة'),
                        target: const MapPage(),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AddProfileIdentityPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              settings: const RouteSettings(
                                name: 'AddProfileIdentity',
                              ),
                            ),
                            (route) => false, // Remove all routes
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B64F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      _buildNavItem(
                        context,
                        icon: LucideIcons.lock,
                        label: appState.tr('Vault', 'الخزنة'),
                        target: const VaultPage(),
                      ),
                      _buildNavItem(
                        context,
                        icon: LucideIcons.settings,
                        label: appState.tr('Settings', 'الإعدادات'),
                        target: const SettingsPage(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget target,
  }) {
    // Determine if this is the active route
    final ModalRoute? currentRoute = ModalRoute.of(context);
    final bool isActive =
        currentRoute?.settings.name == target.runtimeType.toString() ||
        (label == 'Home' && currentRoute?.isFirst == true);

    return GestureDetector(
      onTap: () {
        // If we're already on this page, don't do anything
        if (isActive) return;

        // Navigate to target and clear all routes above it
        // This works from any nested screen
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => target,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            settings: RouteSettings(name: target.runtimeType.toString()),
          ),
          (route) => false, // Remove all previous routes
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1B64F2) : Colors.grey.shade500,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? const Color(0xFF1B64F2)
                    : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
