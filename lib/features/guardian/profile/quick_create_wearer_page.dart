import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuickCreateWearerPage extends StatefulWidget {
  const QuickCreateWearerPage({super.key});

  @override
  State<QuickCreateWearerPage> createState() => _QuickCreateWearerPageState();
}

class _QuickCreateWearerPageState extends State<QuickCreateWearerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _contactController = TextEditingController();

  String? _selectedBirthYear;
  String? _selectedBloodType;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarPath;

  final List<String> _years = List.generate(100, (index) => (DateTime.now().year - index).toString());
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _allergiesController.dispose();
    _medicalNotesController.dispose();
    _contactController.dispose();
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

  Future<void> _handleCreateAndLink() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthYear == null || _selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Please select birth year and blood type', 'الرجاء تحديد سنة الميلاد وفصيلة الدم'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final guardianId = Supabase.instance.client.auth.currentUser?.id;
      if (guardianId == null) throw Exception('Guardian not logged in');

      String avatarUrl = 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/profiles/default.png';
      
      final Map<String, dynamic> emergencyContacts = {};
      if (_contactController.text.isNotEmpty) {
        emergencyContacts['0'] = {
          'name': 'Primary Contact',
          'phone': _contactController.text.trim(),
        };
      }

      final profileRes = await Supabase.instance.client.from('patient_profiles').insert({
        'guardian_id': guardianId,
        'profile_name': _nameController.text.trim(),
        'relationship_to_guardian': 'Wearer',
        'birth_year': int.tryParse(_selectedBirthYear!) ?? 1900,
        'blood_type': _selectedBloodType,
        'allergies_en': _allergiesController.text.trim(),
        'medical_notes_en': _medicalNotesController.text.trim(),
        'emergency_contacts': emergencyContacts,
        'avatar_url': avatarUrl,
        'status': false,
      }).select().single();

      final newProfileId = profileRes['id'];

      if (_selectedAvatarBytes != null) {
        final uploadedUrl = await SupabaseService().uploadAndSaveUserAvatar(_selectedAvatarBytes!, newProfileId);
        if (uploadedUrl != null) {
          avatarUrl = uploadedUrl;
          await Supabase.instance.client.from('patient_profiles').update({'avatar_url': avatarUrl}).eq('id', newProfileId);
        }
      }

      try {
        await Supabase.instance.client.functions.invoke('create-wearer-account', body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'fullName': _nameController.text.trim(),
          'guardianId': guardianId,
          'patientProfileId': newProfileId,
        });
      } catch (e) {
        debugPrint('Could not create wearer auth account automatically: $e');
      }

      AppState().markProfilesDirty();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppState().tr('Wearer created and linked successfully!', 'تم إنشاء وربط Wearer بنجاح!'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppState().tr('Error: $e', 'خطأ: $e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAvatarPreview() {
    if (_selectedAvatarPath == null || _selectedAvatarPath!.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.white);
    }
    if (_selectedAvatarPath!.startsWith('http') || _selectedAvatarPath!.startsWith('blob:')) {
      return Image.network(_selectedAvatarPath!, fit: BoxFit.cover);
    }
    if (_selectedAvatarPath!.startsWith('assets')) {
      return Image.asset(_selectedAvatarPath!, fit: BoxFit.cover);
    }
    if (!kIsWeb) {
      return Image.file(File(_selectedAvatarPath!), fit: BoxFit.cover);
    }
    return const Icon(Icons.person, size: 50, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Image.asset('assets/images/qlink_logo.png', height: 60, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text(
                    appState.tr('Create Wearer', 'إنشاء Wearer'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.tr('Auto-link to your Guardian Hub', 'ربط تلقائي بمركز الوصي الخاص بك'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  
                  // Avatar
                  Center(
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: ClipOval(child: _buildAvatarPreview()),
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
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Account Details
                  _buildTextField(
                    controller: _nameController,
                    hint: appState.tr('Full Name', 'الاسم الكامل'),
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    hint: appState.tr('Email Address', 'البريد الإلكتروني'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hint: appState.tr('Password', 'كلمة المرور'),
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      appState.tr('Minimum 8 characters', 'الحد الأدنى 8 أحرف'),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    appState.tr('Identity & Medical Data', 'البيانات الشخصية والطبية'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  // Birth Year
                  Text(appState.tr('Birth Year', 'سنة الميلاد'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedBirthYear,
                    items: _years,
                    hint: appState.tr('Select birth year', 'اختر سنة الميلاد'),
                    icon: Icons.calendar_today_outlined,
                    onChanged: (val) => setState(() => _selectedBirthYear = val),
                  ),
                  
                  const SizedBox(height: 16),
                  // Blood Type
                  Text(appState.tr('Blood Type', 'فصيلة الدم'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedBloodType,
                    items: _bloodTypes,
                    hint: appState.tr('Select blood type', 'اختر فصيلة الدم'),
                    icon: Icons.bloodtype_outlined,
                    onChanged: (val) => setState(() => _selectedBloodType = val),
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _allergiesController,
                    hint: appState.tr('Allergies', 'الحساسية'),
                    icon: Icons.warning_amber_rounded,
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _medicalNotesController,
                    hint: appState.tr('Medical Notes', 'ملاحظات طبية'),
                    icon: Icons.medical_services_outlined,
                  ),

                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Text('🇪🇬 +20', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: appState.tr('Emergency Contact (Phone)', 'رقم طوارئ (هاتف)'),
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateAndLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28365B),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            appState.tr('Create & Link Wearer', 'إنشاء وربط Wearer'),
                            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appState.tr(
                              'The wearer will receive login credentials to access their own app view.',
                              'سيتلقى Wearer بيانات تسجيل الدخول للوصول إلى التطبيق الخاص به.'
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? AppState().tr('Required', 'مطلوب') : null,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black87)))).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
      ),
    );
  }
}
