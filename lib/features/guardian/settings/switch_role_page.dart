import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/home/main_page.dart';
import 'package:q_link/features/wearer/home/presentation/pages/wearer_main_page.dart';

class SwitchRolePage extends StatefulWidget {
  const SwitchRolePage({super.key});

  @override
  State<SwitchRolePage> createState() => _SwitchRolePageState();
}

class _SwitchRolePageState extends State<SwitchRolePage> {
  late String _tempRole;

  bool _isGuardianLike(String? role) {
    final r = (role ?? '').toLowerCase();
    return r == 'guardian' || r == 'admin';
  }

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

        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.08).clamp(20.0, 36.0);
        final toggleH = (short * 0.14).clamp(46.0, 56.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF7F9FC),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.05,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.035).clamp(8.0, 16.0),
                      vertical: (short * 0.012).clamp(6.0, 10.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Expanded(
                          child: Text(
                            appState.tr('Switch Role', 'تبديل الدور'),
                            style: TextStyle(
                              fontSize: (w * 0.05).clamp(17.0, 22.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF273469),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(hPad, (short * 0.02).clamp(8.0, 16.0), hPad, bottomPad),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Role Card
                          Container(
                            padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all((short * 0.03).clamp(8.0, 14.0)),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEEF2FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.shield,
                                    color: const Color(0xFF1B64F2),
                                    size: (short * 0.06).clamp(20.0, 28.0),
                                  ),
                                ),
                                SizedBox(width: (w * 0.04).clamp(10.0, 18.0)),
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

                          SizedBox(height: (short * 0.07).clamp(24.0, 36.0)),
                          Text(
                            appState.tr('Select Active Mode', 'اختر الوضع النشط'),
                            style: TextStyle(
                              fontSize: (w * 0.045).clamp(16.0, 19.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF273469),
                            ),
                          ),
                          Text(
                            appState.tr('Choose how you want to interact with Qlink.', 'اختر كيف تريد التفاعل مع Qlink.'),
                            style: TextStyle(
                              fontSize: (w * 0.035).clamp(12.0, 15.0),
                              color: Colors.grey.shade500,
                            ),
                          ),
                          
                          SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                          // Segmented Toggle
                          Container(
                            height: toggleH,
                            padding: EdgeInsets.all((short * 0.012).clamp(3.0, 6.0)),
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

                          SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                          // Mode Cards
                          _buildModeCard(
                            role: 'Guardian',
                            title: appState.tr('Guardian Mode', 'وضع الوصي'),
                            description: appState.tr('Manage and monitor your connected profiles.', 'إدارة ومراقبة ملفاتك الشخصية المتصلة.'),
                            icon: Icons.people_outline,
                          ),
                          SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                          _buildModeCard(
                            role: 'Wearer',
                            title: appState.tr('Wearer Mode', 'وضع المرتدي'),
                            description: appState.tr('Use Qlink for your personal safety.', 'استخدم Qlink لسلامتك الشخصية.'),
                            icon: Icons.person_outline,
                          ),

                          SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                          // Info Box
                          Container(
                            padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
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
                              style: TextStyle(
                                fontSize: (w * 0.034).clamp(12.0, 14.0),
                                color: const Color(0xFF273469),
                                height: 1.5,
                              ),
                            ),
                          ),

                          SizedBox(height: (short * 0.07).clamp(24.0, 36.0)),
                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                appState.updateCurrentUser(role: _tempRole);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(appState.tr('Role switched successfully', 'تم تبديل الدور بنجاح'))),
                                );
                                
                                // Reset the indices
                                if (_isGuardianLike(_tempRole)) {
                                  appState.setGuardianIndex(0);
                                } else {
                                  appState.setWearerIndex(0);
                                }

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => _isGuardianLike(_tempRole)
                                        ? const MainPage() 
                                        : const WearerMainPage(),
                                    settings: RouteSettings(name: _isGuardianLike(_tempRole) ? 'MainPage' : 'WearerMainPage'),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: Icon(LucideIcons.repeat, size: (short * 0.045).clamp(16.0, 20.0)),
                              label: Text(
                                appState.tr('Confirm Switch', 'تأكيد التبديل'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: (w * 0.04).clamp(14.0, 17.0),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B64F2),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: (short * 0.045).clamp(14.0, 20.0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                             
                            ),
                          ),
                          SizedBox(height: (short * 0.04).clamp(12.0, 24.0)),
                        ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ],
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
