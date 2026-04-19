import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart';
import 'package:q_link/features/guardian/settings/edit_profile_page.dart';
import 'package:q_link/features/guardian/settings/change_password_page.dart';
import 'package:q_link/features/guardian/settings/email_preferences_page.dart';
import 'package:q_link/features/guardian/settings/switch_role_page.dart';
import 'package:q_link/features/guardian/settings/qr_scan_history_page.dart';
import 'package:q_link/features/guardian/settings/privacy_policy_page.dart';
import 'package:q_link/features/guardian/settings/help_center_page.dart';
import 'package:q_link/features/auth/splash/logout_loading_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricLock = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (Logo, Profile, Lang, Notifications)
                          const HeaderWidget(),
                          
                          const SizedBox(height: 12),
                          Text(
                            appState.tr('Settings', 'الإعدادات'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF273469),
                            ),
                          ),
                          Text(
                            appState.tr('Security & Preferences', 'الأمان والتفضيلات'),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Profile Section
                          _buildSectionLabel(appState.tr('Profile', 'الملف الشخصي')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: Icons.person_outline,
                              title: appState.tr('Edit Profile', 'تعديل الملف الشخصي'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: LucideIcons.lock,
                              title: appState.tr('Change Password', 'تغيير كلمة المرور'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: LucideIcons.mail,
                              title: appState.tr('Email Preferences', 'تفضيلات البريد الإلكتروني'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EmailPreferencesPage()),
                                );
                              },
                            ),
                          ]),

                          _buildSectionLabel(appState.tr('Role', 'الدور')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: LucideIcons.shieldCheck,
                              title: '${appState.tr('Current Role', 'الدور الحالي')}: ${appState.tr(appState.currentUser.role, appState.currentUser.role == 'Guardian' ? 'وصي' : 'مرتدي')}',
                              subtitle: appState.tr('${appState.currentUser.role} Account', 'حساب ${appState.currentUser.role == 'Guardian' ? 'الوصي' : 'المرتدي'}'),
                              isBadge: true,
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: LucideIcons.layers,
                              title: appState.tr('Switch Role', 'تبديل الدور'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SwitchRolePage()),
                                );
                              },
                            ),
                          ]),

                          // Security Section
                          _buildSectionLabel(appState.tr('Security', 'الأمان')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: Icons.fingerprint,
                              title: appState.tr('Biometric Lock', 'القفل البيومتري'),
                              trailing: Switch(
                                value: _biometricLock,
                                onChanged: (v) => setState(() => _biometricLock = v),
                                activeColor: Colors.white,
                                activeTrackColor: const Color(0xFF3F83F8),
                              ),
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: LucideIcons.timer,
                              title: appState.tr('Auto Lock', 'قفل تلقائي'),
                              trailingText: '5 MINUTES',
                              onTap: () {},
                            ),
                          ]),

                          // App Preferences Section
                          _buildSectionLabel(appState.tr('App Preferences', 'تفضيلات التطبيق')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: LucideIcons.watch,
                              title: appState.tr('Notification', 'الإشعارات'),
                              subtitle: 'ACTIVE: QLINK PRO V2',
                              subtitleColor: const Color(0xFF0E9F6E),
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: LucideIcons.plusCircle,
                              title: appState.tr('Language', 'اللغة'),
                              customTrailing: const LanguageSelector(),
                              onTap: () {},
                            ),
                          ]),

                          // Data Section
                          _buildSectionLabel(appState.tr('Data', 'البيانات')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: LucideIcons.qrCode,
                              title: appState.tr('QR Scan History', 'سجل مسح QR'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const QrScanHistoryPage()),
                                );
                              },
                            ),
                          ]),

                          // Privacy Policy Section
                          _buildSectionLabel(appState.tr('Privacy Policy', 'سياسة الخصوصية')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: LucideIcons.shield,
                              title: appState.tr('Privacy Policy', 'سياسة الخصوصية'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                                );
                              },
                            ),
                          ]),

                          // Support Section
                          _buildSectionLabel(appState.tr('Support', 'الدعم')),
                          _buildCardWrapper([
                            _buildListTile(
                              icon: LucideIcons.helpCircle,
                              title: appState.tr('Help Center', 'مركز المساعدة'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HelpCenterPage()),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: LucideIcons.info,
                              title: appState.tr('App Version', 'إصدار التطبيق'),
                              trailingText: 'v2.4.0 (Guardian Edition)',
                              onTap: () {},
                            ),
                          ]),

                          const SizedBox(height: 32),
                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LogoutLoadingPage()),
                                );
                              },
                              icon: const Icon(LucideIcons.logOut, color: Colors.red, size: 18),
                              label: Text(
                                appState.tr('Logout', 'تسجيل الخروج'),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: const Color(0xFFFFF5F5),
                                side: const BorderSide(color: Color(0xFFFED7D7)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
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

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Color(0xFF273469),
        ),
      ),
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    bool isBadge = false,
    Widget? trailing,
    String? trailingText,
    Widget? customTrailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1B64F2), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
        ),
      ),
      subtitle: subtitle != null
        ? isBadge
            ? Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B64F2)),
                ),
              )
            : Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: subtitleColor ?? Colors.grey.shade400,
                ),
              )
        : null,
      trailing: customTrailing ?? (trailing ?? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                trailingText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
        ],
      )),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50);
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return Container(
      width: 140,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (appState.isArabic) appState.toggleLanguage();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !appState.isArabic ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !appState.isArabic ? [
                    const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ] : null,
                ),
                child: const Text('EN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!appState.isArabic) appState.toggleLanguage();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appState.isArabic ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: appState.isArabic ? [
                    const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ] : null,
                ),
                child: const Text('AR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
