import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/auth/presentation/pages/create_account_page.dart';
import 'package:q_link/features/guardian/home/main_page.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart'
    show getUserAvatarProvider;
import 'package:q_link/features/shared/helpers/emergency_qr_scan.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/services/notification_service.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  final String role;
  const SignInPage({super.key, required this.role});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarPath;
  final MobileScannerController _scannerController = MobileScannerController();
  StreamSubscription<AuthState>? _authSubscription;
  bool _scanBusy = false;

  bool _isGuardianLike(String? role) {
    final r = (role ?? '').toLowerCase();
    return r == 'guardian' || r == 'admin';
  }

  Future<void> _handleGoogleLogin() async {
    try {
      await _authSubscription?.cancel();
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) async {
            if (data.event != AuthChangeEvent.signedIn ||
                data.session == null ||
                !mounted) {
              return;
            }

            await _ensureOAuthProfile();
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          });

      // Use Supabase's native OAuth flow
      // This will open a popup on web automatically
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.mariamfarid.qlink://login-callback',
        queryParams: {
          'prompt': 'select_account', // Force account picker every time
        },
      );
      
      // Check if user logged in successfully
      if (Supabase.instance.client.auth.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (error) {
      if (error.toString().contains('popup_closed') || 
          error.toString().contains('User cancelled')) {
        // User cancelled the login, don't show error
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppState().tr(
              'Sign in failed: $error',
              'فشل التوقيع: $error',
            ),
            style: const TextStyle(fontFamily: 'Roboto'),
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _ensureOAuthProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final existing = await client
        .from('profiles')
        .select('id, role')
        .eq('id', user.id)
        .maybeSingle();

    final role = widget.role.trim().isEmpty ? 'Guardian' : widget.role.trim();
    final metadata = user.userMetadata ?? {};
    final displayName =
        (metadata['full_name'] ?? metadata['name'] ?? user.email ?? 'User')
            .toString();
    final avatarUrl = (metadata['avatar_url'] ?? metadata['picture'] ?? '')
        .toString();

    if (existing == null) {
      await client.from('profiles').insert({
        'id': user.id,
        'full_name': displayName,
        'email': user.email ?? '',
        'role': role,
        'status': true,
        'job_title': 'New Member',
        'registration_date': DateTime.now().toIso8601String().split('T')[0],
        'avatar_url': avatarUrl,
      });
      return;
    }

    final existingRole = (existing['role'] ?? '').toString().trim();
    if (existingRole.isEmpty) {
      await client.from('profiles').update({'role': role}).eq('id', user.id);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _scannerController.dispose();
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

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppState().tr(
              'Please enter both email and password',
              'يرجى إدخال البريد الإلكتروني وكلمة المرور',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      final user = authResponse.user;
      var userData = user == null
          ? null
          : await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('id', user.id)
                .maybeSingle();

      // If profile doesn't exist, create one
      if (userData == null && user != null) {
        try {
          await Supabase.instance.client.from('profiles').insert({
            'id': user.id,
            'full_name': email.split('@')[0],
            'email': email,
            'role': widget.role.toLowerCase(),
            'status': true,
            'job_title': 'Member',
            'registration_date': DateTime.now().toIso8601String().split('T')[0],
            'avatar_url': '',
          });
          // Fetch the newly created profile
          userData = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
        } catch (e) {
          debugPrint('Error creating profile: $e');
        }
      }

      if (userData != null) {
        String resolvedAvatar = userData['avatar_url'] ?? '';
        if (_selectedAvatarBytes != null && user != null) {
          final uploadedUrl = await SupabaseService().uploadAndSaveUserAvatar(
            _selectedAvatarBytes!,
            user.id,
          );
          if (uploadedUrl != null) {
            resolvedAvatar = uploadedUrl;
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

        AppState().updateCurrentUser(
          name: userData['full_name'] ?? 'Unknown',
          email: userData['email'] ?? email,
          password: '',
          imagePath: resolvedAvatar,
          role: (userData['role'] ?? widget.role).toLowerCase(),
        );

        try {
          NotificationService().startRealtimeListener();
        } catch (e) {
          debugPrint('[SignIn] Realtime listener start failed: $e');
        }

        final resolvedRole = (userData['role'] ?? widget.role).toString();
        final openGuardianShell = _isGuardianLike(resolvedRole);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  openGuardianShell ? const MainPage() : const WearerMainPage(),
              settings: RouteSettings(
                name: openGuardianShell ? 'MainPage' : 'WearerMainPage',
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppState().tr(
                  'Invalid email or password',
                  'البريد الإلكتروني أو كلمة المرور غير صحيحة',
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppState().tr(
              'Please enter your email first',
              'يرجى إدخال بريدك الإلكتروني أولاً',
            ),
          ),
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppState().tr(
                'Password reset link sent to your email',
                'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _handleScanDevice() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _buildScannerPage()),
    );
  }

  Widget _buildScannerPage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) async {
              if (_scanBusy) return;
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = barcodes.first.rawValue;
              if (raw == null || raw.trim().isEmpty) return;
              _scanBusy = true;
              try {
                if (mounted) {
                  Navigator.pop(context);
                  await navigateEmergencyPreviewFromQrRaw(context, raw);
                }
              } finally {
                if (mounted) _scanBusy = false;
              }
            },
          ),
          Center(
            child: Container(
              width: (MediaQuery.of(context).size.shortestSide * 0.68).clamp(
                220.0,
                280.0,
              ),
              height: (MediaQuery.of(context).size.shortestSide * 0.68).clamp(
                220.0,
                280.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1B64F2), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: (MediaQuery.of(context).size.shortestSide * 0.3).clamp(
              92.0,
              132.0,
            ),
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppState().tr('Scan Device QR', 'مسح رمز QR للجهاز'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    AppState().tr(
                      'Position the QR code within the frame',
                      'ضع رمز QR داخل الإطار',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --------------------------------------------------------

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
            colors: [Color(0xFFB81829), Color(0xFF4C3A71), Color(0xFF015196)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mq = MediaQuery.of(context);
              final padBottom = mq.padding.bottom + mq.viewInsets.bottom + 16.0;
              final shortest = mq.size.shortestSide;
              final logoH = (shortest * 0.2).clamp(52.0, 84.0);
              final titleSize = (mq.size.width * 0.072).clamp(22.0, 30.0);
              final subtitleSize = (mq.size.width * 0.035).clamp(12.0, 15.0);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, padBottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - mq.padding.vertical - 8,
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
                                  fontSize: (titleSize * 1.6).clamp(28.0, 44.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: (shortest * 0.04).clamp(16.0, 32.0)),
                      Text(
                        () {
                          final r = widget.role.toLowerCase();
                          if (r == 'guardian' || r == 'admin') {
                            return appState.tr('Guardian Hub', 'مركز الوصي');
                          } else if (r == 'wearer') {
                            return appState.tr('Wearer Hub', 'مركز المستخدم');
                          }
                          return appState.tr(
                            '${widget.role} Hub',
                            'مركز الدخول',
                          );
                        }(),
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
                        appState.tr(
                          'Secure Access Required',
                          'مطلوب الوصول الآمن',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: (shortest * 0.045).clamp(18.0, 28.0)),
                      Center(child: _buildAuthAvatar(context)),
                      SizedBox(height: (shortest * 0.055).clamp(16.0, 28.0)),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'e.g., user@example.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: (shortest * 0.038).clamp(12.0, 20.0)),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '........',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                      SizedBox(height: (shortest * 0.02).clamp(6.0, 10.0)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _handleForgotPassword,
                          child: Text(
                            appState.tr(
                              'Forgot Password?',
                              'هل نسيت كلمة المرور؟',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(20.0, 32.0)),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
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
                            : Text(
                                appState.tr('Sign In', 'تسجيل الدخول'),
                                style: TextStyle(
                                  fontSize: (mq.size.width * 0.04).clamp(
                                    14.0,
                                    17.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      SizedBox(height: (shortest * 0.07).clamp(24.0, 40.0)),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.8),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              appState.tr('OR', 'أو'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
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
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: const Color(0xFF28365B),
                          borderRadius: BorderRadius.circular(25.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25.0),
                            onTap: _handleGoogleLogin,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/google2.png',
                                    width: (shortest * 0.085).clamp(26.0, 36.0),
                                    height: (shortest * 0.085).clamp(
                                      26.0,
                                      36.0,
                                    ),
                                  ),
                                  SizedBox(
                                    width: (shortest * 0.03).clamp(8.0, 12.0),
                                  ),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: (mq.size.width * 0.04).clamp(
                                        14.0,
                                        17.0,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(20.0, 32.0)),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.8),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              appState.tr('EMERGENCY', 'طوارئ'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: (mq.size.width * 0.03).clamp(
                                  10.0,
                                  13.0,
                                ),
                              ),
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
                      SizedBox(height: (shortest * 0.045).clamp(14.0, 22.0)),
                      ElevatedButton(
                        onPressed: _handleScanDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE223C),
                          padding: EdgeInsets.symmetric(
                            vertical: (shortest * 0.038).clamp(14.0, 18.0),
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Text(
                                  appState.tr('Scan Device', 'مسح الجهاز'),
                                  style: TextStyle(
                                    fontSize: (mq.size.width * 0.035).clamp(
                                      11.0,
                                      15.0,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (shortest * 0.055).clamp(20.0, 32.0)),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 8,
                        children: [
                          Text(
                            appState.tr('New to Qlink? ', 'جديد في كيولينك؟ '),
                            style: const TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CreateAccountPage(role: widget.role),
                                ),
                              );
                            },
                            child: Text(
                              appState.tr('Create Account', 'إنشاء حساب'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (shortest * 0.035).clamp(14.0, 24.0)),
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
    final iconPerson = (avatarSize * 0.52).clamp(40.0, 58.0);

    Widget avatarChild;
    if (_selectedAvatarPath != null && _selectedAvatarPath!.isNotEmpty) {
      if (_selectedAvatarPath!.startsWith('http') ||
          _selectedAvatarPath!.startsWith('blob:')) {
        avatarChild = Image.network(_selectedAvatarPath!, fit: BoxFit.cover);
      } else if (_selectedAvatarPath!.startsWith('assets')) {
        avatarChild = Image.asset(_selectedAvatarPath!, fit: BoxFit.cover);
      } else if (!kIsWeb) {
        avatarChild = Image.file(File(_selectedAvatarPath!), fit: BoxFit.cover);
      } else {
        avatarChild = Icon(Icons.person, size: iconPerson, color: Colors.white);
      }
    } else if (AppState().currentUser.imagePath.trim().isNotEmpty) {
      avatarChild = Image(
        image: getUserAvatarProvider(AppState().currentUser.imagePath),
        fit: BoxFit.cover,
      );
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
    required IconData prefixIcon,
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
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
