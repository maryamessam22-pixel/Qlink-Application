import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';

class PrivacyControlPage extends StatefulWidget {
  final int profileIndex;
  final ProfileData profile;

  const PrivacyControlPage({
    super.key,
    required this.profileIndex,
    required this.profile,
  });

  @override
  State<PrivacyControlPage> createState() => _PrivacyControlPageState();
}

class _PrivacyControlPageState extends State<PrivacyControlPage> {
  late bool _showBloodType;
  late bool _showAllergies;
  late bool _showMedicalNotes;
  late bool _showEmergencyContacts;
  late bool _showBirthYear;
  late bool _showRelationship;

  @override
  void initState() {
    super.initState();
    _showBloodType = widget.profile.visibility.showBloodType;
    _showAllergies = widget.profile.visibility.showAllergies;
    _showMedicalNotes = widget.profile.visibility.showMedicalNotes;
    _showEmergencyContacts = widget.profile.visibility.showEmergencyContacts;
    _showBirthYear = widget.profile.visibility.showBirthYear;
    _showRelationship = widget.profile.visibility.showRelationship;
  }

  void _saveSettings() {
    widget.profile.visibility.showBloodType = _showBloodType;
    widget.profile.visibility.showAllergies = _showAllergies;
    widget.profile.visibility.showMedicalNotes = _showMedicalNotes;
    widget.profile.visibility.showEmergencyContacts = _showEmergencyContacts;
    widget.profile.visibility.showBirthYear = _showBirthYear;
    widget.profile.visibility.showRelationship = _showRelationship;
    
    AppState().updateProfile(widget.profileIndex, widget.profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppState().tr('Privacy settings updated', 'تم تحديث إعدادات الخصوصية'))),
    );
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
                        // Back
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
                                  const SizedBox(width: 4),
                                  Text(appState.tr('Back', 'رجوع'), style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const LanguageToggle(),
                          ],
                        ),
                    const SizedBox(height: 32),

                      Text(
                        AppState().tr('QR Code Visibility', 'رؤية رمز QR'),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppState().tr('Choose what information appears when someone scans the bracelet', 'اختر المعلومات التي تظهر عندما يقوم شخص ما بمسح السوار'),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    _buildVisibilityItem(
                      icon: Icons.bloodtype_outlined,
                      title: AppState().tr('Blood Type', 'فصيلة الدم'),
                      subtitle: widget.profile.bloodType.isNotEmpty ? widget.profile.bloodType : AppState().tr('Not set', 'غير محدد'),
                      value: _showBloodType,
                      color: Colors.red,
                      onChanged: (val) => setState(() {
                        _showBloodType = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.warning_amber_rounded,
                      title: AppState().tr('Allergies', 'الحساسية'),
                      subtitle: widget.profile.allergies.isNotEmpty ? AppState().tr('Set', 'محدد') : AppState().tr('Not set', 'غير محدد'),
                      value: _showAllergies,
                      color: Colors.orange,
                      onChanged: (val) => setState(() {
                        _showAllergies = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.favorite_outline,
                      title: AppState().tr('Medical Notes', 'ملاحظات طبية'),
                      subtitle: widget.profile.condition.isNotEmpty ? AppState().tr('Set', 'محدد') : AppState().tr('Not set', 'غير محدد'),
                      value: _showMedicalNotes,
                      color: Colors.red,
                      onChanged: (val) => setState(() {
                        _showMedicalNotes = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.call_outlined,
                      title: AppState().tr('Emergency Contacts', 'جهات اتصال الطوارئ'),
                      subtitle: '${widget.profile.emergencyContacts.length} ${AppState().tr('contacts', 'جهات اتصال')}',
                      value: _showEmergencyContacts,
                      color: Colors.green,
                      onChanged: (val) => setState(() {
                        _showEmergencyContacts = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.calendar_today_outlined,
                      title: AppState().tr('Birth Year', 'سنة الميلاد'),
                      subtitle: widget.profile.birthYear.isNotEmpty ? widget.profile.birthYear : AppState().tr('Not set', 'غير محدد'),
                      value: _showBirthYear,
                      color: Colors.blue,
                      onChanged: (val) => setState(() {
                        _showBirthYear = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.family_restroom_outlined,
                      title: AppState().tr('Relationship', 'صلة القرابة'),
                      subtitle: widget.profile.relationship.isNotEmpty ? widget.profile.relationship : AppState().tr('Not set', 'غير محدد'),
                      value: _showRelationship,
                      color: Colors.purple,
                      onChanged: (val) => setState(() {
                        _showRelationship = val;
                        _saveSettings();
                      }),
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF273469),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppState().tr('Preview QR View', 'معاينة رمز QR'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildVisibilityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF3F83F8),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
                border: Border.all(color: Colors.white.withValues(alpha:0.5), width: 1.5),
                borderRadius: BorderRadius.circular(35),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(context, icon: LucideIcons.home, label: AppState().tr('Home', 'الرئيسية')),
                  _buildNavItem(context, icon: LucideIcons.map, label: AppState().tr('Map', 'الخريطة')),
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
                  _buildNavItem(context, icon: LucideIcons.lock, label: AppState().tr('Vault', 'الخزنة')),
                  _buildNavItem(context, icon: LucideIcons.settings, label: AppState().tr('Settings', 'الإعدادات')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
