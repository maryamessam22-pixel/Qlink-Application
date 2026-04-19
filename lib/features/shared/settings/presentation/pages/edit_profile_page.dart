import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class EditProfilePage extends StatefulWidget {
  final bool isWearer;
  const EditProfilePage({super.key, this.isWearer = true});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Mariam Essam');
  final _emailController = TextEditingController(text: 'mohamedsaber@gmail.com');
  final _phoneController = TextEditingController(text: '+20 123 456 7890');
  final _passwordController = TextEditingController(text: '********');

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              appState.tr('Edit Profile', 'تعديل الملف الشخصي'),
              style: const TextStyle(
                color: Color(0xFF273469),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade100, width: 4),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/mypic.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B64F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Role Badge
                Text(
                  appState.tr('Current Role: Wearer', 'الدور الحالي: مرتدي'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF273469),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appState.tr('Wearer Account', 'حساب المرتدي'),
                    style: const TextStyle(
                      color: Color(0xFF1B64F2),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Form Fields
                _buildFieldLabel(appState.tr('Full Name', 'الاسم الكامل')),
                _buildTextField(controller: _nameController, hint: 'Mariam Essam'),
                
                const SizedBox(height: 24),
                
                _buildFieldLabel(appState.tr('Password', 'كلمة المرور')),
                _buildTextField(controller: _passwordController, hint: '********', isPassword: true),
                
                const SizedBox(height: 24),
                
                _buildFieldLabel(appState.tr('Email Address', 'عنوان البريد الإلكتروني')),
                _buildTextField(controller: _emailController, hint: 'mohamedsaber@gmail.com'),
                
                const SizedBox(height: 24),
                
                // Enhanced Field: Phone Number
                _buildFieldLabel(appState.tr('Phone Number', 'رقم الهاتف')),
                _buildTextField(controller: _phoneController, hint: '+20 123 456 7890'),
                
                const SizedBox(height: 40),
                
                // Save Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B64F2),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B64F2).withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      appState.tr('Save Changes', 'حفظ التغييرات'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: widget.isWearer 
            ? WearerBottomNav(
                currentIndex: 3,
                onTap: (index) {
                  Navigator.pop(context); // Go back to settings
                },
              )
            : null, // Handle Guardian nav if needed later
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF273469),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: Color(0xFF273469),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
