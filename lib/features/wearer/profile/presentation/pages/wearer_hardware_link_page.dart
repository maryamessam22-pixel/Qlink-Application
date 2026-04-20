import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/core/models/patient_profile.dart';
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
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Row(
                    children: [
                      VideoLogoWidget(),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFE6F0FE),
                        backgroundImage: getUserAvatarProvider(appState.currentUser.imagePath),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const Spacer(),
                      const LanguageToggle(),
                      const SizedBox(width: 16),
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: Color(0xFF1E3A8A), size: 28),
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
                  ),
                  const SizedBox(height: 24),
                  
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
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    appState.tr('Connect Your Device', 'ربط جهازك'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF273469),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF273469),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF273469),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF273469),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    appState.tr('Step 3 of 3: Hardware Link', 'الخطوة 3 من 3: ربط الجهاز'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FFFA),
                      borderRadius: BorderRadius.circular(12),
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
                  
                  const SizedBox(height: 32),
                  
                  // Device Type
                  Text(
                    appState.tr('Device Type', 'نوع الجهاز'),
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
                  
                  const SizedBox(height: 24),
                  
                  // Code Field
                  Text(
                    appState.tr('Enter Code (Inside the bracelet box)', 'أدخل الرمز (داخل صندوق السوار)'),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  
                  const SizedBox(height: 48),
                  
                  // Connect Button
                  GestureDetector(
                    onTap: () async {
                      if (_isLoading) return;
                      setState(() => _isLoading = true);

                      try {
                        final profileId = const Uuid().v4();
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
                              deviceType: _selectedDeviceType ?? 'Nova',
                              code: _codeController.text.trim(),
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

                        await SupabaseService().client.from('patient_profiles').insert({
                          'id': profileId,
                          'profile_name': widget.name,
                          'relationship_to_guardian': widget.relationship,
                          'birth_year': int.tryParse(widget.birthYear) ?? 0,
                          'blood_type': widget.bloodType,
                          'allergies_en': widget.allergies,
                          'medical_notes_en': widget.condition,
                          'safety_notes_en': widget.safetyNotes,
                          'emergency_contacts': contactsJson,
                          'status': true,
                          'device_code': _codeController.text.trim(),
                        });

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
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066CC), Color(0xFF273469)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              appState.tr('Connect the Bracelet', 'ربط السوار'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF273469), Color(0xFF0066CC)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          appState.tr('Skip this step for now', 'تخطي هذه الخطوة الآن'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
