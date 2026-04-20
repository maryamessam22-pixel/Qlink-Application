import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/features/guardian/profile/emergency_info_page.dart';
import 'package:q_link/features/guardian/profile/connect_device_page.dart';
import 'package:q_link/features/guardian/profile/privacy_control_page.dart';
import 'package:q_link/features/guardian/vault/vault_detail_page.dart';
import 'package:q_link/features/guardian/profile/public_preview_qr_page.dart';
import 'package:q_link/features/guardian/profile/locate_bracelet_page.dart';
import 'package:q_link/features/guardian/profile/connected_device_page.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/services/supabase_service.dart';

class ProfileManagementPage extends StatefulWidget {
  final int profileIndex;
  final ProfileData profile;

  const ProfileManagementPage({
    super.key,
    required this.profileIndex,
    required this.profile,
  });

  @override
  State<ProfileManagementPage> createState() => _ProfileManagementPageState();
}

class _ProfileManagementPageState extends State<ProfileManagementPage> {
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _relationshipController = TextEditingController(
      text: widget.profile.relationship,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    widget.profile.name = _nameController.text;
    widget.profile.relationship = _relationshipController.text;

    if (widget.profile.id != null && widget.profile.id!.isNotEmpty) {
      try {
        await SupabaseService().client
            .from('patient_profiles')
            .update({
              'profile_name': _nameController.text,
              'relationship_to_guardian': _relationshipController.text,
            })
            .eq('id', widget.profile.id!);
      } catch (e) {
        debugPrint('Error updating profile: $e');
      }
    }

    if (widget.profileIndex >= 0 && widget.profileIndex < AppState().profileCount) {
      AppState().updateProfile(widget.profileIndex, widget.profile);
    }
    AppState().markProfilesDirty();

    setState(() => _isEditing = false);
  }

