import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/auth/presentation/pages/sign_in_page.dart';
import 'package:q_link/features/guardian/home/main_page.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_initial_setup_page.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAccountPage extends StatefulWidget {
  final String role;
  
  const CreateAccountPage({super.key, required this.role});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarPath;

  bool _isGuardianLike(String? role) {
    final r = (role ?? '').toLowerCase();
    return r == 'guardian' || r == 'admin';
  }

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
        SnackBar(content: Text(AppState().tr('Please fill all fields', 'يرجى ملء جميع الحقول'))),
      );
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppState().tr(
              'Please enter a valid email address',
              'يرجى إدخال بريد إلكتروني صحيح',
            ),
          ),
        ),
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
      String avatarUrl =
          'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/profiles/default.png';
      if (user != null) {
        if (_selectedAvatarBytes != null) {
          final uploadedUrl = await SupabaseService()
              .uploadAndSaveUserAvatar(_selectedAvatarBytes!, user.id);
          if (uploadedUrl != null) {
            avatarUrl = uploadedUrl;
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Avatar upload failed: ${SupabaseService().lastUploadError ?? 'unknown error'}',
                ),
              ),
            );
          }
        }

        await _upsertProfileWithRoleFallback(
          userId: user.id,
          fullName: name,
          email: email,
          preferredRole: widget.role,
          avatarUrl: avatarUrl,
        );
      }

      if (mounted && user != null) {
        final openGuardianShell = _isGuardianLike(widget.role);
        AppState().updateCurrentUser(
          name: name,
          email: email,
          password: '',
          imagePath: avatarUrl,
          role: widget.role,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => openGuardianShell
                ? const MainPage() 
                : const WearerInitialSetupPage(),
            settings: RouteSettings(name: openGuardianShell ? 'MainPage' : 'WearerInitialSetupPage'),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppState().tr(
                  'Could not create account. Check email confirmation settings.',
                  'تعذر إنشاء الحساب. تحقق من إعدادات تأكيد البريد الإلكتروني.',
                ),
              ),
            ),
          );
        }
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
                      'تنسيق البريد الإلكتروني غير صحيح. مثال: name@email.com',
                    )
                  : 'Error: ${e.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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

      await Supabase.instance.client.from('profiles').upsert({
        ...profilePayload,
        'role': 'Guardian',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final appState = AppState();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB81829),
              Color(0xFF4C3A71),
              Color(0xFF015196),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mq = MediaQuery.of(context);
              final padBottom = mq.padding.bottom + mq.viewInsets.bottom + 20.0;
              final shortest = mq.size.shortestSide;
              final logoH = (shortest * 0.19).clamp(52.0, 78.0);
              final titleSize = (mq.size.width * 0.07).clamp(22.0, 30.0);
              final subtitleSize = (mq.size.width * 0.035).clamp(12.0, 16.0);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, padBottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - mq.padding.vertical - 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: (shortest * 0.02).clamp(4.0, 12.0)),
                      Center(
                        child: Image.asset(
                          'assets/images/qlink_logo.png',
                          height: logoH,
                          color: Colors.white,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Qlink',
                                style: TextStyle(
                                  fontSize: (titleSize * 1.5).clamp(26.0, 40.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(18.0, 32.0)),
                      Text(
                        appState.tr('Create Account', 'إنشاء حساب'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Century Gothic',
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: (shortest * 0.015).clamp(6.0, 10.0)),
                      Text(
                        appState.tr('Starts your safety journey', 'ابدأ رحلة سلامتك'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(18.0, 32.0)),
                      Center(
                        child: _buildAuthAvatar(context),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(18.0, 32.0)),
                      _buildTextField(
                        controller: _nameController,
                        hintText: appState.tr('Full Name', 'الاسم الكامل'),
                      ),
                      SizedBox(height: (shortest * 0.038).clamp(12.0, 20.0)),
                      _buildTextField(
                        controller: _emailController,
                        hintText: appState.tr('Email Address', 'عنوان البريد الإلكتروني'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: (shortest * 0.038).clamp(12.0, 20.0)),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: appState.tr('Password', 'كلمة المرور'),
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(20.0, 32.0)),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28365B),
                          padding: EdgeInsets.symmetric(
                            vertical: (shortest * 0.038).clamp(14.0, 18.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  appState.tr(
                                    'Create a ${widget.role} Hub',
                                    'إنشاء حساب ${widget.role}',
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: (mq.size.width * 0.04).clamp(14.0, 17.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: (shortest * 0.065).clamp(24.0, 40.0)),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.8),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              appState.tr('OR', 'أو'),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.8),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(20.0, 32.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            context,
                            iconWidget: Image.asset(
                              'assets/icons/fb2.png',
                              width: (shortest * 0.09).clamp(28.0, 38.0),
                              height: (shortest * 0.09).clamp(28.0, 38.0),
                            ),
                            backgroundColor: Colors.transparent,
                            borderColor: Colors.white,
                            onTap: () {},
                          ),
                          SizedBox(width: (shortest * 0.045).clamp(12.0, 22.0)),
                          _buildSocialButton(
                            context,
                            iconWidget: Image.asset(
                              'assets/icons/google2.png',
                              width: (shortest * 0.085).clamp(26.0, 36.0),
                              height: (shortest * 0.085).clamp(26.0, 36.0),
                            ),
                            backgroundColor: Colors.transparent,
                            borderColor: Colors.white,
                            onTap: () {},
                          ),
                          SizedBox(width: (shortest * 0.045).clamp(12.0, 22.0)),
                          _buildSocialButton(
                            context,
                            iconWidget: Image.asset(
                              'assets/icons/apple2.png',
                              width: (shortest * 0.085).clamp(26.0, 36.0),
                              height: (shortest * 0.08).clamp(24.0, 34.0),
                            ),
                            backgroundColor: Colors.transparent,
                            borderColor: Colors.white,
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: (shortest * 0.065).clamp(24.0, 40.0)),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 8,
                        children: [
                          Text(
                            appState.tr('Already have an account ? ', 'هل لديك حساب بالفعل؟ '),
                            style: const TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignInPage(role: widget.role),
                                ),
                              );
                            },
                            child: Text(
                              appState.tr('Sign In', 'تسجيل الدخول'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (shortest * 0.04).clamp(12.0, 24.0)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthAvatar(BuildContext context) {
    final mq = MediaQuery.of(context);
    final avatarSize = (mq.size.shortestSide * 0.26).clamp(80.0, 112.0);
    final iconPerson = (avatarSize * 0.52).clamp(36.0, 54.0);

    Widget avatarChild;
    if (_selectedAvatarPath != null && _selectedAvatarPath!.isNotEmpty) {
      if (_selectedAvatarPath!.startsWith('http') || _selectedAvatarPath!.startsWith('blob:')) {
        avatarChild = Image.network(_selectedAvatarPath!, fit: BoxFit.cover);
      } else if (_selectedAvatarPath!.startsWith('assets')) {
        avatarChild = Image.asset(_selectedAvatarPath!, fit: BoxFit.cover);
      } else if (!kIsWeb) {
        avatarChild = Image.file(File(_selectedAvatarPath!), fit: BoxFit.cover);
      } else {
        avatarChild = Icon(Icons.person, size: iconPerson, color: Colors.white);
      }
    } else {
      avatarChild = Icon(Icons.person, size: iconPerson, color: Colors.white);
    }

    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(child: avatarChild),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all((avatarSize * 0.08).clamp(6.0, 10.0)),
              decoration: const BoxDecoration(
                color: Color(0xFF28365B),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: (avatarSize * 0.2).clamp(16.0, 22.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    TextEditingController? controller, 
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextField(
        controller: controller, // <-- w rabato hna bel TextField
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    Color backgroundColor = Colors.transparent,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    final d = (MediaQuery.sizeOf(context).shortestSide * 0.13).clamp(44.0, 56.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: Center(
          child: iconWidget ?? Icon(icon, color: iconColor, size: d * 0.62),
        ),
      ),
    );
  }
}