import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme(String languageCode) {
    TextTheme baseTheme;
    
    if (languageCode == 'ar') {
      baseTheme = GoogleFonts.notoKufiArabicTextTheme();
    } else {
      final robotoTheme = GoogleFonts.robotoTextTheme();
      baseTheme = robotoTheme.copyWith(
        displayLarge: robotoTheme.displayLarge?.copyWith(fontFamily: 'CenturyGothic'),
        displayMedium: robotoTheme.displayMedium?.copyWith(fontFamily: 'CenturyGothic'),
        displaySmall: robotoTheme.displaySmall?.copyWith(fontFamily: 'CenturyGothic'),
        headlineLarge: robotoTheme.headlineLarge?.copyWith(fontFamily: 'CenturyGothic'),
        headlineMedium: robotoTheme.headlineMedium?.copyWith(fontFamily: 'CenturyGothic'),
        headlineSmall: robotoTheme.headlineSmall?.copyWith(fontFamily: 'CenturyGothic'),
        titleLarge: robotoTheme.titleLarge?.copyWith(fontFamily: 'CenturyGothic'),
        titleMedium: robotoTheme.titleMedium?.copyWith(fontFamily: 'CenturyGothic'),
        titleSmall: robotoTheme.titleSmall?.copyWith(fontFamily: 'CenturyGothic'),
      );
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
      textTheme: baseTheme,
      useMaterial3: true,
    );
  }
}
