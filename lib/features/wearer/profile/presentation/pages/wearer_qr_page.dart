import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/features/wearer/health/presentation/pages/wearer_health_page.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_settings_page.dart';

class WearerQrPage extends StatefulWidget {
  const WearerQrPage({super.key});

  @override
  State<WearerQrPage> createState() => _WearerQrPageState();
}

class _WearerQrPageState extends State<WearerQrPage> {
  final String _qrData = "QLINK-USER-EMERGENCY-DATA-MOCKED";
  
  void _showNumberInputDialog() {
    final appState = AppState();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          appState.tr('Emergency Contact', 'جهة اتصال الطوارئ'),
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF273469)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appState.tr('Enter your emergency phone number', 'أدخل رقم هاتف الطوارئ الخاص بك'),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+20 123 456 7890',
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.tr('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF273469),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(appState.tr('Save', 'حفظ'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const WearerHeader(),
                  const SizedBox(height: 32),
                  
                  Text(
                    appState.tr('Emergency QR', 'رمز QR للطوارئ'),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF273469),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    appState.tr('Let others scan this in emergencies', 'دع الآخرين يمسحون هذا في حالات الطوارئ'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: const Color(0xFF273469).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // QR Container
                  GestureDetector(
                    onTap: _showNumberInputDialog,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 220.0,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF273469),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Share Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.white, size: 20),
                      label: Text(
                        appState.tr('Share QR Code', 'مشاركة رمز QR'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      appState.tr(
                        'Allow first responders to scan this code to access your emergency medical information.',
                        'اسمح للمستجيبين الأوائل بمسح هذا الرمز للوصول إلى معلوماتك الطبية الطارئة.'
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF273469).withValues(alpha: 0.7),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          bottomNavigationBar: WearerBottomNav(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WearerMainPage(isConnected: true)),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WearerHealthPage()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WearerQrPage()),
                );
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WearerSettingsPage()),
                );
              }
            },
          ),
        );
      },
    );
  }
}
