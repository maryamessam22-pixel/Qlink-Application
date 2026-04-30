import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
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

        final mq = MediaQuery.of(context);
        final w = mq.size.width;
        final short = mq.size.shortestSide;
        final margin = (w * 0.06).clamp(12.0, 24.0);
        final hPad = (w * 0.06).clamp(12.0, 26.0);
        final vPad = (short * 0.03).clamp(8.0, 14.0);
        final radius = (short * 0.18).clamp(28.0, 38.0);
        final barMinH = (short * 0.18).clamp(62.0, 78.0);

        return SafeArea(
          child: Container(
          margin: EdgeInsets.all(margin),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          constraints: BoxConstraints(minHeight: barMinH),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
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
        ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex) {
    bool isActive = currentIndex == index;
    final short = MediaQuery.of(context).size.shortestSide;
    final itemW = (short * 0.18).clamp(52.0, 68.0);
    final iconS = (short * 0.062).clamp(20.0, 26.0);
    final textFs = (short * 0.029).clamp(10.0, 12.0);

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
        width: itemW,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1B64F2) : Colors.grey.shade400,
              size: iconS,
            ),
            SizedBox(height: (short * 0.01).clamp(2.0, 5.0)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: textFs,
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
