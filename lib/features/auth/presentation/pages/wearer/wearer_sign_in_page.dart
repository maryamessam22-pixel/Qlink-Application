import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/auth/splash/choose_role_page.dart';
import 'package:q_link/features/auth/presentation/pages/wearer/wearer_create_account_page.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WearerSignInPage extends StatefulWidget {
  const WearerSignInPage({super.key});

  @override
  State<WearerSignInPage> createState() => _WearerSignInPageState();
}

class _WearerSignInPageState extends State<WearerSignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarPath;

  @override
  void dispose() {
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

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (_selectedAvatarBytes != null && user != null) {
        final uploadedUrl = await SupabaseService()
            .uploadAndSaveUserAvatar(_selectedAvatarBytes!, user.id);
        if (uploadedUrl != null) {
          _selectedAvatarPath = uploadedUrl;
        }
      }
      final userData = user == null
          ? null
          : await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (userData != null) {
        AppState().updateCurrentUser(
          name: userData['full_name'] ?? '',
          email: userData['email'] ?? email,
          password: '',
          imagePath: userData['avatar_url'] ?? '',
          role: userData['role'] ?? 'Wearer',
        );
      } else {
        AppState().updateCurrentUser(
          name: '',
          email: email,
          password: '',
          imagePath: '',
          role: 'Wearer',
        );
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WearerMainPage(),
            settings: const RouteSettings(name: 'WearerMainPage'),
          ),
          (route) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Image.asset('assets/images/qlink_logo.png', height: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'Wearer Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF1B64F2), width: 2),
                        ),
                        child: ClipOval(child: _buildAvatarPreview()),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B64F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B64F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WearerCreateAccountPage(),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF1B64F2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    if (_selectedAvatarPath == null || _selectedAvatarPath!.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Color(0xFF1B64F2));
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
    return const Icon(Icons.person, size: 50, color: Color(0xFF1B64F2));
  }
}
