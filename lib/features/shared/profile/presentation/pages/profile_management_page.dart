import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/profile/presentation/pages/emergency_info_page.dart';
import 'package:q_link/features/shared/profile/presentation/pages/connect_device_page.dart';
import 'package:q_link/features/shared/profile/presentation/pages/privacy_control_page.dart';
import 'package:q_link/features/shared/vault/presentation/pages/vault_detail_page.dart';
import 'package:q_link/features/shared/profile/presentation/pages/public_preview_qr_page.dart';
import 'package:q_link/features/shared/profile/presentation/pages/connected_device_page.dart';
import 'package:q_link/features/shared/profile/presentation/pages/locate_bracelet_page.dart';

class ProfileManagementPage extends StatelessWidget {
  final int profileIndex;
  final ProfileData profile;

  const ProfileManagementPage({
    super.key,
    required this.profileIndex,
    required this.profile,
  });

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back and Title
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appState.tr('Back', 'رجوع'),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const LanguageToggle(),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF273469),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: profile.imagePath.contains('mypic')
                                    ? Text(
                                        profile.name.isNotEmpty
                                            ? profile.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          profile.imagePath,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              Text(
                                profile.relationship,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1B64F2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Info Cards
                        _buildFeatureCard(
                          icon: Icons.language_outlined,
                          title: appState.tr(
                            'Emergency Info',
                            'معلومات الطوارئ',
                          ),
                          subtitle: appState.tr(
                            'Public - visible when scanned',
                            'عام - مرئي عند المسح',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyInfoPage(
                                  profileIndex: profileIndex,
                                  profile: profile,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: LucideIcons.eye,
                          title: appState.tr(
                            'Privacy Control',
                            'التحكم في الخصوصية',
                          ),
                          subtitle: appState.tr(
                            'Manage visibility',
                            'إدارة مستوى الرؤية',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivacyControlPage(
                                  profileIndex: profileIndex,
                                  profile: profile,
                                ),
                              ),
                            ).then((_) {
                              // Force rebuild of parent when returning
                              if (context.mounted)
                                (context as Element).markNeedsBuild();
                            });
                          },
                        ),
                        _buildFeatureCard(
                          icon: LucideIcons.shield,
                          title: appState.tr('Vault', 'الخزنة'),
                          subtitle: appState.tr(
                            'App-only • Secured with lock\nAccess sensitive reports',
                            'للتطبيق فقط • محمي برمز\nالوصول للتقارير الحساسة',
                          ),
                          isLocked: true,
                          onTap: () {
                            // Safe conversion of primitive list to Maps
                            List<Map<String, String>> mappedContacts = profile
                                .emergencyContacts
                                .map((contact) {
                                  return {
                                    'name': appState.tr('Contact', 'جهة اتصال'),
                                    'phone': contact,
                                  };
                                })
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VaultDetailPage(
                                  name: profile.name,
                                  imagePath: profile.imagePath,
                                  monitoredSince: appState.tr(
                                    'Since connected',
                                    'منذ الاتصال',
                                  ),
                                  statusLabel: profile.hasDevice
                                      ? appState.tr('Active', 'نشط')
                                      : appState.tr(
                                          'No Device',
                                          'لا يوجد جهاز',
                                        ),
                                  statusColor: profile.hasDevice
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFDE8E8),
                                  bloodType: profile.bloodType,
                                  condition: profile.condition,
                                  allergies: profile.allergies,
                                  emergencyContacts: mappedContacts,
                                  documents: const [
                                    {
                                      'title': 'Medical Document',
                                      'date': 'Just now',
                                      'size': '1.2 MB',
                                      'format': 'PDF',
                                    },
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: LucideIcons.qrCode,
                          title: appState.tr('QR Preview', 'معاينة QR'),
                          subtitle: appState.tr(
                            'See what scanners see',
                            'شاهد ما يراه الماسحون',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PublicPreviewQrPage(profile: profile),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                        Text(
                          appState.tr('Device', 'الجهاز'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Device Section
                        if (profile.hasDevice)
                          _buildActionItem(
                            icon: Icons.watch_outlined,
                            title: appState.tr(
                              'Connected Device',
                              'الجهاز المتصل',
                            ),
                            subtitle: profile.devices.first.code.toUpperCase(),
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ConnectedDevicePage(),
                                ),
                              );
                            },
                          ),

                        _buildActionItem(
                          icon: Icons.add_circle_outline,
                          title: appState.tr('Add Device', 'إضافة جهاز'),
                          color: const Color(0xFF1B64F2),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConnectDevicePage(
                                  targetProfileIndex: profileIndex,
                                ),
                              ),
                            );
                          },
                        ),

                        _buildActionItem(
                          icon: Icons.my_location_outlined,
                          title: appState.tr(
                            'Find My Bracelet',
                            'البحث عن سواري',
                          ),
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            _showDeleteConfirm(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            appState.tr('Delete Bracelet', 'حذف السوار'),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1B64F2), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked)
              const Icon(LucideIcons.lock, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF1B64F2)).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? const Color(0xFF1B64F2), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppState().tr('Delete Profile', 'حذف الملف الشخصي')),
        content: Text(
          '${AppState().tr('Are you sure you want to delete', 'هل أنت متأكد أنك تريد حذف')} ${profile.name}? ${AppState().tr('This action cannot be undone.', 'لا يمكن التراجع عن هذا الإجراء.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppState().tr('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () {
              AppState().removeProfile(profileIndex);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to home
            },
            child: Text(
              AppState().tr('Delete', 'حذف'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
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
              color: Colors.blue.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(35),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    context,
                    icon: LucideIcons.home,
                    label: AppState().tr('Home', 'الرئيسية'),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.map,
                    label: AppState().tr('Map', 'الخريطة'),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B64F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.lock,
                    label: AppState().tr('Vault', 'الخزنة'),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.settings,
                    label: AppState().tr('Settings', 'الإعدادات'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
