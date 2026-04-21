import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/auth/presentation/pages/sign_in_page.dart';
import 'package:q_link/features/guardian/home/main_page.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_initial_setup_page.dart';
import 'package:q_link/services/supabase_service.dart'; // LAAAAZM TA3MLY IMPORT L-EL SERVICE

class CreateAccountPage extends StatefulWidget {
  final String role;
  
  const CreateAccountPage({super.key, required this.role});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // 1. HNA DEFT EL CONTROLLERS 3SHAN N-2RA EL KLAM
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. HNA EL FUNCTION ELLY B-TRBOT B-SUPABASE
  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Lw feh 7aga fadya
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Please fill all fields', 'يرجى ملء جميع الحقول'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // B-n-klem el Service elly by-rfa3 3la table el profiles
      final success = await SupabaseService().signUpUser(
        email: email,
        password: password,
        fullName: name,
        role: widget.role,
      );

      if (success && mounted) {
        // N-7ot el data f el AppState (el memory bta3t el app)
        AppState().updateCurrentUser(
          name: name,
          email: email,
          password: '',
          imagePath: widget.role == 'Wearer' ? 'assets/images/Mohamed Saber.png' : 'assets/images/mypic.png',
          role: widget.role,
        );

        // N-wady 3la el Home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => widget.role == 'Guardian' 
                ? const MainPage() 
                : const WearerInitialSetupPage(),
            settings: RouteSettings(name: widget.role == 'Guardian' ? 'MainPage' : 'WearerInitialSetupPage'),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create account')),
          );
        }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/images/qlink_logo.png',
                    height: 70,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                
                Text(
                  appState.tr('Create Account', 'إنشاء حساب'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Century Gothic',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.tr('Starts your safety journey', 'ابدأ رحلة سلامتك'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 30),

                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: AssetImage(widget.role == 'Wearer' 
                                ? 'assets/images/Mohamed Saber.png' 
                                : 'assets/images/mypic.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF28365B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 3. HNA RABATNA EL CONTROLLERS B-EL TEXT FIELDS
                _buildTextField(
                  controller: _nameController, // Rabatna Esm
                  hintText: appState.tr('Full Name', 'الاسم الكامل')
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController, // Rabatna Email
                  hintText: appState.tr('Email Address', 'عنوان البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController, // Rabatna Password
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
                const SizedBox(height: 30),
                
                // 4. HNA RABATNA ZRAR EL CREATE B-EL FUNCTION
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp, // <--- HNA
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28365B),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
                        appState.tr('Create a ${widget.role} Hub', 'إنشاء حساب ${widget.role}'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
                const SizedBox(height: 40),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.8), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(appState.tr('OR', 'أو'), style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                    ),
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.8), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      iconWidget: Image.asset('assets/icons/fb.png', width: 48, height: 48),
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white,
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      iconWidget: Image.asset('assets/icons/google.png', width: 48, height: 48),
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white,
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      iconWidget: Image.asset('assets/icons/apple.png', width: 48, height: 48),
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appState.tr('Already have an account ? ', 'هل لديك حساب بالفعل؟ '),
                      style: const TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignInPage(role: widget.role)),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. DEFT HNA `TextEditingController? controller`
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

  Widget _buildSocialButton({
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    Color backgroundColor = Colors.transparent,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: Center(
          child: iconWidget ?? Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }
}