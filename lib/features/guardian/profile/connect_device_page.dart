import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/profile/syncing_page.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';

class ConnectDevicePage extends StatefulWidget {
  final int? targetProfileIndex;
  final String? name;
  final String? relationship;
  final String? birthYear;
  final List<String>? emergencyContacts;
  final String? bloodType;
  final String? avatarUrl;
  final String? allergies;
  final String? condition;

  const ConnectDevicePage({
    super.key,
    this.targetProfileIndex,
    this.name,
    this.relationship,
    this.birthYear,
    this.emergencyContacts,
    this.bloodType,
    this.avatarUrl,
    this.allergies,
    this.condition,
  });

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  String? _selectedDeviceType;
  final TextEditingController _codeController = TextEditingController();

  final List<String> _deviceTypes = [
    'Qlink Smart Bracelet "Nova"',
    'Qlink Smart Bracelet "Pulse"',
    'Qlink Band "Non Digital"',
    'Link Smart Watch',
  ];

  @override
  void dispose() {
    _codeController.dispose();
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
                  _buildInfoCard(),
                  const SizedBox(height: 28),
                  _buildDeviceTypeDropdown(),
                  const SizedBox(height: 24),
                  _buildCodeField(),
                  const SizedBox(height: 36),
                  _buildConnectButton(),
                  const SizedBox(height: 14),
                  _buildSkipButton(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
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
      AppState().tr('Connect Device', 'توصيل جهاز'),
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
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLabel() {
    return Text(
      AppState().tr('Step 3 of 3: Hardware Link', 'الخطوة 3 من 3: ربط الأجهزة'),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB4E6C9).withValues(alpha:0.6),
          width: 1.5,
        ),
      ),
      child: Text(
        AppState().tr(
          'Find the activation card inside your Qlink bracelet box. Enter the credentials to link this hardware to the patient profile.',
          'ابحث عن بطاقة التفعيل داخل صندوق سوار كيولينك الخاص بك. أدخل البيانات لربط هذا الجهاز بملف المريض.'
        ),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDeviceTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Device Type', 'نوع الجهاز'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDeviceType,
              hint: Text(
                AppState().tr('Choose Device Type', 'اختر نوع الجهاز'),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: _deviceTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDeviceType = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Enter Code (Inside the bracelet box)', 'أدخل الرمز (يوجد داخل صندوق السوار)'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _codeController,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            hintText: 'QLINK-PULSE-8A3F2E',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_selectedDeviceType == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppState().tr('Please select a device type', 'الرجاء اختيار نوع الجهاز'))),
            );
            return;
          }
          if (_codeController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppState().tr('Please enter the bracelet code', 'الرجاء إدخال رمز السوار'))),
            );
            return;
          }

          final device = DeviceData(
            deviceType: _selectedDeviceType!,
            code: _codeController.text,
            connectedAt: DateTime.now(),
          );

          if (widget.targetProfileIndex != null) {
            AppState().addDeviceToProfile(widget.targetProfileIndex!, device);
          } else {
            final newProfile = PatientProfile(
              id: UniqueKey().toString(), // Dummy ID, Supabase will generate a real one if configured, or use UUID
              guardianId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', // Your guardian ID from the SQL
              profileName: widget.name ?? 'New Profile',
              relationshipToGuardian: widget.relationship ?? 'Member',
              birthYear: int.tryParse(widget.birthYear ?? '2000') ?? 2000,
              age: DateTime.now().year - (int.tryParse(widget.birthYear ?? '2000') ?? 2000),
              emergencyContacts: {
                'primary': {
                  'name': 'Primary Contact',
                  'phone': (widget.emergencyContacts != null && widget.emergencyContacts!.isNotEmpty) ? widget.emergencyContacts![0] : '',
                  'relation': 'Guardian'
                }
              },
              bloodType: widget.bloodType ?? '',
              safetyNotesEn: '',
              allergiesEn: widget.allergies ?? '',
              medicalNotesEn: widget.condition ?? '',
              medicalNotesAr: '',
              status: true,
              avatarUrl: widget.avatarUrl ?? 'assets/images/mypic.png',
              seoSlug: (widget.name ?? 'new-profile').toLowerCase().replaceAll(' ', '-'),
              metaTitleEn: '',
              metaDescriptionEn: '',
              featuredImageAltEn: '',
              safetyNotesAr: '',
              allergiesAr: '',
              metaTitleAr: '',
              metaDescriptionAr: '',
              featuredImageAltAr: '',
              createdAt: DateTime.now(),
            );

            SupabaseService().createPatientProfile(newProfile);
            
            // Also keep local fallback if needed
            AppState().addProfile(ProfileData(
              name: widget.name ?? 'New Profile',
              imagePath: 'assets/images/mypic.png',
              relationship: widget.relationship ?? 'Member',
              birthYear: widget.birthYear ?? '',
              emergencyContacts: widget.emergencyContacts ?? [],
              bloodType: widget.bloodType ?? '',
              allergies: widget.allergies ?? '',
              condition: widget.condition ?? '',
            ));
            AppState().addDeviceToProfile(AppState().profileCount - 1, device);
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SyncingPage(
                title: AppState().tr('Syncing to Hardware', 'تتم المزامنة مع الجهاز'),
                subtitle: AppState().tr('Encrypting data into bracelet\'s hardware ID', 'تشفير البيانات في معرف جهاز السوار'),
                onComplete: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(27),
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066CC).withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppState().tr('Connect the Bracelet', 'توصيل السوار'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: () {
        // Add profile before skipping hardware link if needed
        if (widget.targetProfileIndex == null) {
          final newProfile = PatientProfile(
            id: UniqueKey().toString(),
            guardianId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
            profileName: widget.name ?? 'New Profile',
            relationshipToGuardian: widget.relationship ?? 'Member',
            birthYear: int.tryParse(widget.birthYear ?? '2000') ?? 2000,
            age: DateTime.now().year - (int.tryParse(widget.birthYear ?? '2000') ?? 2000),
            emergencyContacts: {
              'primary': {
                'name': 'Primary Contact',
                'phone': (widget.emergencyContacts != null && widget.emergencyContacts!.isNotEmpty) ? widget.emergencyContacts![0] : '',
                'relation': 'Guardian'
              }
            },
            bloodType: widget.bloodType ?? '',
            safetyNotesEn: '',
            allergiesEn: widget.allergies ?? '',
            medicalNotesEn: widget.condition ?? '',
            medicalNotesAr: '',
            status: false,
            avatarUrl: widget.avatarUrl ?? 'assets/images/mypic.png',
            seoSlug: (widget.name ?? 'new-profile').toLowerCase().replaceAll(' ', '-'),
            metaTitleEn: '',
            metaDescriptionEn: '',
            featuredImageAltEn: '',
            safetyNotesAr: '',
            allergiesAr: '',
            metaTitleAr: '',
            metaDescriptionAr: '',
            featuredImageAltAr: '',
            createdAt: DateTime.now(),
          );

          SupabaseService().createPatientProfile(newProfile);

          AppState().addProfile(ProfileData(
            name: widget.name ?? 'New Profile',
            relationship: widget.relationship ?? 'Member',
            imagePath: 'assets/images/mypic.png',
            birthYear: widget.birthYear ?? '',
            emergencyContacts: widget.emergencyContacts ?? [],
            bloodType: widget.bloodType ?? '',
            allergies: widget.allergies ?? '',
            condition: widget.condition ?? '',
          ));
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SyncingPage(
              title: AppState().tr('Finalizing Profile', 'تجهيز الملف النهائي'),
              subtitle: AppState().tr('Saving medical information and creating QR ID', 'حفظ المعلومات الطبية وإنشاء رمز الاستجابة السريعة (QR)'),
              onComplete: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(
            color: const Color(0xFFEF4444),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppState().tr('Skip this step for now', 'تخطي هذه الخطوة الآن'),
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha:0.15),
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
                color: Colors.white.withValues(alpha:0.4),
                border: Border.all(
                  color: Colors.white.withValues(alpha:0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(35),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: LucideIcons.home,
                    label: AppState().tr('Home', 'الرئيسية'),
                  ),
                  _buildNavItem(
                    icon: LucideIcons.map,
                    label: AppState().tr('Map', 'الخريطة'),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B64F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: LucideIcons.lock,
                    label: AppState().tr('Vault', 'الخزنة'),
                  ),
                  _buildNavItem(
                    icon: LucideIcons.settings,
                    label: AppState().tr('Settings', 'الإعدادات'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
  }) {
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
            Icon(
              icon,
              color: Colors.grey.shade500,
              size: 26,
            ),
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
}
