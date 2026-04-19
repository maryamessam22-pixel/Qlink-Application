import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';

class SwitchRolePage extends StatefulWidget {
  const SwitchRolePage({super.key});

  @override
  State<SwitchRolePage> createState() => _SwitchRolePageState();
}

class _SwitchRolePageState extends State<SwitchRolePage> {
  late String _tempRole;

  @override
  void initState() {
    super.initState();
    _tempRole = AppState().currentUser.role;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final currentRole = appState.currentUser.role;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                   // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Text(
                          appState.tr('Switch Role', 'تبديل الدور'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF273469),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Role Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEEF2FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.shield, color: Color(0xFF1B64F2), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appState.tr('Current Role', 'الدور الحالي'),
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
                                      ),
                                      Text(
                                        appState.tr(currentRole, currentRole == 'Guardian' ? 'وصي' : 'مرتدي'),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B64F2)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    appState.tr('Active', 'نشط'),
                                    style: const TextStyle(color: Color(0xFF1B64F2), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                          Text(
                            appState.tr('Select Active Mode', 'اختر الوضع النشط'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
                          ),
                          Text(
                            appState.tr('Choose how you want to interact with Qlink.', 'اختر كيف تريد التفاعل مع Qlink.'),
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                          
                          const SizedBox(height: 24),
                          // Segmented Toggle
                          Container(
                            height: 50,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                _buildToggleItem('Guardian', appState.tr('Guardian', 'وصي')),
                                _buildToggleItem('Wearer', appState.tr('Wearer', 'مرتدي')),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Mode Cards
                          _buildModeCard(
                            role: 'Guardian',
                            title: appState.tr('Guardian Mode', 'وضع الوصي'),
                            description: appState.tr('Manage and monitor your connected profiles.', 'إدارة ومراقبة ملفاتك الشخصية المتصلة.'),
                            icon: Icons.people_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildModeCard(
                            role: 'Wearer',
                            title: appState.tr('Wearer Mode', 'وضع المرتدي'),
                            description: appState.tr('Use Qlink for your personal safety.', 'استخدم Qlink لسلامتك الشخصية.'),
                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 24),
                          // Info Box
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              appState.tr(
                                'You can switch roles anytime from settings. Transitioning modes will update your dashboard and notification preferences.',
                                'يمكنك تبديل الأدوار في أي وقت من الإعدادات. سيؤدي انتقال الأوضاع إلى تحديث لوحة التحكم وتفضيلات الإشعارات.'
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF273469), height: 1.5),
                            ),
                          ),

                          const SizedBox(height: 32),
                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                appState.updateCurrentUser(role: _tempRole);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(appState.tr('Role switched successfully', 'تم تبديل الدور بنجاح'))),
                                );
                                Navigator.pop(context);
                              },
                              icon: const Icon(LucideIcons.repeat, size: 18),
                              label: Text(
                                appState.tr('Confirm Switch', 'تأكيد التبديل'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B64F2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                             
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleItem(String role, String label) {
    final isSelected = _tempRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tempRole = role),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF1B64F2) : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _tempRole == role;
    return GestureDetector(
      onTap: () => setState(() => _tempRole = role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B64F2) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF1B64F2) : Colors.grey.shade400, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1B64F2), size: 24),
          ],
        ),
      ),
    );
  }
}
