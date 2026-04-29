import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/settings/change_password_page.dart';
import 'package:q_link/features/guardian/settings/email_preferences_page.dart';
import 'package:q_link/services/supabase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AppState().currentUser.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedAvatarPath = image.path;
          _selectedAvatarBytes = bytes;
        });
        AppState().updateCurrentUser(imagePath: image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final appState = AppState();

    try {
      final userId = SupabaseService().client.auth.currentUser?.id;
      String? avatarUrl = appState.currentUser.imagePath;

      if (userId != null && _selectedAvatarBytes != null) {
        final uploaded = await SupabaseService()
            .uploadAndSaveUserAvatar(_selectedAvatarBytes!, userId);
        if (uploaded != null) {
          avatarUrl = uploaded;
        } else {
          throw Exception(
            SupabaseService().lastUploadError ?? 'Avatar upload failed',
          );
        }
      }

      if (userId != null) {
        await SupabaseService().client.from('profiles').update({
          'full_name': _nameController.text.trim(),
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
        }).eq('id', userId);
      }

      appState.updateCurrentUser(
        name: _nameController.text.trim(),
        imagePath: avatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.tr('Changes saved successfully', 'تم حفظ التغييرات بنجاح'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final user = appState.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Text(
                          appState.tr('Edit Profile', 'تعديل الملف الشخصي'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF273469),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Image with Camera Icon
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _buildProfileImage(user.imagePath),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1B64F2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(LucideIcons.camera, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${appState.tr('Current Role', 'الدور الحالي')}: ${appState.tr(user.role, user.role == 'Guardian' ? 'وصي' : 'مرتدي')}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appState.tr('${user.role} Account', 'حساب ${user.role == 'Guardian' ? 'الوصي' : 'المرتدي'}'),
                              style: const TextStyle(color: Color(0xFF1B64F2), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form Fields
                          _buildTextField(
                            label: appState.tr('Full Name', 'الاسم بالكامل'),
                            controller: _nameController,
                          ),
                          const SizedBox(height: 20),
                          _buildNavigationField(
                            label: appState.tr('Password', 'كلمة المرور'),
                            value: '********',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildNavigationField(
                            label: appState.tr('Email Address', 'البريد الإلكتروني'),
                            value: user.email,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EmailPreferencesPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 48),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B64F2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      appState.tr('Save Changes', 'حفظ التغييرات'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                            ),
                          ),
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

  Widget _buildProfileImage(String path) {
    if (path.startsWith('assets')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else if (path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 60, color: Color(0xFF1B64F2));
      });
    } else if (!kIsWeb) {
      return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 60, color: Color(0xFF1B64F2));
      });
    } else {
      return const Icon(Icons.person, size: 60, color: Color(0xFF1B64F2));
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B64F2), width: 1.5),
            ),
          ),
          style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildNavigationField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
