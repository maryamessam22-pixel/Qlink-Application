import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:q_link/features/guardian/profile/connect_device_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart';

class AddMedicalInfoPage extends StatefulWidget {
  final String name;
  final String relationship;
  final String birthYear;
  final List<String> emergencyContacts;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final int? editIndex;
  final ProfileData? existingProfile;

  const AddMedicalInfoPage({
    super.key,
    required this.name,
    required this.relationship,
    this.birthYear = '',
    this.emergencyContacts = const [],
    this.avatarUrl,
    this.avatarBytes,
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
  bool _isLoading = false; // Zwedna loading state

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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final vPad = (short * 0.028).clamp(12.0, 20.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);
        final gapL = (short * 0.055).clamp(18.0, 28.0);
        final gapM = (short * 0.045).clamp(14.0, 22.0);
        final gapS = (short * 0.02).clamp(6.0, 10.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          extendBody: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bottomPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - mq.padding.vertical),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAppBar(),
                        SizedBox(height: gapL),
                        _buildBackButton(),
                        SizedBox(height: gapM),
                        _buildTitle(),
                        SizedBox(height: gapS + 8),
                        _buildProgressBar(),
                        SizedBox(height: gapS),
                        _buildStepLabel(),
                        SizedBox(height: gapL),
                        const Divider(
                          color: Color(0xFFE5E7EB),
                          thickness: 1,
                        ),
                        SizedBox(height: gapL),
                        _buildSafetyNotesField(),
                        SizedBox(height: gapL),
                        _buildAllergiesField(),
                        SizedBox(height: gapL),
                        _buildBloodTypeSelector(),
                        SizedBox(height: gapL),
                        _buildMedicalNotesField(),
                        SizedBox(height: (short * 0.07).clamp(24.0, 36.0)),
                        _buildContinueButton(),
                        SizedBox(height: (short * 0.03).clamp(8.0, 16.0)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return const HeaderWidget();
  }

  Widget _buildBackButton() {
    final w = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.grey.shade500,
            size: (MediaQuery.sizeOf(context).shortestSide * 0.052).clamp(18.0, 22.0),
          ),
          SizedBox(width: (w * 0.012).clamp(3.0, 6.0)),
          Text(
            AppState().tr('Back', 'رجوع'),
            style: TextStyle(
              fontSize: (w * 0.04).clamp(14.0, 17.0),
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    final w = MediaQuery.sizeOf(context).width;
    return Text(
      AppState().tr('Generate Patient Profile', 'إنشاء ملف المريض'),
      style: TextStyle(
        fontSize: (w * 0.055).clamp(18.0, 24.0),
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E3A8A),
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
    final w = MediaQuery.sizeOf(context).width;
    return Text(
      AppState().tr('Step 2 of 3: Medical', 'الخطوة 2 من 3: الطبية'),
      style: TextStyle(
        fontSize: (w * 0.04).clamp(14.0, 17.0),
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
    final short = MediaQuery.sizeOf(context).shortestSide;
    final w = MediaQuery.sizeOf(context).width;
    final chipW = (short * 0.19).clamp(56.0, 76.0);
    final chipH = (short * 0.11).clamp(40.0, 50.0);
    final chipFs = (w * 0.036).clamp(12.0, 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Blood Type', 'فصيلة الدم'),
          style: TextStyle(
            fontSize: (w * 0.036).clamp(12.0, 15.0),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
        Wrap(
          spacing: (w * 0.025).clamp(6.0, 12.0),
          runSpacing: (w * 0.025).clamp(6.0, 12.0),
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
                width: chipW,
                height: chipH,
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
                    fontSize: chipFs,
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
        if (_isLoading) return;

        setState(() {
          _isLoading = true;
        });

        try {
          if (widget.editIndex != null) {
            String resolvedAvatarUrl =
                widget.avatarUrl ?? widget.existingProfile?.imagePath ?? '';
            final existingId = widget.existingProfile?.id;
            if (existingId != null &&
                existingId.isNotEmpty &&
                widget.avatarBytes != null &&
                widget.avatarBytes!.isNotEmpty) {
              final uploadedUrl = await SupabaseService()
                  .uploadProfileAvatarBytes(widget.avatarBytes!, existingId);
              if (uploadedUrl != null) {
                resolvedAvatarUrl = uploadedUrl;
              }
            }

            final updatedProfile = ProfileData(
              id: widget.existingProfile?.id,
              name: widget.name,
              relationship: widget.relationship,
              birthYear: widget.birthYear,
              emergencyContacts: widget.emergencyContacts,
              bloodType: _selectedBloodType ?? '',
              allergies: _allergiesController.text.trim(),
              condition: _medicalNotesController.text.trim(),
              devices: widget.existingProfile?.devices,
              imagePath: resolvedAvatarUrl,
              visibility: widget.existingProfile?.visibility,
            );

            // Update Supabase if ID exists
            if (updatedProfile.id != null && updatedProfile.id!.isNotEmpty) {
              await SupabaseService().client.from('patient_profiles').update({
                'profile_name': updatedProfile.name,
                'relationship_to_guardian': updatedProfile.relationship,
                'birth_year': int.tryParse(updatedProfile.birthYear) ?? 0,
                'blood_type': updatedProfile.bloodType,
                'allergies_en': updatedProfile.allergies,
                'medical_notes_en': updatedProfile.condition,
                'safety_notes_en': _safetyNotesController.text.trim(),
                'avatar_url': resolvedAvatarUrl,
              }).eq('id', updatedProfile.id!);
            }

            AppState().updateProfile(widget.editIndex!, updatedProfile);
            
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
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
                  avatarUrl: widget.avatarUrl,
                  avatarBytes: widget.avatarBytes,
                  allergies: _allergiesController.text.trim(),
                  condition: _medicalNotesController.text.trim(),
                  safetyNotes: _safetyNotesController.text.trim(),
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving info: $e'), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final short = MediaQuery.sizeOf(context).shortestSide;
          final w = MediaQuery.sizeOf(context).width;
          final btnH = (short * 0.135).clamp(48.0, 58.0);
          return Container(
            width: double.infinity,
            height: btnH,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066CC), Color(0xFF273469)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(btnH * 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: (short * 0.055).clamp(18.0, 24.0),
                    height: (short * 0.055).clamp(18.0, 24.0),
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                else ...[
                  Flexible(
                    child: Text(
                      AppState().tr('Continue to Hardware Link', 'متابعة لربط الأجهزة'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (w * 0.04).clamp(14.0, 17.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
                  Icon(Icons.arrow_forward, color: Colors.white, size: (short * 0.05).clamp(18.0, 22.0)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}