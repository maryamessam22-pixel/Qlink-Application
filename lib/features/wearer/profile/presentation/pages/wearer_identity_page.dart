import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';

class WearerIdentityPage extends StatefulWidget {
  const WearerIdentityPage({super.key});

  @override
  State<WearerIdentityPage> createState() => _WearerIdentityPageState();
}

class _WearerIdentityPageState extends State<WearerIdentityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final List<TextEditingController> _contactControllers = [];

  @override
  void initState() {
    super.initState();
    // Add two initial contact controllers (Emergency + Additional 1)
    _contactControllers.add(TextEditingController());
    _contactControllers.add(TextEditingController());
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
                  
                  // Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          appState.tr('Cancel', 'إلغاء'),
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
                    appState.tr('Generate Your Profile', 'أنشئ ملفك الشخصي'),
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
                    appState.tr('Step 1 of 3: Identity', 'الخطوة 1 من 3: الهوية'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                  const SizedBox(height: 24),

                  // Form Fields
                  _buildLabelAndTextField(
                    label: appState.tr('Patient\'s Full Name', 'الاسم الكامل للمريض'),
                    hintText: appState.tr('e.g., Mohamed Saber', 'مثال: محمد صابر'),
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabelAndTextField(
                    label: appState.tr('Relationship to You', 'صلة القرابة'),
                    hintText: appState.tr('e.g., Grandfather', 'مثال: الجد'),
                    controller: _relationshipController,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabelAndTextField(
                    label: appState.tr('Birth Year', 'سنة الميلاد'),
                    hintText: appState.tr('e.g., 1945', 'مثال: 1945'),
                    controller: _birthYearController,
                  ),
                  const SizedBox(height: 24),

                  // Emergency Contacts
                  ..._contactControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildContactField(index, appState),
                    );
                  }),

                  const SizedBox(height: 8),
                  
                  // Add More Button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _contactControllers.add(TextEditingController());
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_box, color: Color(0xFF1B64F2)),
                          const SizedBox(width: 12),
                          Text(
                            appState.tr('Add More Contact Number', 'إضافة رقم اتصال إضافي'),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Continue Button
                  GestureDetector(
                    onTap: () {
                      // Navigate to Step 2
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appState.tr('Continue to Medical Info', 'متابعة للمعلومات الطبية'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
                        ],
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

  Widget _buildLabelAndTextField({
    required String label,
    required String hintText,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF273469),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B64F2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactField(int index, AppState appState) {
    String label = index == 0 
        ? appState.tr('EMERGENCY CONTACT * (Primary Guardian Phone)', 'جهة اتصال الطوارئ * (هاتف الوصي الأساسي)')
        : appState.tr('Additional Contact $index', 'جهة اتصال إضافية $index');
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF273469),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _contactControllers[index],
                decoration: InputDecoration(
                  hintText: appState.tr('e.g., 01119988299', 'مثال: 01119988299'),
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1B64F2)),
                  ),
                ),
              ),
            ),
            if (index > 0) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _contactControllers[index].dispose();
                    _contactControllers.removeAt(index);
                  });
                },
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade400, width: 1.5),
                  ),
                  child: Icon(Icons.close, color: Colors.red.shade700, size: 24),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
