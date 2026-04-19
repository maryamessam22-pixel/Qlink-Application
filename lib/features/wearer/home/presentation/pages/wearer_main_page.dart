import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

class WearerMainPage extends StatefulWidget {
  const WearerMainPage({super.key});

  @override
  State<WearerMainPage> createState() => _WearerMainPageState();
}

class _WearerMainPageState extends State<WearerMainPage> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.watch, size: 80, color: Color(0xFF8A2BE2)),
            const SizedBox(height: 20),
            Text(
              appState.tr('Wearer Interface', 'واجهة المرتدي'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Coming Soon...', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
