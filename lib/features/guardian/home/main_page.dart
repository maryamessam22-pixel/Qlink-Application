import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/features/guardian/map/map_page.dart';
import 'package:q_link/features/guardian/vault/vault_page.dart';
import 'package:q_link/features/guardian/settings/settings_page.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    MapPage(),
    Center(child: Text('Actions')),
    VaultPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final currentIndex = appState.currentGuardianIndex;
        
        return Scaffold(
          extendBody: true, // Important for floating nav bar
          body: _pages[currentIndex],
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }
}
