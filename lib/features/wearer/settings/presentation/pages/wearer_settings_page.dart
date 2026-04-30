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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.06).clamp(16.0, 28.0);
        final bottomPad = mq.padding.bottom + (short * 0.22).clamp(72.0, 104.0);
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WearerHeader(),
                  SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),

                  Text(
                    appState.tr('Settings', 'الإعدادات'),
                    style: TextStyle(
                      fontSize: (short * 0.07).clamp(22.0, 28.0),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF273469),
                    ),
                  ),
                  SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
                  Text(
                    appState.tr('Security & Preferences', 'الأمن والتفضيلات'),
                    style: TextStyle(
                      fontSize: (short * 0.036).clamp(13.0, 15.0),
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),

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

                  SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

                  // Security Section
                  _buildSectionTitle(appState.tr('Security', 'الأمان')),
                  _buildSettingsToggle(
                    icon: LucideIcons.fingerprint,
                    title: appState.tr('Biometric Lock', 'القفل الحيوي'),
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),

                  SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

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
                  SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
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

                  SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

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

                  SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

                  // Support Section
                  _buildSectionTitle(appState.tr('Support', 'الدعم')),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
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
                          padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
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
                              SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
                              Expanded(
                                child: Text(
                                  appState.tr('App Version', 'إصدار التطبيق'),
                                  style: TextStyle(
                                    fontSize: (short * 0.038).clamp(14.0, 16.0),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF273469),
                                  ),
                                ),
                              ),
                              Text(
                                'v2.4.0 (Wearer Edition)',
                                style: TextStyle(
                                  fontSize: (short * 0.033).clamp(12.0, 14.0),
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

                  SizedBox(height: (short * 0.12).clamp(34.0, 52.0)),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: (short * 0.16).clamp(54.0, 64.0),
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
                          borderRadius: BorderRadius.circular((short * 0.08).clamp(24.0, 32.0)),
                        ),
                      ),
                      child: Text(
                        appState.tr('Logout', 'تسجيل الخروج'),
                        style: TextStyle(
                          color: Color(0xFFE11D48),
                          fontSize: (short * 0.04).clamp(14.0, 17.0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    final short = MediaQuery.of(context).size.shortestSide;
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: (short * 0.03).clamp(8.0, 14.0)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: (short * 0.04).clamp(14.0, 17.0),
          fontWeight: FontWeight.w900,
          color: const Color(0xFF273469),
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
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: noMargin ? 0 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: noMargin ? BorderRadius.zero : BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
        child: Padding(
          padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all((short * 0.026).clamp(8.0, 12.0)),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF1B64F2), size: (short * 0.05).clamp(18.0, 22.0)),
              ),
              SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: (short * 0.038).clamp(14.0, 16.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF273469),
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
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all((short * 0.026).clamp(8.0, 12.0)),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B64F2), size: (short * 0.05).clamp(18.0, 22.0)),
          ),
          SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: (short * 0.038).clamp(14.0, 16.0),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF273469),
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
