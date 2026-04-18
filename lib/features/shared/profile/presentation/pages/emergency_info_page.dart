import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/shared/profile/presentation/pages/add_profile_identity.dart';

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

  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _birthYearController;
  late TextEditingController _conditionController;
  late TextEditingController _allergiesController;
  late List<TextEditingController> _contactControllers;

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
    _contactControllers = widget.profile.emergencyContacts.map((c) => TextEditingController(text: c)).toList();
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

  void _saveEdits() {
    final updatedProfile = ProfileData(
      name: _nameController.text,
      relationship: _relationshipController.text,
      birthYear: _birthYearController.text,
      bloodType: _bloodTypeController.text,
      allergies: _allergiesController.text,
      condition: _conditionController.text,
      emergencyContacts: _contactControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      devices: widget.profile.devices,
      imagePath: widget.profile.imagePath,
    );
    updatedProfile.visibility = widget.profile.visibility; // Preserve privacy settings

    AppState().updateProfile(widget.profileIndex, updatedProfile);
    
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
  }

  void _cancelEdits() {
    setState(() {
      _isEditing = false;
      _initControllers(); // Reset to original values
    });
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
                              Text('Back', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                            ],
                          ),
                        ),
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
                            color: Colors.black.withOpacity(0.04),
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
                                child: widget.profile.imagePath.contains('mypic') 
                                  ? Text(
                                      widget.profile.name.isNotEmpty ? widget.profile.name[0].toUpperCase() : '?', 
                                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(widget.profile.imagePath, fit: BoxFit.cover, width: 70, height: 70),
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
                                        decoration: const InputDecoration(labelText: 'Name', isDense: true),
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
                                                const Text('Pulse', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    const SizedBox(height: 4),
                                    if (_isEditing)
                                      TextField(
                                        controller: _relationshipController,
                                        decoration: const InputDecoration(labelText: 'Relationship', isDense: true),
                                      )
                                    else
                                      Text(widget.profile.relationship, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (_isEditing) ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _cancelEdits,
                                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                    label: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _saveEdits,
                                    icon: const Icon(Icons.check, size: 16, color: Colors.green),
                                    label: const Text('Save Edits', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    },
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                                    label: const Text('Edit Profile', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      AppState().removeProfile(widget.profileIndex);
                                      Navigator.popUntil(context, (r) => r.isFirst);
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                    label: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Vitals Snapshot
                    const Text('Vitals Snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildVitalItem('BLOOD_TYPE', _bloodTypeController.text.isEmpty ? 'N/A' : widget.profile.bloodType, controller: _bloodTypeController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildVitalItem('BIRTH_YEAR', _birthYearController.text.isEmpty ? 'N/A' : widget.profile.birthYear, controller: _birthYearController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFullWidthCard('Allergies', widget.profile.allergies.isEmpty ? 'No allergies provided' : widget.profile.allergies, controller: _allergiesController),
                    const SizedBox(height: 16),
                    _buildFullWidthCard('Medical Notes', widget.profile.condition.isEmpty ? 'No notes provided' : widget.profile.condition, controller: _conditionController),

                    const SizedBox(height: 32),

                    // Connected Bracelet Section
                    if (widget.profile.hasDevice) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Connected Bracelet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B64F2))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDEF7EC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.battery_full, size: 12, color: Color(0xFF0E9F6E)),
                                      SizedBox(width: 4),
                                      Text('62%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0E9F6E))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('LAST_LOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      Text('Home - Just now', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Mock Map
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F0FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1B64F2).withOpacity(0.3)),
                              ),
                              child: const Center(
                                child: Icon(Icons.person_pin_circle, color: Color(0xFF1B64F2), size: 40),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF273469),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Locate Bracelet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Emergency Contacts
                    _buildContactsCard(),
                    const SizedBox(height: 32),

                    // Document Access
                    const Text('Document Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 16),
                    _buildLargeButton('View QR Code', const Color(0xFF273469), Icons.qr_code_scanner),
                    const SizedBox(height: 12),
                    _buildLargeButton('Enter Medical Vault', const Color(0xFF1B64F2), LucideIcons.lock),
                    
                    const SizedBox(height: 100),
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
          const Text('EMERGENCY_CONTACTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
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
                          labelText: e.key == 0 ? 'Primary Guardian' : 'Contact ${e.key + 1}',
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
              label: const Text('Add Contact'),
            ),
          ] else ...[
            if (widget.profile.emergencyContacts.isEmpty)
              const Text('No emergency contacts added', style: TextStyle(color: Colors.grey, fontSize: 13))
            else
              ...widget.profile.emergencyContacts.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key == 0 ? 'Primary Guardian' : 'Contact ${e.key + 1}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(e.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }

  Widget _buildLargeButton(String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
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
