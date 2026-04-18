import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/features/shared/home/presentation/pages/home_page.dart';
import 'package:q_link/features/shared/profile/presentation/pages/add_medical_info.dart';
import 'package:q_link/core/state/app_state.dart';

class AddProfileIdentityPage extends StatefulWidget {
  final int? editIndex;
  final ProfileData? existingProfile;

  const AddProfileIdentityPage({
    super.key,
    this.editIndex,
    this.existingProfile,
  });

  @override
  State<AddProfileIdentityPage> createState() => _AddProfileIdentityPageState();
}

class _AddProfileIdentityPageState extends State<AddProfileIdentityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final List<TextEditingController> _contactControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _nameController.text = widget.existingProfile!.name;
      _relationshipController.text = widget.existingProfile!.relationship;
      _birthYearController.text = widget.existingProfile!.birthYear;
      for (var contact in widget.existingProfile!.emergencyContacts) {
        _contactControllers.add(TextEditingController(text: contact));
      }
    }
    // Ensure at least one contact field
    if (_contactControllers.isEmpty) {
      _contactControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _birthYearController.dispose();
    for (var controller in _contactControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const VideoLogoWidget(),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/mypic.png'),
                  ),
                  const Spacer(),
                  const Icon(Icons.language, color: Color(0xFF1E3A8A), size: 28),
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.grey.shade500, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Cancel',
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
              const Text(
                'Generate Patient Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
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
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 1 of 3: Identity',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE5E7EB), thickness: 1),
              const SizedBox(height: 24),
              
              _buildLabelAndTextField('Patient\'s Full Name', 'e.g., Mohamed Saber', controller: _nameController),
              const SizedBox(height: 16),
              
              _buildLabelAndTextField('Relationship to You', 'e.g., Grandfather', controller: _relationshipController),
              const SizedBox(height: 16),
              
              _buildLabelAndTextField('Birth Year', 'e.g., 1945', controller: _birthYearController),
              const SizedBox(height: 24),
              const Text(
                'EMERGENCY CONTACTS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 12),
              ..._contactControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildContactField(index),
                );
              }),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _contactControllers.add(TextEditingController());
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_box, color: Color(0xFF1B64F2)),
                      const SizedBox(width: 8),
                      Text(
                        'Add More Contact Number',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMedicalInfoPage(
                        name: _nameController.text,
                        relationship: _relationshipController.text,
                        birthYear: _birthYearController.text,
                        emergencyContacts: _contactControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
                        editIndex: widget.editIndex,
                        existingProfile: widget.existingProfile,
                      ),
                    ),
                  );
                },
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
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Medical Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                    _buildNavItem(icon: LucideIcons.home, label: 'Home'),
                    _buildNavItem(icon: LucideIcons.map, label: 'Map'),
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
                    _buildNavItem(icon: LucideIcons.lock, label: 'Vault'),
                    _buildNavItem(icon: LucideIcons.settings, label: 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label}) {
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
            Icon(icon, color: Colors.grey.shade500, size: 26),
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

  Widget _buildContactField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          index == 0 ? 'Primary Guardian' : 'Additional Contact $index',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _contactControllers[index],
                decoration: InputDecoration(
                  hintText: 'e.g., 01119988299',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
            ),
            if (index > 0) ...[
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade400, width: 1.5),
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade600, size: 20),
                  onPressed: () {
                    setState(() {
                      _contactControllers[index].dispose();
                      _contactControllers.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLabelAndTextField(String label, String hintText, {TextEditingController? controller, TextInputAction textInputAction = TextInputAction.next}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }
}
