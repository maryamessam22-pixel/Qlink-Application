import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class LanguageToggle extends StatelessWidget {
  final Color? color;
  const LanguageToggle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return GestureDetector(
          onTap: () => appState.toggleLanguage(),
          child: Icon(
            Icons.language,
            color: color ?? const Color(0xFF1E3A8A),
            size: 28,
          ),
        );
      },
    );
  }
}
