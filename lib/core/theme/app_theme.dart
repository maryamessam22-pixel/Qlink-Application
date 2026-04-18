import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(String languageCode) {
    TextTheme baseTheme;

    if (languageCode == 'ar') {
      // Arabic theme with Noto Kufi Arabic font
      baseTheme = GoogleFonts.notoKufiArabicTextTheme();
    } else {
      // English theme with Roboto font
      final robotoTheme = GoogleFonts.robotoTextTheme();
      baseTheme = robotoTheme.copyWith(
        displayLarge: robotoTheme.displayLarge?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        displayMedium: robotoTheme.displayMedium?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        displaySmall: robotoTheme.displaySmall?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        headlineLarge: robotoTheme.headlineLarge?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        headlineMedium: robotoTheme.headlineMedium?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        headlineSmall: robotoTheme.headlineSmall?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        titleLarge: robotoTheme.titleLarge?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        titleMedium: robotoTheme.titleMedium?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
        titleSmall: robotoTheme.titleSmall?.copyWith(
          fontFamily: 'CenturyGothic',
        ),
      );
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      textTheme: baseTheme,
      useMaterial3: true,
      // Configure app bar theme for RTL/LTR
      appBarTheme: AppBarTheme(
        titleTextStyle: languageCode == 'ar'
            ? GoogleFonts.notoKufiArabic(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )
            : GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      // Configure button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: languageCode == 'ar'
              ? GoogleFonts.notoKufiArabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )
              : GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // Configure text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: languageCode == 'ar'
              ? GoogleFonts.notoKufiArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )
              : GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
