import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class WearerEditProfilePage extends StatefulWidget {
  const WearerEditProfilePage({super.key});

  @override
  State<WearerEditProfilePage> createState() => _WearerEditProfilePageState();
}

class _WearerEditProfilePageState extends State<WearerEditProfilePage> {
  // Account Controllers
  final _nameController = TextEditingController(text: 'Mariam Essam');
  final _emailController = TextEditingController(text: 'mohamedsaber@gmail.com');
  final _phoneController = TextEditingController(text: '+20 123 456 7890');
  final _passwordController = TextEditingController(text: '********');

  // Identity Controllers
  final _patientNameController = TextEditingController(text: 'Mohamed Saber');
  final _relationshipController = TextEditingController(text: 'Grandfather');
  final _birthYearController = TextEditingController(text: '1945');
  final List<TextEditingController> _emergencyContacts = [
    TextEditingController(text: '01119988299'),
    TextEditingController(text: '01223344556'),
  ];

  // Medical Controllers
  final _safetyNotesController = TextEditingController(text: 'Needs assistance while walking long distances.');
  final _allergiesController = TextEditingController(text: 'Penicillin, Peanuts');
  final _medicalNotesController = TextEditingController(text: 'Diabetic Type 2, Hypertension');
  String? _selectedBloodType = 'O+';
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _patientNameController.dispose();
    _relationshipController.dispose();
    _birthYearController.dispose();
    for (var c in _emergencyContacts) {
      c.dispose();
    }
    _safetyNotesController.dispose();
    _allergiesController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

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
              appState.tr('Edit Full Profile', 'تعديل الملف الشخصي الكامل'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            image: AssetImage('assets/images/Mohamed Saber.png'),
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
                Center(
                  child: Column(
                    children: [
                      Text(
                        appState.tr('Wearer Account', 'حساب المرتدي'),
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
                          appState.tr('Active Connection', 'اتصال نشط'),
                          style: const TextStyle(
                            color: Color(0xFF1B64F2),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- SECTION 1: ACCOUNT INFO ---
                _buildSectionHeader(appState.tr('Account Information', 'معلومات الحساب')),
                _buildFieldLabel(appState.tr('Full Name', 'الاسم الكامل')),
                _buildTextField(controller: _nameController, hint: 'Mariam Essam'),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Email Address', 'عنوان البريد الإلكتروني')),
                _buildTextField(controller: _emailController, hint: 'mohamedsaber@gmail.com'),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Phone Number', 'رقم الهاتف')),
                _buildTextField(controller: _phoneController, hint: '+20 123 456 7890'),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Password', 'كلمة المرور')),
                _buildTextField(controller: _passwordController, hint: '********', isPassword: true),
                
                const SizedBox(height: 40),

                // --- SECTION 2: IDENTITY INFO ---
                _buildSectionHeader(appState.tr('Identity Information', 'معلومات الهوية')),
                _buildFieldLabel(appState.tr('Patient\'s Full Name', 'الاسم الكامل للمريض')),
                _buildTextField(controller: _patientNameController, hint: 'Mohamed Saber'),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Relationship to You', 'صلة القرابة')),
                _buildTextField(controller: _relationshipController, hint: 'Grandfather'),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Birth Year', 'سنة الميلاد')),
                _buildTextField(controller: _birthYearController, hint: '1945'),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Emergency Contacts', 'جهات اتصال الطوارئ')),
                ..._emergencyContacts.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTextField(
                      controller: entry.value,
                      hint: 'Contact ${entry.key + 1}',
                      suffixIcon: entry.key > 0 ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => setState(() => _emergencyContacts.removeAt(entry.key)),
                      ) : null,
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _emergencyContacts.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(appState.tr('Add Contact', 'إضافة جهة اتصال')),
                ),

                const SizedBox(height: 40),

                // --- SECTION 3: MEDICAL INFO ---
                _buildSectionHeader(appState.tr('Medical Information', 'المعلومات الطبية')),
                _buildFieldLabel(appState.tr('Blood Type', 'فصيلة الدم')),
                _buildBloodTypePicker(),
                const SizedBox(height: 24),
                _buildFieldLabel(appState.tr('Allergies', 'الحساسية')),
                _buildTextField(controller: _allergiesController, hint: 'e.g., Penicillin', maxLines: 2),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Safety Notes', 'ملاحظات السلامة')),
                _buildTextField(controller: _safetyNotesController, hint: 'e.g., Needs assistance', maxLines: 3),
                const SizedBox(height: 20),
                _buildFieldLabel(appState.tr('Medical Notes', 'الملاحظات الطبية')),
                _buildTextField(controller: _medicalNotesController, hint: 'e.g., Diabetic', maxLines: 3),

                const SizedBox(height: 60),
                
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
          bottomNavigationBar: const WearerBottomNav(),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B64F2),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 40, color: const Color(0xFF1B64F2).withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF273469),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF273469),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildBloodTypePicker() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: _bloodTypes.length,
      itemBuilder: (context, index) {
        final type = _bloodTypes[index];
        final isSelected = _selectedBloodType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedBloodType = type),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF273469) : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF273469) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF273469),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
