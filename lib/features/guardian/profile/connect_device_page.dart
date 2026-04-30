import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/features/guardian/home/main_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/profile/syncing_page.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
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
  final Uint8List? avatarBytes;
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
    this.avatarBytes,
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
    'Qlink Smart Bracelet "Pro"',
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

  Future<void> _createProfileAndNavigate({required bool withDevice}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final guardianId = SupabaseService().client.auth.currentUser?.id;

      if (guardianId != null) {
        final newProfileId = Uuid().v4();

        String avatarUrl = '';
        if (widget.avatarBytes != null && widget.avatarBytes!.isNotEmpty) {
          debugPrint('[ConnectDevice] Uploading ${widget.avatarBytes!.length} avatar bytes...');
          final uploadedUrl = await SupabaseService().uploadProfileAvatarBytes(widget.avatarBytes!, newProfileId);
          if (uploadedUrl != null) {
            avatarUrl = uploadedUrl;
            debugPrint('[ConnectDevice] Avatar uploaded: $avatarUrl');
          } else if (mounted) {
            final err = SupabaseService().lastUploadError ?? 'Unknown error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: $err'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 6),
              ),
            );
          }
        } else if (widget.avatarUrl != null && widget.avatarUrl!.startsWith('assets')) {
          avatarUrl = widget.avatarUrl!;
        } else {
          debugPrint('[ConnectDevice] No avatar bytes provided (avatarBytes is null or empty)');
        }

        String deviceType = _selectedDeviceType ?? 'Qlink Smart Bracelet "Pro"';
        String deviceCode = _codeController.text.trim();
        String shortDeviceType = deviceType.contains('Qlink') ? 'Qlink Bracelet' : 'Smart Watch';

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
          status: withDevice,
          avatarUrl: avatarUrl,
          deviceCode: withDevice ? deviceCode : '',
          seoSlug: '${(widget.name ?? 'new-profile').toLowerCase().replaceAll(' ', '-')}-${newProfileId.substring(0, 8)}',
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

        // Sync with Supabase (Patient Profile)
        await SupabaseService().createPatientProfile(newProfile);

        try {
          await SupabaseService().ensurePublicQrToken(newProfileId);
        } catch (e) {
          debugPrint('[ConnectDevice] ensurePublicQrToken: $e');
        }

        // Update Dashboard Tables (Both specialized and generic device logs)
        if (withDevice) {
           await SupabaseService().client.from('devices').insert({
              'id': const Uuid().v4(),
              'device_name': deviceType,
              'device_code': deviceCode,
              'type': shortDeviceType,
              'profile_id': newProfileId,
              'guardian_id': guardianId,
              'linekd_profile': widget.name ?? 'New Profile',
              'status': true,
              'battery_level': 100,
              'action': 'connect',
              'image': avatarUrl.isNotEmpty ? avatarUrl : 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/default-avatar.png',
              'created_at': DateTime.now().toIso8601String(),
           });

           if (deviceType.contains('Qlink')) {
              await SupabaseService().client.from('bracelets').insert({
                'id': const Uuid().v4(),
                'bracelet_id_code': deviceCode,
                'status': 'Active',
                'assigned_profile_id': newProfileId,
                'assigned_profile': widget.name ?? 'New Profile',
                'last_sync': 'Just now',
                'actions': 'Assign',
                'image': avatarUrl.isNotEmpty ? avatarUrl : 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/default-avatar.png',
                'created_at': DateTime.now().toIso8601String(),
              });
           }

           final device = DeviceData(
            deviceType: deviceType,
            code: deviceCode,
            connectedAt: DateTime.now(),
          );
          AppState().addDeviceToProfile(AppState().profileCount - 1, device);
        }

        // Synchronize local state for immediate UI feedback
        AppState().addProfile(ProfileData(
          id: newProfileId,
          name: widget.name ?? 'New Profile',
          relationship: widget.relationship ?? 'Member',
          imagePath: avatarUrl,
          birthYear: widget.birthYear ?? '',
          emergencyContacts: widget.emergencyContacts ?? [],
          bloodType: widget.bloodType ?? '',
          allergies: widget.allergies ?? '',
          condition: widget.condition ?? '',
        ));

        AppState().markProfilesDirty();
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainPage(),
                    settings: const RouteSettings(name: 'MainPage'),
                  ),
                  (route) => false,
                );
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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final vPad = (short * 0.028).clamp(12.0, 20.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.26).clamp(80.0, 112.0);
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
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - mq.padding.vertical,
                    ),
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
                        _buildInfoCard(),
                        SizedBox(height: (short * 0.06).clamp(22.0, 32.0)),
                        _buildDeviceTypeDropdown(),
                        SizedBox(height: gapL),
                        _buildCodeField(),
                        SizedBox(height: (short * 0.08).clamp(28.0, 40.0)),
                        _buildConnectButton(),
                        SizedBox(height: (short * 0.032).clamp(12.0, 18.0)),
                        _buildSkipButton(),
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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final avR = (short * 0.042).clamp(14.0, 18.0);
    final notif = (short * 0.068).clamp(24.0, 30.0);
    final dot = (short * 0.028).clamp(8.0, 11.0);

    return Row(
      children: [
        const VideoLogoWidget(),
        SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
        CircleAvatar(
          radius: avR,
          backgroundColor: const Color(0xFFE6F0FE),
          backgroundImage: getUserAvatarProvider(AppState().currentUser.imagePath),
          onBackgroundImageError: (_, __) {},
        ),
        const Spacer(),
        const LanguageToggle(),
        SizedBox(width: (w * 0.04).clamp(10.0, 18.0)),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_none,
              color: const Color(0xFF1E3A8A),
              size: notif,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: dot,
                height: dot,
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
    final w = MediaQuery.sizeOf(context).width;
    final short = MediaQuery.sizeOf(context).shortestSide;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.grey.shade500,
            size: (short * 0.052).clamp(18.0, 22.0),
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
      AppState().tr('Connect Device', 'توصيل جهاز'),
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
              color: const Color(0xFF1E3A8A),
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
      AppState().tr('Step 3 of 3: Hardware Link', 'الخطوة 3 من 3: ربط الأجهزة'),
      style: TextStyle(
        fontSize: (w * 0.04).clamp(14.0, 17.0),
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoCard() {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final pad = (short * 0.05).clamp(14.0, 22.0);
    return Container(
      padding: EdgeInsets.all(pad),
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
          fontSize: (MediaQuery.sizeOf(context).width * 0.035).clamp(12.0, 15.0),
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDeviceTypeDropdown() {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final w = MediaQuery.sizeOf(context).width;
    final h = (short * 0.135).clamp(48.0, 58.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppState().tr('Device Type', 'نوع الجهاز'),
          style: TextStyle(
            fontSize: (w * 0.036).clamp(12.0, 15.0),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: (short * 0.024).clamp(8.0, 12.0)),
        Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: (w * 0.04).clamp(12.0, 18.0)),
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
        onTap: () async {
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

          if (widget.targetProfileIndex == null) {
             _createProfileAndNavigate(withDevice: true);
          } else {
             // Logic for adding a device to an existing patient profile
             setState(() => _isLoading = true);
             try {
                String deviceType = _selectedDeviceType!;
                String deviceCode = _codeController.text.trim();
                String shortDeviceType = deviceType.contains('Qlink') ? 'Qlink Bracelet' : 'Smart Watch';

                final device = DeviceData(
                  deviceType: deviceType,
                  code: deviceCode,
                  connectedAt: DateTime.now(),
                );
                
                if (widget.targetProfileIndex != null && 
                    widget.targetProfileIndex! < AppState().profileCount) {
                  AppState().addDeviceToProfile(widget.targetProfileIndex!, device);
                }

                final profileId = widget.targetProfileId;
                if (profileId != null && profileId.isNotEmpty) {
                  final guardianId = SupabaseService().client.auth.currentUser?.id;
                  if (guardianId == null) {
                    throw Exception('Not logged in. Please sign in again.');
                  }
                  // Update the status in the central profile table
                  await SupabaseService().client.from('patient_profiles')
                    .update({'status': true}).eq('id', profileId);

                  // Update Dashboard Tables
                  String linkedName = widget.targetProfileIndex! < AppState().profileCount ? AppState().profiles[widget.targetProfileIndex!].name : 'Unknown';

                  await SupabaseService().client.from('devices').insert({
                    'id': const Uuid().v4(),
                    'device_name': deviceType,
                    'device_code': deviceCode,
                    'type': shortDeviceType,
                    'profile_id': profileId,
                    'guardian_id': guardianId,
                    'linekd_profile': linkedName,
                    'status': true,
                    'battery_level': 100,
                    'action': 'connect',
                    'image': 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/default-avatar.png',
                    'created_at': DateTime.now().toIso8601String(),
                  });

                  if (deviceType.contains('Qlink')) {
                    await SupabaseService().client.from('bracelets').insert({
                      'id': const Uuid().v4(),
                      'bracelet_id_code': deviceCode,
                      'status': 'Active',
                      'assigned_profile_id': profileId,
                      'assigned_profile': linkedName,
                      'last_sync': 'Just now',
                      'actions': 'Assign',
                      'image': 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/default-avatar.png',
                      'created_at': DateTime.now().toIso8601String(),
                    });
                  }
                }

                AppState().markProfilesDirty();

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SyncingPage(
                      title: AppState().tr('Syncing to Hardware', 'تتم المزامنة مع الجهاز'),
                      subtitle: AppState().tr('Encrypting data into bracelet\'s hardware ID', 'تشفير البيانات في معرف جهاز السوار'),
                      onComplete: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ).then((_) {
                  if (mounted) Navigator.pop(context, true);
                });
             } catch (e) {
                 if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
             } finally {
                 if (mounted) setState(() => _isLoading = false);
             }
          }
        },
        borderRadius: BorderRadius.circular(27),
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
                      ? SizedBox(
                          width: (short * 0.055).clamp(18.0, 24.0),
                          height: (short * 0.055).clamp(18.0, 24.0),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Flexible(
                          child: Text(
                            AppState().tr('Connect the Bracelet', 'توصيل السوار'),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;

        if (widget.targetProfileIndex == null) {
          _createProfileAndNavigate(withDevice: false);
        } else {
           Navigator.pop(context); 
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(btnH * 0.5),
              border: Border.all(
                color: const Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? SizedBox(
                        width: (short * 0.055).clamp(18.0, 24.0),
                        height: (short * 0.055).clamp(18.0, 24.0),
                        child: const CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2),
                      )
                    : Flexible(
                        child: Text(
                          AppState().tr('Skip this step for now', 'تخطي هذه الخطوة الآن'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFEF4444),
                            fontSize: (w * 0.04).clamp(14.0, 17.0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}