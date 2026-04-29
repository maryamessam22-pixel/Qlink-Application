import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/core/state/app_state.dart';
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
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
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
                  ? 'Invalid email format. Example: name@email.com'
                  : 'Sign up failed: ${e.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset('assets/images/qlink_logo.png', height: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'Wearer Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
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
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B64F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WearerSignInPage(),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF1B64F2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
