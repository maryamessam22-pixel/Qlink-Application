import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:uuid/uuid.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;

class WearerHardwareLinkPage extends StatefulWidget {
  final String name;
  final String relationship;
  final String birthYear;
  final List<String> emergencyContacts;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final String bloodType;
  final String allergies;
  final String condition;
  final String safetyNotes;

  const WearerHardwareLinkPage({
    super.key,
    required this.name,
    required this.relationship,
    this.birthYear = '',
    this.emergencyContacts = const [],
    this.avatarUrl,
    this.avatarBytes,
    this.bloodType = '',
    this.allergies = '',
    this.condition = '',
    this.safetyNotes = '',
  });

  @override
  State<WearerHardwareLinkPage> createState() => _WearerHardwareLinkPageState();
}

class _WearerHardwareLinkPageState extends State<WearerHardwareLinkPage> {
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

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.06).clamp(16.0, 28.0);
        final vPad = (short * 0.03).clamp(12.0, 20.0);
        final bottomPad = mq.viewInsets.bottom + mq.padding.bottom + (short * 0.08).clamp(24.0, 40.0);
        final gapS = (short * 0.04).clamp(12.0, 18.0);
        final gapM = (short * 0.06).clamp(18.0, 26.0);
        final gapL = (short * 0.08).clamp(24.0, 34.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bottomPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                   Row(
                    children: [
                      VideoLogoWidget(),
                      SizedBox(width: (short * 0.022).clamp(6.0, 12.0)),
                      CircleAvatar(
                        radius: (short * 0.042).clamp(14.0, 18.0),
                        backgroundColor: const Color(0xFFE6F0FE),
                        backgroundImage: getUserAvatarProvider(appState.currentUser.imagePath),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const Spacer(),
                      const LanguageToggle(),
                      SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: const Color(0xFF1E3A8A),
                            size: (short * 0.072).clamp(24.0, 30.0),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: (short * 0.028).clamp(8.0, 12.0),
                              height: (short * 0.028).clamp(8.0, 12.0),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: gapM),
                  
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          appState.tr('Back', 'رجوع'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: gapS),
                  
                  // Title
                  Text(
                    appState.tr('Connect Your Device', 'ربط جهازك'),
                    style: TextStyle(
                      fontSize: (short * 0.065).clamp(20.0, 26.0),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF273469),
                    ),
                  ),

                  SizedBox(height: gapS),
                  
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: (short * 0.012).clamp(3.0, 5.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273469),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(width: (short * 0.016).clamp(4.0, 8.0)),
                      Expanded(
                        child: Container(
                          height: (short * 0.012).clamp(3.0, 5.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273469),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(width: (short * 0.016).clamp(4.0, 8.0)),
                      Expanded(
                        child: Container(
                          height: (short * 0.012).clamp(3.0, 5.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273469),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: (short * 0.02).clamp(6.0, 10.0)),
                  
                  Text(
                    appState.tr('Step 3 of 3: Hardware Link', 'الخطوة 3 من 3: ربط الجهاز'),
                    style: TextStyle(
                      fontSize: (short * 0.036).clamp(13.0, 15.0),
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: gapM),
                  
                  // Info Box
                  Container(
                    padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FFFA),
                      borderRadius: BorderRadius.circular((w * 0.03).clamp(10.0, 14.0)),
                      border: Border.all(color: const Color(0xFF38B2AC), width: 1),
                    ),
                     child: Text(
                      appState.tr(
                        'Find the activation card inside your Qlink bracelet box. Enter the credentials to link this hardware to your profile.',
                        'ابحث عن بطاقة التنشيط داخل صندوق سوار Qlink. أدخل بيانات الاعتماد لربط هذا الجهاز بملفك الشخصي.'
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C7A7B),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: gapL),
                  
                  // Device Type
                  Text(
                    appState.tr('Device Type', 'نوع الجهاز'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: (short * 0.026).clamp(8.0, 12.0)),
                  Container(
                    constraints: BoxConstraints(minHeight: (short * 0.145).clamp(48.0, 58.0)),
                    padding: EdgeInsets.symmetric(horizontal: (short * 0.04).clamp(12.0, 18.0)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular((w * 0.03).clamp(10.0, 14.0)),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDeviceType,
                        hint: Text(
                          appState.tr('Choose Device Type', 'اختر نوع الجهاز'),
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
                              style: TextStyle(
                                fontSize: (short * 0.035).clamp(13.0, 15.0),
                                color: Color(0xFF1F2937),
                              ),
                              overflow: TextOverflow.ellipsis,
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
                  
                  SizedBox(height: gapM),
                  
                  // Code Field
                  Text(
                    appState.tr('Enter Code (Inside the bracelet box)', 'أدخل الرمز (داخل صندوق السوار)'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: (short * 0.026).clamp(8.0, 12.0)),
                  TextField(
                    controller: _codeController,
                    style: TextStyle(
                      fontSize: (short * 0.035).clamp(13.0, 15.0),
                      color: Color(0xFF1F2937),
                      letterSpacing: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'QLINK-PULSE-8A3F2E',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: (short * 0.035).clamp(13.0, 15.0),
                        letterSpacing: 1.2,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: (short * 0.04).clamp(12.0, 18.0),
                        vertical: (short * 0.04).clamp(12.0, 18.0),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular((w * 0.03).clamp(10.0, 14.0)),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular((w * 0.03).clamp(10.0, 14.0)),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E3A8A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.12).clamp(34.0, 52.0)),
                  
                  // Connect Button
                  GestureDetector(
                    onTap: () async {
                      if (_isLoading) return;
                      setState(() => _isLoading = true);

                      try {
                        final currentUserId = SupabaseService().client.auth.currentUser?.id;
                        if (currentUserId == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not logged in. Please sign in again.'), backgroundColor: Colors.red),
                            );
                            setState(() => _isLoading = false);
                          }
                          return;
                        }

                        final profileId = const Uuid().v4();
                        String deviceType = _selectedDeviceType ?? 'Qlink Smart Bracelet "Pro"';
                        String deviceCode = _codeController.text.trim();
                        String shortDeviceType = deviceType.contains('Qlink') ? 'Qlink Bracelet' : 'Smart Watch';

                        final newProfile = ProfileData(
                          id: profileId,
                          name: widget.name,
                          relationship: widget.relationship,
                          birthYear: widget.birthYear,
                          emergencyContacts: widget.emergencyContacts,
                          bloodType: widget.bloodType,
                          allergies: widget.allergies,
                          condition: widget.condition,
                          imagePath: widget.avatarUrl ?? 'assets/images/mypic.png',
                          devices: [
                            DeviceData(
                              deviceType: deviceType,
                              code: deviceCode,
                              connectedAt: DateTime.now(),
                              batteryLevel: 95,
                              signalStrength: 'Strong',
                              isConnected: true,
                            )
                          ],
                        );

                        final Map<String, dynamic> contactsJson = {};
                        for (int i = 0; i < widget.emergencyContacts.length; i++) {
                          final key = i == 0 ? 'primary' : 'secondary';
                          contactsJson[key] = {
                            'name': widget.emergencyContacts[i],
                            'phone': '',
                            'relation': i == 0 ? 'Guardian' : 'Contact',
                          };
                        }

                        // Insert into patient_profiles
                        await SupabaseService().client.from('patient_profiles').insert({
                          'id': profileId,
                          'guardian_id': currentUserId,
                          'profile_name': widget.name,
                          'relationship_to_guardian': widget.relationship,
                          'birth_year': int.tryParse(widget.birthYear) ?? 0,
                          'blood_type': widget.bloodType,
                          'allergies_en': widget.allergies,
                          'medical_notes_en': widget.condition,
                          'safety_notes_en': widget.safetyNotes,
                          'emergency_contacts': contactsJson,
                          'status': true,
                          'seo_slug': '${(widget.name).toLowerCase().replaceAll(' ', '-')}-${const Uuid().v4().substring(0, 6)}',
                        });

                        // Insert into devices table
                        await SupabaseService().client.from('devices').insert({
                          'id': const Uuid().v4(),
                          'device_name': deviceType,
                          'device_code': deviceCode,
                          'type': shortDeviceType,
                          'profile_id': profileId,
                          'guardian_id': currentUserId,
                          'linekd_profile': widget.name,
                          'status': true,
                          'battery_level': 100,
                          'action': 'connect',
                          'image': widget.avatarUrl ?? 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/default-avatar.png',
                          'created_at': DateTime.now().toIso8601String(),
                        });

                        // Insert into bracelets table
                        if (deviceType.contains('Qlink')) {
                          await SupabaseService().client.from('bracelets').insert({
                            'id': const Uuid().v4(),
                            'bracelet_id_code': deviceCode,
                            'status': 'Active',
                            'assigned_profile_id': profileId,
                            'assigned_profile': widget.name,
                            'last_sync': 'Just now',
                            'actions': 'Assign',
                            'image': widget.avatarUrl ?? 'https://vveftffbvwptlsqgeygp.supabase.co/storage/v1/object/public/qlink-assets/default-avatar.png',
                            'created_at': DateTime.now().toIso8601String(),
                          });
                        }

                        AppState().addProfile(newProfile);

                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WearerMainPage(isConnected: true),
                              settings: const RouteSettings(name: 'WearerMainPage'),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: (short * 0.15).clamp(50.0, 60.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066CC), Color(0xFF273469)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular((short * 0.075).clamp(24.0, 30.0)),
                      ),
                      child: Center(
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              appState.tr('Connect the Bracelet', 'ربط السوار'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (short * 0.04).clamp(14.0, 17.0),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: gapS),
                  
                  // Skip Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WearerMainPage(isConnected: false),
                          settings: const RouteSettings(name: 'WearerMainPage'),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: (short * 0.15).clamp(50.0, 60.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF273469), Color(0xFF0066CC)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular((short * 0.075).clamp(24.0, 30.0)),
                      ),
                      child: Center(
                        child: Text(
                          appState.tr('Skip this step for now', 'تخطي هذه الخطوة الآن'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (short * 0.04).clamp(14.0, 17.0),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}