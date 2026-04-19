import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                        Text(
                          appState.tr('Settings', 'الإعدادات'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appState.tr('Manage your preferences and app security', 'إدارة تفضيلاتك وأمان التطبيق'),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 40),

                        // Account Section
                        _buildSectionHeader(appState.tr('Account', 'الحساب')),
                        _buildSettingsItem(
                          icon: LucideIcons.user,
                          title: appState.tr('Personal Information', 'المعلومات الشخصية'),
                          subtitle: appState.tr('Update your name and profile details', 'تحديث اسمك وتفاصيل الملف الشخصي'),
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: LucideIcons.bell,
                          title: appState.tr('Notifications', 'الإشعارات'),
                          subtitle: appState.tr('Manage how you receive alerts', 'إدارة كيفية تلقي التنبيهات'),
                          onTap: () {},
                        ),

                        const SizedBox(height: 24),
                        // App Settings Section
                        _buildSectionHeader(appState.tr('App Settings', 'إعدادات التطبيق')),
                        _buildSettingsItem(
                          icon: LucideIcons.languages,
                          title: appState.tr('Language', 'اللغة'),
                          subtitle: appState.isArabic ? 'العربية' : 'English',
                          trailing: const LanguageToggle(),
                          onTap: () => appState.toggleLanguage(),
                        ),
                        _buildSettingsItem(
                          icon: LucideIcons.shieldCheck,
                          title: appState.tr('Privacy & Security', 'الخصوصية والأمان'),
                          subtitle: appState.tr('Manage data and connectivity', 'إدارة البيانات والاتصال'),
                          onTap: () {},
                        ),

                        const SizedBox(height: 24),
                        // Support Section
                        _buildSectionHeader(appState.tr('Support', 'الدعم')),
                        _buildSettingsItem(
                          icon: LucideIcons.helpCircle,
                          title: appState.tr('Help Center', 'مركز المساعدة'),
                          subtitle: appState.tr('FAQ and customer support', 'الأسئلة الشائعة ودعم العملاء'),
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: LucideIcons.info,
                          title: appState.tr('About Qlink', 'عن كيو لينك'),
                          subtitle: 'Version 1.0.2',
                          onTap: () {},
                        ),

                        const SizedBox(height: 40),
                        
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.logOut, color: Colors.red),
                            label: Text(
                              appState.tr('Log Out', 'تسجيل الخروج'),
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.red.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B64F2),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1B64F2), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}
