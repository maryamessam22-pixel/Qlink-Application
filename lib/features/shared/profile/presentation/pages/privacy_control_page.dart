import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';

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

  @override
  void initState() {
    super.initState();
    _showBloodType = widget.profile.visibility.showBloodType;
    _showAllergies = widget.profile.visibility.showAllergies;
    _showMedicalNotes = widget.profile.visibility.showMedicalNotes;
    _showEmergencyContacts = widget.profile.visibility.showEmergencyContacts;
    _showBirthYear = widget.profile.visibility.showBirthYear;
  }

  void _saveSettings() {
    widget.profile.visibility.showBloodType = _showBloodType;
    widget.profile.visibility.showAllergies = _showAllergies;
    widget.profile.visibility.showMedicalNotes = _showMedicalNotes;
    widget.profile.visibility.showEmergencyContacts = _showEmergencyContacts;
    widget.profile.visibility.showBirthYear = _showBirthYear;
    
    AppState().updateProfile(widget.profileIndex, widget.profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              Text('Back', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'QR Code Visibility',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose what information appears when someone scans the bracelet',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    _buildVisibilityItem(
                      icon: Icons.bloodtype_outlined,
                      title: 'Blood Type',
                      subtitle: widget.profile.bloodType.isNotEmpty ? widget.profile.bloodType : 'Not set',
                      value: _showBloodType,
                      color: Colors.red,
                      onChanged: (val) => setState(() {
                        _showBloodType = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.warning_amber_rounded,
                      title: 'Allergies',
                      subtitle: widget.profile.allergies.isNotEmpty ? 'Set' : 'Not set',
                      value: _showAllergies,
                      color: Colors.orange,
                      onChanged: (val) => setState(() {
                        _showAllergies = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.favorite_outline,
                      title: 'Medical Notes',
                      subtitle: widget.profile.condition.isNotEmpty ? 'Set' : 'Not set',
                      value: _showMedicalNotes,
                      color: Colors.red,
                      onChanged: (val) => setState(() {
                        _showMedicalNotes = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.call_outlined,
                      title: 'Emergency Contacts',
                      subtitle: '${widget.profile.emergencyContacts.length} contacts',
                      value: _showEmergencyContacts,
                      color: Colors.green,
                      onChanged: (val) => setState(() {
                        _showEmergencyContacts = val;
                        _saveSettings();
                      }),
                    ),
                    _buildVisibilityItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'Birth Year',
                      subtitle: widget.profile.birthYear.isNotEmpty ? widget.profile.birthYear : 'Not set',
                      value: _showBirthYear,
                      color: Colors.blue,
                      onChanged: (val) => setState(() {
                        _showBirthYear = val;
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
                      child: const Text('Preview QR View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
              color: color.withOpacity(0.1),
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
              color: Colors.blue.withOpacity(0.15),
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
                color: Colors.white.withOpacity(0.4),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                borderRadius: BorderRadius.circular(35),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(context, icon: LucideIcons.home, label: 'Home'),
                  _buildNavItem(context, icon: LucideIcons.map, label: 'Map'),
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
                  _buildNavItem(context, icon: LucideIcons.lock, label: 'Vault'),
                  _buildNavItem(context, icon: LucideIcons.settings, label: 'Settings'),
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
