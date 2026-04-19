import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';

import 'package:q_link/features/shared/profile/presentation/pages/locate_bracelet_page.dart';
import 'package:q_link/features/shared/home/presentation/pages/home_page.dart';

class ConnectedDevicePage extends StatelessWidget {
  final ProfileData profile;
  const ConnectedDevicePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
                                  const SizedBox(width: 4),
                                  Text(appState.tr('Back', 'رجوع'), style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const LanguageToggle(),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Device Image & Status
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade100, width: 2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/pulse.png', // Assuming pulse.png matches the design
                                  width: 100,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.watch_outlined, size: 60, color: Color(0xFF273469)),
                                ),
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.only(right: 15, bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'Qlink Pulse',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              appState.tr('Connected via Bluetooth', 'متصل عبر البلوتوث'),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Battery Status Card
                        _buildStatusCard(
                          context,
                          icon: Icons.battery_charging_full,
                          iconColor: Colors.green,
                          title: appState.tr('Battery Status', 'حالة البطارية'),
                          value: '85%',
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.85,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                appState.tr('Last charged 2 hours ago • ~3 days remaining', 'تم الشحن منذ ساعتين • متبقي حوالي 3 أيام'),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Connection Strength Card
                        _buildStatusCard(
                          context,
                          icon: Icons.signal_cellular_alt,
                          iconColor: Colors.green,
                          title: appState.tr('Connection Strength', 'قوة الاتصال'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.signal_cellular_alt, color: Colors.green, size: 20),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Device Information
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appState.tr('Device Information', 'معلومات الجهاز'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(appState.tr('Serial Number', 'الرقم التسلسلي'), 'QLINK-PULSE-8A3F2E'),
                        _buildInfoRow(appState.tr('Firmware Version', 'إصدار البرنامج'), 'v2.4.12-rc', isBadge: true),
                        _buildInfoRow(appState.tr('Hardware ID', 'معرف الأجهزة'), 'B4:F1:A2:99:C3:00'),

                        const SizedBox(height: 32),

                        // Actions
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocateBraceletPage(profile: profile),
                              ),
                            );
                          },
                          icon: const Icon(Icons.my_location, color: Colors.white, size: 20),
                          label: Row(
                            children: [
                              const Spacer(),
                              Text(appState.tr('Find My Bracelet', 'البحث عن سواري'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                        ),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.bluetoothOff, color: Colors.red, size: 20),
                          label: Row(
                            children: [
                              const Spacer(),
                              Text(appState.tr('Disconnect Device', 'قطع اتصال الجهاز'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.red),
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, {required IconData icon, required Color iconColor, required String title, String? value, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 15)),
              const Spacer(),
              if (value != null)
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E3A8A))),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              const Spacer(),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
              if (isBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LATEST', style: TextStyle(color: Color(0xFF1B64F2), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha:0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(context, icon: LucideIcons.home, label: AppState().tr('Home', 'الرئيسية')),
                _buildNavItem(context, icon: LucideIcons.map, label: AppState().tr('Map', 'الخريطة')),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B64F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                _buildNavItem(context, icon: LucideIcons.lock, label: AppState().tr('Vault', 'الخزنة')),
                _buildNavItem(context, icon: LucideIcons.settings, label: AppState().tr('Settings', 'الإعدادات')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}
