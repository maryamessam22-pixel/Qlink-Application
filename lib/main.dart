import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/shared/splash/presentation/pages/choose_role_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      builder: (context, child) {
        final locale = Localizations.maybeLocaleOf(context);
        final languageCode = locale?.languageCode ?? 'en';
        return Theme(
          data: AppTheme.getTheme(languageCode),
          child: child!,
        );
      },
      home: const ChooseRolePage(),
    );
  }
}
