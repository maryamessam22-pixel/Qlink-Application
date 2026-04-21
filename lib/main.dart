import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Darory 3shan el Token
import 'services/notification_service.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash/choose_role_page.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await Supabase.initialize(
    url: 'https://vveftffbvwptlsqgeygp.supabase.co',
    anonKey: 'sb_publishable_bsCGwopSC-xFZyt_wiBPNA_4wcGHVgQ',
  );

  // 2. Initialize Firebase
  await Firebase.initializeApp();

  // 3. Initialize your Notification Service
  await NotificationService().initialize();

  // 4. Get and Print FCM Token (Da elly e7na m7tageno dlw2ty)
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("***********************************************");
    print("FCM TOKEN AHO YA MARIAM: $token");
    print("***********************************************");
  } catch (e) {
    print("Error getting token: $e");
  }

  runApp(const MyApp());
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
            Locale('ar', 'SA')
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