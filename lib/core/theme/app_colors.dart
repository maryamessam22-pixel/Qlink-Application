import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Original seed color
  static const Color secondary = Color(0xFF0066CC);
  static const Color accent = Color(0xFF273469);
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);

  // Gradient Colors (from previous button design)
  static const List<Color> primaryGradient = [
    Color(0xFF0066CC),
    Color(0xFF273469),
  ];

  // Helper for transparency
  static Color withAlpha(Color color, double opacity) => color.withValues(alpha: opacity);
}
