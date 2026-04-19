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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF1E3A8A)).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.isArabic ? 'AR' : 'EN',
                  style: TextStyle(
                    color: color ?? const Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.language,
                  color: color ?? const Color(0xFF1E3A8A),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
