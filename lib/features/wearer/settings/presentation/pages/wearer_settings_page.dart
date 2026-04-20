import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/auth/splash/logout_loading_page.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_edit_profile_page.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_privacy_policy_page.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_help_center_page.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_qr_scan_history_page.dart';
import 'package:q_link/features/wearer/settings/presentation/pages/wearer_find_my_bracelet_page.dart';

class WearerSettingsPage extends StatefulWidget {
  const WearerSettingsPage({super.key});

  @override
  State<WearerSettingsPage> createState() => _WearerSettingsPageState();
}

class _WearerSettingsPageState extends State<WearerSettingsPage> {
  bool _biometricEnabled = true;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WearerHeader(),
                  const SizedBox(height: 32),

                  Text(
                    appState.tr('Settings', 'الإعدادات'),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF273469),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.tr('Security & Preferences', 'الأمن والتفضيلات'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Profile Section
                  _buildSectionTitle(appState.tr('Profile', 'الملف الشخصي')),
                  _buildSettingsItem(
                    icon: LucideIcons.user,
                    title: appState.tr('Edit Profile', 'تعديل الملف الشخصي'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WearerEditProfilePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Security Section
                  _buildSectionTitle(appState.tr('Security', 'الأمان')),
                  _buildSettingsToggle(
                    icon: LucideIcons.fingerprint,
                    title: appState.tr('Biometric Lock', 'القفل الحيوي'),
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),

                  const SizedBox(height: 24),

                  // Device Section
                  _buildSectionTitle(appState.tr('Device', 'الجهاز')),
                  _buildSettingsItem(
                    icon: LucideIcons.locate,
                    title: appState.tr('Find My Bracelet', 'العثور على سواري'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WearerFindMyBraceletPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: LucideIcons.history,
                    title: appState.tr('QR Scan History', 'سجل مسح QR'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WearerQrScanHistoryPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Privacy Section
                  _buildSectionTitle(
                    appState.tr('Privacy Policy', 'سياسة الخصوصية'),
                  ),
                  _buildSettingsItem(
                    icon: LucideIcons.shieldCheck,
                    title: appState.tr('Privacy Policy', 'سياسة الخصوصية'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WearerPrivacyPolicyPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Support Section
                  _buildSectionTitle(appState.tr('Support', 'الدعم')),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: LucideIcons.helpCircle,
                          title: appState.tr('Help Center', 'مركز المساعدة'),
                          noMargin: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WearerHelpCenterPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey.shade100,
                          indent: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.info,
                                  color: Color(0xFF1B64F2),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  appState.tr('App Version', 'إصدار التطبيق'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF273469),
                                  ),
                                ),
                              ),
                              Text(
                                'v2.4.0 (Wearer Edition)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LogoutLoadingPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFFE4E6),
                          width: 1.5,
                        ),
                        backgroundColor: const Color(0xFFFFF1F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        appState.tr('Logout', 'تسجيل الخروج'),
                        style: const TextStyle(
                          color: Color(0xFFE11D48),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Color(0xFF273469),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool noMargin = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: noMargin ? 0 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: noMargin ? BorderRadius.zero : BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF1B64F2), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF273469),
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: Colors.grey.shade300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B64F2), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF273469),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF1B64F2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
