import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

/// Language switcher widget - can be placed in settings or app bar
class LanguageSwitcher extends StatefulWidget {
  final bool isCompact;

  const LanguageSwitcher({super.key, this.isCompact = false});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  late AppState appState;

  @override
  void initState() {
    super.initState();
    appState = AppState();
    appState.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    appState.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isArabic = appState.isArabic;

        if (widget.isCompact) {
          return GestureDetector(
            onTap: () {
              appState.toggleLanguage();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isArabic ? 'EN' : 'AR',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _buildLanguageButton(
                    label: 'English',
                    isSelected: !isArabic,
                    onTap: () {
                      if (isArabic) {
                        appState.toggleLanguage();
                      }
                    },
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildLanguageButton(
                    label: 'العربية',
                    isSelected: isArabic,
                    onTap: () {
                      if (!isArabic) {
                        appState.toggleLanguage();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
