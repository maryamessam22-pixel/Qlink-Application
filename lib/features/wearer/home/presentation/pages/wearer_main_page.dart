import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_setup_intro_page.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';
import 'package:q_link/features/wearer/health/presentation/pages/wearer_health_page.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_qr_page.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_settings_page.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_hardware_link_page.dart';

import 'package:q_link/features/wearer/home/presentation/pages/wearer_home_page.dart';

class WearerMainPage extends StatelessWidget {
  final bool isConnected;
  const WearerMainPage({super.key, this.isConnected = false});

  static const List<Widget> _pages = [
    WearerHomePage(),
    WearerHealthPage(),
    WearerQrPage(),
    WearerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final currentIndex = appState.currentWearerIndex;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: const WearerBottomNav(),
        );
      },
    );
  }
}