  Widget _buildProfileAvatar(ProfileData profile) {
    final path = profile.imagePath;
    if (path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    if (path.startsWith('assets')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    if (path.isNotEmpty && !kIsWeb) {
      return Image.file(File(path), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsAvatar(profile.name),
      );
    }
    return _buildInitialsAvatar(profile.name);
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFF273469),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Profile updated successfully', 'تم تحديث الملف بنجاح'))),
      );
    }
  }

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
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF273469),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1E3A8A,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: _buildProfileAvatar(widget.profile),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _isEditing
                                  ? TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: appState.tr(
                                          'Full Name',
                                          'الاسم الكامل',
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      widget.profile.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                              const SizedBox(height: 8),
                              _isEditing
                                  ? TextField(
                                      controller: _relationshipController,
                                      decoration: InputDecoration(
                                        labelText: appState.tr(
                                          'Relationship',
                                          'العلاقة',
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  : Text(
                                      widget.profile.relationship,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1B64F2),
                                      ),
                                    ),
                              const SizedBox(height: 16),
                              _isEditing
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => setState(
                                            () => _isEditing = false,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.grey.shade400,
                                          ),
                                          child: Text(
                                            appState.tr('Cancel', 'إلغاء'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: _saveChanges,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1B64F2,
                                            ),
                                          ),
                                          child: Text(
                                            appState.tr('Save', 'حفظ'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : OutlinedButton.icon(
                                      onPressed: () =>
                                          setState(() => _isEditing = true),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        appState.tr(
                                          'Edit Profile',
                                          'تعديل الملف',
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF1E3A8A,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
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
                                  profileIndex: widget.profileIndex,
                                  profile: widget.profile,
                                ),
                              ),
                            ).then((result) {
                              // If EmergencyInfoPage saved successfully, pop back to home so it re-fetches
                              if (result == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            });
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
                                  profileIndex: widget.profileIndex,
                                  profile: widget.profile,
                                ),
                              ),
                            ).then((_) {
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
                            List<Map<String, String>> mappedContacts = widget
                                .profile
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
                                  profile: PatientProfile(
                                    id: widget.profile.id ?? '',
                                    guardianId: '',
                                    profileName: widget.profile.name,
                                    relationshipToGuardian:
                                        widget.profile.relationship,
                                    birthYear:
                                        int.tryParse(
                                          widget.profile.birthYear,
                                        ) ??
                                        0,
                                    age: 0,
                                    emergencyContacts: {
                                      'primary': {
                                        'name': mappedContacts.isNotEmpty
                                            ? mappedContacts[0]['name']
                                            : '',
                                        'relation': widget.profile.relationship,
                                      },
                                    },
                                    bloodType: widget.profile.bloodType,
                                    safetyNotesEn: '',
                                    allergiesEn: widget.profile.allergies,
                                    medicalNotesEn: widget.profile.condition,
                                    medicalNotesAr: '',
                                    status: widget.profile.hasDevice,
                                    avatarUrl: widget.profile.imagePath,
                                    seoSlug: '',
                                    metaTitleEn: '',
                                    metaDescriptionEn: '',
                                    featuredImageAltEn: '',
                                    safetyNotesAr: '',
                                    allergiesAr: '',
                                    metaTitleAr: '',
                                    metaDescriptionAr: '',
                                    featuredImageAltAr: '',
                                    createdAt: DateTime.now(),
                                  ),
                                  documents: const [
                                    {
                                      'title': 'Medical Document',
                                      'subtitle': 'PDF • 1.2 MB',
                                      'type': 'PDF',
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
                                builder: (context) => PublicPreviewQrPage(
                                  profile: widget.profile,
                                ),
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

                        _buildActionItem(
                          icon: Icons.add_circle_outline,
                          title: appState.tr('Add Device', 'إضافة جهاز'),
                          color: const Color(0xFF1B64F2),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConnectDevicePage(
                                  targetProfileIndex: widget.profileIndex,
                                  targetProfileId: widget.profile.id,
                                ),
                              ),
                            ).then((result) {
                              if (result == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            });
                          },
                        ),

                        if (widget.profile.hasDevice)
                          _buildActionItem(
                            icon: Icons.watch_outlined,
                            title: appState.tr(
                              'Connected Device',
                              'الجهاز المتصل',
                            ),
                            subtitle: widget.profile.devices.isNotEmpty
                                ? widget.profile.devices.first.code
                                : null,
                            color: const Color(0xFF0E9F6E),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConnectedDevicePage(
                                    profile: widget.profile,
                                  ),
                                ),
                              ).then((result) {
                                // Device was disconnected — pop back to home to refresh
                                if (result == true && mounted) {
                                  Navigator.pop(context, true);
                                }
                              });
                            },
                          ),

                        _buildActionItem(
                          icon: Icons.my_location_outlined,
                          title: appState.tr(
                            'Find My Bracelet',
                            'البحث عن سواري',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LocateBraceletPage(profile: widget.profile),
                              ),
                            );
                          },
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
          bottomNavigationBar: const BottomNavWidget(),
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
      builder: (dialogCtx) => AlertDialog(
        title: Text(AppState().tr('Delete Profile', 'حذف الملف الشخصي')),
        content: Text(
          '${AppState().tr('Are you sure you want to delete', 'هل أنت متأكد أنك تريد حذف')} ${widget.profile.name}? ${AppState().tr('This action cannot be undone.', 'لا يمكن التراجع عن هذا الإجراء.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(AppState().tr('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () async {
              // Delete from Supabase
              if (widget.profile.id != null && widget.profile.id!.isNotEmpty) {
                try {
                  await SupabaseService().client
                      .from('patient_profiles')
                      .delete()
                      .eq('id', widget.profile.id!);
                } catch (e) {
                  debugPrint('Error deleting profile: $e');
                }
              }
              AppState().removeProfile(widget.profileIndex);
              AppState().markProfilesDirty();
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (context.mounted) Navigator.pop(context, true);
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
}
