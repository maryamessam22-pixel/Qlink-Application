import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/features/guardian/profile/connect_device_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMedicalInfoPage extends StatefulWidget {
  final String name;
  final String relationship;
  final String birthYear;
  final List<String> emergencyContacts;
  final int? editIndex;
  final ProfileData? existingProfile;

  const AddMedicalInfoPage({
    super.key,
    required this.name,
    required this.relationship,
    this.birthYear = '',
    this.emergencyContacts = const [],
    this.editIndex,
    this.existingProfile,
  });

  @override
  State<AddMedicalInfoPage> createState() => _AddMedicalInfoPageState();
}

class _AddMedicalInfoPageState extends State<AddMedicalInfoPage> {
  String? _selectedBloodType;
  final TextEditingController _safetyNotesController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _allergiesController.text = widget.existingProfile!.allergies;
      _medicalNotesController.text = widget.existingProfile!.condition;
      _selectedBloodType = widget.existingProfile!.bloodType;
    }
  }

  @override
  void dispose() {
    _safetyNotesController.dispose();
    _allergiesController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAppBar(),
                        const SizedBox(height: 24),
                        _buildBackButton(),
                        const SizedBox(height: 20),
                        _buildTitle(),
                        const SizedBox(height: 16),
                        _buildProgressBar(),
                        const SizedBox(height: 8),
                        _buildStepLabel(),
                        const SizedBox(height: 24),
                        const Divider(
                          color: Color(0xFFE5E7EB),
                          thickness: 1,
                        ),
                        const SizedBox(height: 24),
                        _buildSafetyNotesField(),
                        const SizedBox(height: 24),
                        _buildAllergiesField(),
                        const SizedBox(height: 24),
                        _buildBloodTypeSelector(),
                        const SizedBox(height: 24),
                        _buildMedicalNotesField(),
                        const SizedBox(height: 32),
                        _buildContinueButton(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(icon: LucideIcons.home, label: AppState().tr('Home', 'الرئيسية')),
                        _buildNavItem(icon: LucideIcons.map, label: AppState().tr('Map', 'الخريطة')),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B64F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 28),
                          ),
                        ),
                        _buildNavItem(icon: LucideIcons.lock, label: AppState().tr('Vault', 'الخزنة')),
                        _buildNavItem(icon: LucideIcons.settings, label: AppState().tr('Settings', 'الإعدادات')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        VideoLogoWidget(),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/mypic.png'),
        ),
        const Spacer(),
        const LanguageToggle(),
        const SizedBox(width: 16),
        Stack(
          children: [
            const Icon(
              Icons.notifications_none,
              color: Color(0xFF1E3A8A),
              size: 28,
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            AppState().tr('Back', 'رجوع'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppState().tr('Generate Patient Profile', 'إنشاء ملف المريض'),
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLabel() {
    return Text(
      AppState().tr('Step 2 of 3: Medical', 'الخطوة 2 من 3: الطبية'),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSafetyNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Safety Notes', 'ملاحظات السلامة'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _safetyNotesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppState().tr('e.g., Additional safety information', 'مثال: معلومات سلامة إضافية'),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergiesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Allergies', 'الحساسية'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _allergiesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppState().tr('e.g., Penicillin, Peanuts, Shellfish', 'مثال: البنسيلين، الفول السوداني، المحار'),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Blood Type', 'فصيلة الدم'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _bloodTypes.map((type) {
            final isSelected = _selectedBloodType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBloodType = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicalNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Medical Notes', 'ملاحظات طبية'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _medicalNotesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppState().tr('e.g., Diabetic', 'مثال: مريض سكري'),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: () async {
        if (widget.editIndex == null) {
          try {
            await Supabase.instance.client.from('patient_profiles').insert({
              'profile_name': widget.name,
              'relationship_to_guardian': widget.relationship,
              'birth_year': int.tryParse(widget.birthYear),
              'blood_type': _selectedBloodType,
              'status': false,
            });
          } catch (e) {
            print("Error saving to Supabase: $e");
          }
        } else {
          final updatedProfile = ProfileData(
            name: widget.name,
            relationship: widget.relationship,
            birthYear: widget.birthYear,
            emergencyContacts: widget.emergencyContacts,
            bloodType: _selectedBloodType ?? '',
            allergies: _allergiesController.text,
            condition: _medicalNotesController.text,
            devices: widget.existingProfile?.devices,
            imagePath: widget.existingProfile?.imagePath ?? 'assets/images/mypic.png',
            visibility: widget.existingProfile?.visibility,
          );
          AppState().updateProfile(widget.editIndex!, updatedProfile);
          Navigator.popUntil(context, (route) => route.isFirst);
          return;
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectDevicePage(
                name: widget.name,
                relationship: widget.relationship,
                birthYear: widget.birthYear,
                emergencyContacts: widget.emergencyContacts,
                bloodType: _selectedBloodType ?? '',
                allergies: _allergiesController.text,
                condition: _medicalNotesController.text,
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0066CC), Color(0xFF273469)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppState().tr('Continue', 'متابعة'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}