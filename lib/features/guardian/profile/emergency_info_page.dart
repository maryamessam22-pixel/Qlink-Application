import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/profile/locate_bracelet_page.dart';
import 'package:q_link/features/guardian/profile/emergency_qr_page.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';

// Imports bta3t Supabase wel Models
import 'package:q_link/services/supabase_service.dart'; 
import 'package:q_link/core/models/patient_profile.dart'; 

class EmergencyInfoPage extends StatefulWidget {
  final int profileIndex;
  final ProfileData profile;

  const EmergencyInfoPage({
    super.key,
    required this.profileIndex,
    required this.profile,
  });

  @override
  State<EmergencyInfoPage> createState() => _EmergencyInfoPageState();
}

class _EmergencyInfoPageState extends State<EmergencyInfoPage> {
  bool _isEditing = false;
  bool _isSaving = false; // 3shan n-zhar loading lma y-dos Save

  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _birthYearController;
  late TextEditingController _conditionController;
  late TextEditingController _allergiesController;
  late List<TextEditingController> _contactControllers;

  Widget _buildAvatar(String path, String name, double size) {
    Widget fallback = Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(color: Colors.white, fontSize: size * 0.45, fontWeight: FontWeight.bold),
    );
    if (path.isEmpty) return fallback;
    if (path.startsWith('assets')) {
      return Image.asset(path, fit: BoxFit.cover, width: size, height: size,
        errorBuilder: (_, __, ___) => fallback);
    }
    return Image.network(path, fit: BoxFit.cover, width: size, height: size,
      errorBuilder: (_, __, ___) => fallback);
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.profile.name);
    _relationshipController = TextEditingController(text: widget.profile.relationship);
    _bloodTypeController = TextEditingController(text: widget.profile.bloodType);
    _birthYearController = TextEditingController(text: widget.profile.birthYear);
    _conditionController = TextEditingController(text: widget.profile.condition);
    _allergiesController = TextEditingController(text: widget.profile.allergies);
    _contactControllers = widget.profile.emergencyContacts
        .map((c) => TextEditingController(text: c))
        .toList();
    if (_contactControllers.isEmpty) {
      _contactControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _bloodTypeController.dispose();
    _birthYearController.dispose();
    _conditionController.dispose();
    _allergiesController.dispose();
    for (var c in _contactControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- SAVE: Updates local state + pushes ALL fields to Supabase ---
  Future<void> _saveEdits() async {
    setState(() {
      _isSaving = true; 
    });

    try {
      // 1. Update local AppState
      final updatedContacts = _contactControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final updatedProfile = ProfileData(
        id: widget.profile.id, 
        name: _nameController.text.trim(),
        relationship: _relationshipController.text.trim(),
        birthYear: _birthYearController.text.trim(),
        bloodType: _bloodTypeController.text.trim(),
        allergies: _allergiesController.text.trim(),
        condition: _conditionController.text.trim(),
        emergencyContacts: updatedContacts,
        devices: widget.profile.devices,
        imagePath: widget.profile.imagePath,
      );
      updatedProfile.visibility = widget.profile.visibility;
      AppState().updateProfile(widget.profileIndex, updatedProfile);

      // 2. Push to Supabase — send ALL editable columns
      if (widget.profile.id != null && widget.profile.id!.isNotEmpty) {
        // Build the emergency_contacts JSON from the flat list
        final Map<String, dynamic> contactsJson = {};
        for (int i = 0; i < updatedContacts.length; i++) {
          final key = i == 0 ? 'primary' : 'secondary';
          contactsJson[key] = {
            'name': updatedContacts[i],
            'phone': '',
            'relation': i == 0 ? 'Guardian' : 'Contact',
          };
        }

        await SupabaseService().client.from('patient_profiles').update({
          'profile_name': updatedProfile.name,
          'relationship_to_guardian': updatedProfile.relationship,
          'birth_year': int.tryParse(updatedProfile.birthYear) ?? 0,
          'blood_type': updatedProfile.bloodType,
          'allergies_en': updatedProfile.allergies,
          'medical_notes_en': updatedProfile.condition,
          'emergency_contacts': contactsJson,
          'safety_notes_en': updatedProfile.condition,
        }).eq('id', widget.profile.id!);
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppState().tr('Profile updated successfully.', 'تم تحديث الملف الشخصي بنجاح.'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Signal parent pages to refresh from Supabase
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdits() {
    setState(() {
      _isEditing = false;
      _initControllers(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back Button & Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_isEditing) {
                                  _cancelEdits();
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    appState.tr('Back', 'رجوع'),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const LanguageToggle(),
                            const SizedBox(width: 12),
                            
                            // Edit / Save Button with Loading
                            GestureDetector(
                              onTap: () {
                                if (_isSaving) return; 
                                if (_isEditing) {
                                  _saveEdits();
                                } else {
                                  setState(() => _isEditing = true);
                                }
                              },
                              child: _isSaving 
                                ? const SizedBox(
                                    width: 16, height: 16, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B64F2))
                                  )
                                : Text(
                                    _isEditing ? appState.tr('Save', 'حفظ') : appState.tr('Edit', 'تعديل'),
                                    style: const TextStyle(
                                      color: Color(0xFF1B64F2),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                            if (_isEditing && !_isSaving) ...[
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _cancelEdits,
                                child: Text(
                                  appState.tr('Cancel', 'إلغاء'),
                                  style: TextStyle(color: Colors.red.shade600, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Profile Summary Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF273469),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: _buildAvatar(widget.profile.imagePath, widget.profile.name, 70),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_isEditing)
                                          TextField(
                                            controller: _nameController,
                                            decoration: InputDecoration(
                                              labelText: AppState().tr('Name', 'الاسم'),
                                              isDense: true,
                                            ),
                                          )
                                        else
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                widget.profile.name,
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                              ),
                                              if (widget.profile.hasDevice)
                                                Row(
                                                  children: [
                                                    const Icon(Icons.circle, color: Color(0xFF0E9F6E), size: 10),
                                                    const SizedBox(width: 4),
                                                    Text(AppState().tr('Pulse', 'بض'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        const SizedBox(height: 4),
                                        if (_isEditing)
                                          TextField(
                                            controller: _relationshipController,
                                            decoration: InputDecoration(
                                              labelText: AppState().tr('Relationship', 'صلة القرابة'),
                                              isDense: true,
                                            ),
                                          )
                                        else
                                          Text(
                                            widget.profile.relationship,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Vitals Snapshot
                        const Text(
                          'Vitals Snapshot',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVitalItem(
                                AppState().tr('BLOOD_TYPE', 'فصيلة_الدم'),
                                _bloodTypeController.text.isEmpty ? AppState().tr('N/A', 'غير متوفر') : widget.profile.bloodType,
                                controller: _bloodTypeController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildVitalItem(
                                AppState().tr('BIRTH_YEAR', 'سنة_الميلاد'),
                                _birthYearController.text.isEmpty ? AppState().tr('N/A', 'غير متوفر') : widget.profile.birthYear,
                                controller: _birthYearController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFullWidthCard(
                          AppState().tr('Allergies', 'الحساسية'),
                          widget.profile.allergies.isEmpty ? AppState().tr('No allergies provided', 'لم يتم تقديم بيانات حساسية') : widget.profile.allergies,
                          controller: _allergiesController,
                        ),
                        const SizedBox(height: 16),
                        _buildFullWidthCard(
                          AppState().tr('Medical Notes', 'ملاحظات طبية'),
                          widget.profile.condition.isEmpty ? AppState().tr('No notes provided', 'لا توجد ملاحظات') : widget.profile.condition,
                          controller: _conditionController,
                        ),

                        const SizedBox(height: 32),

                        // Emergency Contacts
                        _buildContactsCard(),
                        const SizedBox(height: 32),

                        // Document Access
                        Text(
                          AppState().tr('Document Access', 'الوصول إلى المستندات'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 16),
                        _buildLargeButton(
                          AppState().tr('View QR Code', 'عرض رمز QR'),
                          Icons.qr_code_scanner,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyQrPage(profile: widget.profile)));
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLargeButton(
                          AppState().tr('Enter Medical Vault', 'دخول الخزنة الطبية'),
                          LucideIcons.lock,
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }

  Widget _buildVitalItem(String label, String value, {required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const SizedBox(height: 4),
          if (_isEditing)
            TextField(
              controller: controller,
              decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder()),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            )
          else
            Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildFullWidthCard(String label, String content, {required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const SizedBox(height: 8),
          if (_isEditing)
            TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            )
          else
            Text(content, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildContactsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppState().tr('EMERGENCY_CONTACTS', 'جهات_اتصال_الطوارئ'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(height: 16),
          if (_isEditing) ...[
            ..._contactControllers.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          labelText: e.key == 0 ? AppState().tr('Primary Guardian', 'الوصي الأساسي') : '${AppState().tr('Contact', 'جهة اتصال')} ${e.key + 1}',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (e.key > 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _contactControllers[e.key].dispose();
                            _contactControllers.removeAt(e.key);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _contactControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: Text(AppState().tr('Add Contact', 'إضافة جهة اتصال')),
            ),
          ] else ...[
            if (widget.profile.emergencyContacts.isEmpty)
              Text(
                AppState().tr('No emergency contacts added', 'لم يتم إضافة جهات اتصال طوارئ'),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )
            else
              ...widget.profile.emergencyContacts.asMap().entries.map((e) {
                String contactName = e.value;
                String? avatarPath;
                if (contactName.toLowerCase().contains('mariam')) {
                  avatarPath = 'assets/images/mypic.png';
                } else if (contactName.toLowerCase().contains('saber') || contactName.toLowerCase().contains('ahmed')) {
                  avatarPath = 'assets/images/Mohamed Saber.png';
                } else if (contactName.toLowerCase().contains('mazen')) {
                  avatarPath = 'assets/images/Ahmed Mazen.png';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                        clipBehavior: Clip.antiAlias,
                        child: avatarPath != null
                            ? Image.asset(avatarPath, fit: BoxFit.cover)
                            : Icon(Icons.person, color: Colors.grey.shade400, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.key == 0 ? AppState().tr('Primary Guardian', 'الوصي الأساسي') : '${AppState().tr('Contact', 'جهة اتصال')} ${e.key + 1}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(contactName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }

  Widget _buildLargeButton(String label, IconData icon, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF273469)], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: const Color(0xFF0066CC).withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}