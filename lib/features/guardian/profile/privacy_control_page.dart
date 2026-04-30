import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/profile/public_preview_qr_page.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';

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
    final cached = AppState().qrVisibilitySettingsFor(widget.profile.id);
    if (cached != null) {
      final v = widget.profile.visibility;
      v.showBloodType = cached.showBloodType;
      v.showAllergies = cached.showAllergies;
      v.showMedicalNotes = cached.showMedicalNotes;
      v.showEmergencyContacts = cached.showEmergencyContacts;
      v.showBirthYear = cached.showBirthYear;
      v.showRelationship = cached.showRelationship;
    }
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
    final id = widget.profile.id?.trim();
    if (id != null && id.isNotEmpty) {
      AppState().setQrVisibilitySettingsForProfile(id, widget.profile.visibility);
    } else {
      AppState().notifyQrVisibilityChanged();
    }
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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final vPad = (short * 0.028).clamp(12.0, 20.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.26).clamp(80.0, 112.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          backgroundColor: const Color(0xFFF7F9FC),
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
                        // Back
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.grey.shade600,
                                    size: (short * 0.052).clamp(18.0, 22.0),
                                  ),
                                  SizedBox(width: (w * 0.012).clamp(3.0, 6.0)),
                                  Text(
                                    appState.tr('Back', 'رجوع'),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: (w * 0.04).clamp(14.0, 17.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const LanguageToggle(),
                          ],
                        ),
                    SizedBox(height: (short * 0.07).clamp(24.0, 36.0)),

                      Text(
                        AppState().tr('QR Code Visibility', 'رؤية رمز QR'),
                      style: TextStyle(
                        fontSize: (w * 0.06).clamp(20.0, 26.0),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppState().tr('Choose what information appears when someone scans the bracelet', 'اختر المعلومات التي تظهر عندما يقوم شخص ما بمسح السوار'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: (w * 0.032).clamp(12.0, 14.0),
                        height: 1.4,
                      ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublicPreviewQrPage(
                              profile: widget.profile,
                            ),
                          ),
                        );
                      },
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
                );
              },
            ),
          ),
          bottomNavigationBar: const BottomNavWidget(),
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

}
