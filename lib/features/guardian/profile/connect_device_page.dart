import 'package:flutter/material.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/profile/syncing_page.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:uuid/uuid.dart';

class ConnectDevicePage extends StatefulWidget {
  final int? targetProfileIndex;
  final String? targetProfileId;
  final String? name;
  final String? relationship;
  final String? birthYear;
  final List<String>? emergencyContacts;
  final String? bloodType;
  final String? avatarUrl;
  final String? allergies;
  final String? condition;
  final String? safetyNotes; 

  const ConnectDevicePage({
    super.key,
    this.targetProfileIndex,
    this.targetProfileId,
    this.name,
    this.relationship,
    this.birthYear,
    this.emergencyContacts,
    this.bloodType,
    this.avatarUrl,
    this.allergies,
    this.condition,
    this.safetyNotes,
  });

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  String? _selectedDeviceType;
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false; 

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

  // --- 3. HNA EL FUNCTION ELLY B-TKRYET EL PROFILE F SUPABASE ---
  Future<void> _createProfileAndNavigate({required bool withDevice}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final guardianId = SupabaseService().client.auth.currentUser?.id;

      if (guardianId != null) {
        // N-karyet ID gded
        final newProfileId = Uuid().v4();

        final newProfile = PatientProfile(
          id: newProfileId, 
          guardianId: guardianId, 
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
          safetyNotesEn: widget.safetyNotes ?? '',
          allergiesEn: widget.allergies ?? '',
          medicalNotesEn: widget.condition ?? '',
          medicalNotesAr: '',
          status: withDevice, // Lw 3ml connect yb2a true, lw skip yb2a false
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

        // N-rfa3 3la Supabase
        await SupabaseService().createPatientProfile(newProfile);

        // N-7ot local bardo 3shan t-sme3 f wa2tha
        AppState().addProfile(ProfileData(
          id: newProfileId, // N-7ot nfs el ID
          name: widget.name ?? 'New Profile',
          relationship: widget.relationship ?? 'Member',
          imagePath: widget.avatarUrl ?? 'assets/images/mypic.png',
          birthYear: widget.birthYear ?? '',
          emergencyContacts: widget.emergencyContacts ?? [],
          bloodType: widget.bloodType ?? '',
          allergies: widget.allergies ?? '',
          condition: widget.condition ?? '',
        ));

        if (withDevice) {
           final device = DeviceData(
            deviceType: _selectedDeviceType!,
            code: _codeController.text,
            connectedAt: DateTime.now(),
          );
          AppState().addDeviceToProfile(AppState().profileCount - 1, device);
        }
      }
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SyncingPage(
              title: AppState().tr(withDevice ? 'Syncing to Hardware' : 'Finalizing Profile', withDevice ? 'تتم المزامنة مع الجهاز' : 'تجهيز الملف النهائي'),
              subtitle: AppState().tr(
                withDevice ? 'Encrypting data into bracelet\'s hardware ID' : 'Saving medical information and creating QR ID', 
                withDevice ? 'تشفير البيانات في معرف جهاز السوار' : 'حفظ المعلومات الطبية وإنشاء رمز الاستجابة السريعة (QR)'
              ),
              onComplete: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          bottomNavigationBar: const BottomNavWidget(),
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
          if (_isLoading) return;

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

          // 4. B-n-nady 3la el function 3shan t-karyet w t-connect f nfs el wa2t
          if (widget.targetProfileIndex == null) {
             _createProfileAndNavigate(withDevice: true);
          } else {
             // Adding device to existing profile
             final device = DeviceData(
              deviceType: _selectedDeviceType!,
              code: _codeController.text,
              connectedAt: DateTime.now(),
            );
            
            // Add locally if profile exists in AppState
            if (widget.targetProfileIndex != null && 
                widget.targetProfileIndex! < AppState().profileCount) {
              AppState().addDeviceToProfile(widget.targetProfileIndex!, device);
            }

            // Update Supabase status to connected using the passed profileId
            final profileId = widget.targetProfileId;
            if (profileId != null && profileId.isNotEmpty) {
              SupabaseService().client.from('patient_profiles')
                .update({'status': true}).eq('id', profileId);
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
          }
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
              _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
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
        if (_isLoading) return;

        // 5. B-n-nady 3la el function bs b- false (ya3ny 3ml skip ll-bracelet)
        if (widget.targetProfileIndex == null) {
          _createProfileAndNavigate(withDevice: false);
        } else {
           Navigator.pop(context); // Lw hwa aslan kan gowa el profile w das skip, yrg3
        }
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
            _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
                : Text(
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
}