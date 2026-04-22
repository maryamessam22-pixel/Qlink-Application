import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash/choose_role_page.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vveftffbvwptlsqgeygp.supabase.co',
    anonKey: 'sb_publishable_bsCGwopSC-xFZyt_wiBPNA_4wcGHVgQ',
  );

  await Firebase.initializeApp();

  runApp(const MyApp());

  // Initialize notifications after UI is shown — avoids white screen
  // if FCM token fetch hangs (e.g. slow network or Play Services delay)
  NotificationService().initialize().catchError((e) {
    debugPrint('[Startup] Notification init error: $e');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isArabic = appState.isArabic;
        final languageCode = isArabic ? 'ar' : 'en';

        final baseTheme = AppTheme.getTheme(languageCode);

        final textTheme = isArabic
            ? GoogleFonts.notoKufiArabicTextTheme(baseTheme.textTheme)
            : GoogleFonts.robotoTextTheme(baseTheme.textTheme);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          locale: isArabic ? const Locale('ar', 'SA') : const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
