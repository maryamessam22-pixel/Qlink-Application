import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/shared/splash/presentation/pages/choose_role_page.dart';
import 'core/state/app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final isArabic = AppState().isArabic;
        final languageCode = isArabic ? 'ar' : 'en';
        
        final baseTheme = AppTheme.getTheme(languageCode);
        final textTheme = isArabic 
            ? GoogleFonts.notoKufiArabicTextTheme(baseTheme.textTheme)
            : GoogleFonts.robotoTextTheme(baseTheme.textTheme);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          builder: (context, child) {
            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Theme(
                data: baseTheme.copyWith(textTheme: textTheme),
                child: child!,
              ),
            );
          },
          home: const ChooseRolePage(),
        );
      },
    );
  }
}
