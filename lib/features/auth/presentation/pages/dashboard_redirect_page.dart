import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:q_link/features/guardian/home/main_page.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/features/auth/splash/choose_role_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/notification_service.dart';

class DashboardRedirectPage extends StatefulWidget {
  const DashboardRedirectPage({super.key});

  @override
  State<DashboardRedirectPage> createState() => _DashboardRedirectPageState();
}

class _DashboardRedirectPageState extends State<DashboardRedirectPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChooseRolePage()),
      );
      return;
    }

    try {
      // Clear AppState first to prevent showing previous account's data
      AppState().clearData();

      final profile = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final role = (profile != null && profile['role'] != null)
          ? profile['role'].toString().trim().toLowerCase()
          : '';
      final isGuardian = role == 'guardian' || role == 'admin';
      final isWearer = role == 'wearer';

      // Update AppState with profile data
      if (profile != null) {
        AppState().updateCurrentUser(
          name: profile['full_name'] ?? 'Unknown',
          email: profile['email'] ?? user.email ?? '',
          password: '',
          imagePath: profile['avatar_url'] ?? '',
          role: isGuardian ? 'Guardian' : 'Wearer',
        );
      }

      if (!isGuardian && !isWearer) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChooseRolePage()),
        );
        return;
      }

      try {
        NotificationService().startRealtimeListener();
      } catch (e) {
        debugPrint('[DashboardRedirect] Realtime listener start failed: $e');
      }

      if (isGuardian) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WearerMainPage()),
        );
      }
    } catch (e) {
      // Fallback to choose role on error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChooseRolePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
