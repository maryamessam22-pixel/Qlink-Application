import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/profile/add_profile_identity.dart';
import 'package:q_link/features/guardian/home/main_page.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final mq = MediaQuery.of(context);
        final w = mq.size.width;
        final short = mq.size.shortestSide;
        final barH = (short * 0.175).clamp(56.0, 78.0);
        final fab = (short * 0.128).clamp(44.0, 56.0);
        final fabIcon = (fab * 0.52).clamp(22.0, 30.0);
        final hMargin = (w * 0.06).clamp(12.0, 28.0);
        final vMargin = (short * 0.038).clamp(10.0, 20.0);
        final radius = (barH * 0.5).clamp(26.0, 40.0);
        final shadowBlur = (short * 0.075).clamp(16.0, 32.0);
        final shadowDy = (short * 0.024).clamp(6.0, 12.0);

        return SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: hMargin, vertical: vMargin),
            height: barH,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.15),
                  blurRadius: shadowBlur,
                  offset: Offset(0, shadowDy),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: (w * 0.018).clamp(4.0, 12.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: LucideIcons.home,
                    label: appState.tr('Home', 'الرئيسية'),
                    target: 0,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: LucideIcons.map,
                    label: appState.tr('Map', 'الخريطة'),
                    target: 1,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                AddProfileIdentityPage(),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        settings: const RouteSettings(
                          name: 'AddProfileIdentity',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: fab,
                    height: fab,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B64F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: fabIcon,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: LucideIcons.lock,
                    label: appState.tr('Vault', 'الخزنة'),
                    target: 3,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: LucideIcons.settings,
                    label: appState.tr('Settings', 'الإعدادات'),
                    target: 4,
                  ),
                ),
              ],
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
    required int target, // Index now
  }) {
    final appState = AppState();
    final bool isActive = appState.currentGuardianIndex == target;
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final iconSz = (short * 0.065).clamp(22.0, 28.0);
    final labelFs = (w * 0.024).clamp(9.0, 11.0);
    final gap = (short * 0.01).clamp(2.0, 6.0);

    return GestureDetector(
      onTap: () {
        appState.setGuardianIndex(target);

        // If not on MainPage, go there
        if (ModalRoute.of(context)?.settings.name != 'MainPage') {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MainPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              settings: const RouteSettings(name: 'MainPage'),
            ),
            (route) => false,
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF1B64F2) : Colors.grey.shade500,
            size: iconSz,
          ),
          SizedBox(height: gap),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelFs,
                color: isActive
                    ? const Color(0xFF1B64F2)
                    : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
