import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/auth/splash/choose_role_page.dart';
import 'package:q_link/features/auth/presentation/pages/wearer/wearer_sign_in_page.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_initial_setup_page.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WearerCreateAccountPage extends StatefulWidget {
  const WearerCreateAccountPage({super.key});

  @override
  State<WearerCreateAccountPage> createState() =>
      _WearerCreateAccountPageState();
}

class _WearerCreateAccountPageState extends State<WearerCreateAccountPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarPath;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _selectedAvatarPath = image.path;
      _selectedAvatarBytes = bytes;
    });
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Please fill in all fields', 'يرجى ملء جميع الحقول'))),
      );
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Please enter a valid email address', 'يرجى إدخال بريد إلكتروني صحيح'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Could not create account');
      }

      String avatarUrl =
          'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/profiles/default.png';
      if (_selectedAvatarBytes != null) {
        final uploadedUrl = await SupabaseService()
            .uploadAndSaveUserAvatar(_selectedAvatarBytes!, user.id);
        if (uploadedUrl != null) {
          avatarUrl = uploadedUrl;
        }
      }

      await _upsertProfileWithRoleFallback(
        userId: user.id,
        fullName: name,
        email: email,
        preferredRole: 'Wearer',
        avatarUrl: avatarUrl,
      );

      AppState().updateCurrentUser(
        name: name,
        email: email,
        password: '',
        imagePath: avatarUrl,
        role: 'Wearer',
      );

      if (mounted) {
        // Navigate to initial setup screen which shows "Create Your Profile" intro
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WearerInitialSetupPage(),
            settings: const RouteSettings(name: 'WearerInitialSetupPage'),
          ),
          (route) => false,
        );
      }
    } on AuthApiException catch (e) {
      if (mounted) {
        final isInvalidEmail =
            e.code == 'validation_failed' || e.message.contains('invalid format');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInvalidEmail
                  ? AppState().tr(
                      'Invalid email format. Example: name@email.com',
                      'صيغة البريد الإلكتروني غير صحيحة. مثال: name@email.com',
                    )
                  : AppState().tr('Sign up failed: ${e.message}', 'فشل إنشاء الحساب: ${e.message}'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppState().tr('Error: $e', 'خطأ: $e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _upsertProfileWithRoleFallback({
    required String userId,
    required String fullName,
    required String email,
    required String preferredRole,
    required String avatarUrl,
  }) async {
    final profilePayload = {
      'id': userId,
      'full_name': fullName,
      'email': email,
      'status': true,
      'job_title': 'New Member',
      'registration_date': DateTime.now().toIso8601String().split('T')[0],
      'avatar_url': avatarUrl,
    };

    try {
      await Supabase.instance.client.from('profiles').upsert({
        ...profilePayload,
        'role': preferredRole,
      });
    } on PostgrestException catch (e) {
      final isRoleConstraintError =
          e.code == '23514' || (e.message.contains('profiles_role_check'));
      if (!isRoleConstraintError) rethrow;

      // Fallback for DBs where role check currently allows Guardian only.
      await Supabase.instance.client.from('profiles').upsert({
        ...profilePayload,
        'role': 'Guardian',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final shortest = mq.size.shortestSide;
            final padBottom = mq.padding.bottom + mq.viewInsets.bottom + 16.0;
            final logoH = (shortest * 0.22).clamp(56.0, 92.0);
            final titleSize = (mq.size.width * 0.072).clamp(22.0, 30.0);
            final avatarSize = (shortest * 0.26).clamp(80.0, 112.0);
            final iconInAvatar = (avatarSize * 0.48).clamp(38.0, 56.0);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 12, 24, padBottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - mq.padding.vertical - 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => const ChooseRolePage(),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.grey.shade700, size: 22),
                            const SizedBox(width: 4),
                            Text(
                              AppState().tr('Back', 'رجوع'),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: (mq.size.width * 0.04).clamp(14.0, 17.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: (shortest * 0.03).clamp(12.0, 24.0)),
                    Center(
                      child: Image.asset('assets/images/qlink_logo.png', height: logoH),
                    ),
                    SizedBox(height: (shortest * 0.03).clamp(12.0, 24.0)),
                    Text(
                      AppState().tr('Wearer Sign Up', 'تسجيل حساب المرافق'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: (shortest * 0.05).clamp(20.0, 40.0)),
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF1B64F2), width: 2),
                              ),
                              child: ClipOval(child: _buildAvatarPreview(iconInAvatar)),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all((avatarSize * 0.08).clamp(6.0, 10.0)),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1B64F2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: (avatarSize * 0.18).clamp(15.0, 22.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: (shortest * 0.045).clamp(14.0, 22.0)),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppState().tr('Full Name', 'الاسم الكامل'),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: (shortest * 0.045).clamp(14.0, 22.0)),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppState().tr('Email', 'البريد الإلكتروني'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: (shortest * 0.045).clamp(14.0, 22.0)),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppState().tr('Password', 'كلمة المرور'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: (shortest * 0.055).clamp(22.0, 34.0)),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B64F2),
                        padding: EdgeInsets.symmetric(
                          vertical: (shortest * 0.038).clamp(14.0, 18.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppState().tr('Create Account', 'إنشاء حساب'),
                              style: TextStyle(
                                fontSize: (mq.size.width * 0.045).clamp(15.0, 19.0),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(height: (shortest * 0.045).clamp(16.0, 26.0)),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 8,
                      children: [
                        Text(AppState().tr("Already have an account? ", 'لديك حساب بالفعل؟ ')),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WearerSignInPage(),
                            ),
                          ),
                          child: Text(
                            AppState().tr('Sign In', 'تسجيل الدخول'),
                            style: const TextStyle(
                              color: Color(0xFF1B64F2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (shortest * 0.04).clamp(12.0, 20.0)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(double iconSize) {
    if (_selectedAvatarPath == null || _selectedAvatarPath!.isEmpty) {
      return Icon(Icons.person, size: iconSize, color: const Color(0xFF1B64F2));
    }
    if (_selectedAvatarPath!.startsWith('http') ||
        _selectedAvatarPath!.startsWith('blob:')) {
      return Image.network(_selectedAvatarPath!, fit: BoxFit.cover);
    }
    if (_selectedAvatarPath!.startsWith('assets')) {
      return Image.asset(_selectedAvatarPath!, fit: BoxFit.cover);
    }
    if (!kIsWeb) {
      return Image.file(File(_selectedAvatarPath!), fit: BoxFit.cover);
    }
    return Icon(Icons.person, size: iconSize, color: const Color(0xFF1B64F2));
  }
}
