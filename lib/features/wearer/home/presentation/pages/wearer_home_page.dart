import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_setup_intro_page.dart';

class WearerHomePage extends StatelessWidget {
  final bool isConnected;
  const WearerHomePage({super.key, this.isConnected = false});

  void _triggerSOS(BuildContext context) {
    final appState = AppState();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 8),
            Flexible(child: Text(appState.tr('SOS Activated!', 'تم تفعيل الطوارئ!'))),
          ],
        ),
        content: Text(appState.tr(
          'Emergency alert has been sent to your guardian and emergency contacts.',
          'تم إرسال إنذار الطوارئ إلى وليك وجهات اتصال الطوارئ.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.tr('OK', 'حسناً')),
          ),
        ],
      ),
    );
  }

  void _callEmergencyContact(BuildContext context) {
    final appState = AppState();
    final profiles = appState.profiles;
    String phone = '';
    if (profiles.isNotEmpty && profiles.first.emergencyContacts.isNotEmpty) {
      phone = profiles.first.emergencyContacts.first;
    }

    if (phone.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(appState.tr('Emergency Contact', 'جهة اتصال الطوارئ')),
          content: Text(appState.tr('Calling: $phone', 'جاري الاتصال بـ: $phone')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(appState.tr('Close', 'إغلاق')),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.tr(
          'No emergency contact found. Add one in your profile.',
          'لا يوجد جهة اتصال طوارئ. أضف واحدة في ملفك الشخصي.',
        ))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
    final appState = AppState();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WearerHeader(),
          const SizedBox(height: 24),

          // Greeting
          Text(
            appState.tr('Hello, Mohamed Saber', 'مرحباً، محمد صابر'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF273469),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appState.tr('Your Safety Circle Command Center', 'مركز قيادة دائرة سلامتك'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // System Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.tr('System Status', 'حالة النظام'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.tr('You are Safe', 'أنت في أمان'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected ? const Color(0xFF4ADE80) : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected 
                          ? appState.tr('Monitoring Active', 'المراقبة نشطة')
                          : appState.tr('Offline', 'غير متصل'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Device Status Section
          if (!isConnected)
            _buildNoDeviceCard(context, appState)
          else
            _buildConnectedDevicesGrid(appState),

          const SizedBox(height: 24),

          // Emergency Buttons
          GestureDetector(
            onTap: () => _triggerSOS(context),
            onLongPress: () => _triggerSOS(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha:0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    appState.tr('SOS Emergency', 'طوارئ SOS'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.tr('Press and hold for 3 seconds', 'اضغط مع الاستمرار لمدة 3 ثوانٍ'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton.icon(
              onPressed: () => _callEmergencyContact(context),
              icon: const Icon(LucideIcons.phone, color: Colors.white),
              label: Text(
                appState.tr('Call Emergency Contact', 'اتصل بجهة اتصال الطوارئ'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appState.tr('Recent Activity', 'النشاط الأخير'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF273469),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  appState.tr('View All', 'عرض الكل'),
                  style: const TextStyle(
                    color: Color(0xFF1B64F2),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: LucideIcons.checkCircle2,
            iconColor: const Color(0xFF1B64F2),
            title: appState.tr('System Checkup', 'فحص النظام'),
            subtitle: 'Today, 09:00 AM',
            status: 'Success',
            appState: appState,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: LucideIcons.refreshCcw,
            iconColor: const Color(0xFF6B7280),
            title: appState.tr('App Sync', 'مزامنة التطبيق'),
            subtitle: 'Yesterday, 11:45 PM',
            status: 'Auto',
            appState: appState,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
      },
    );
  }

  Widget _buildNoDeviceCard(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.watch, color: Color(0xFF1B64F2), size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.tr('No Device Connected', 'لا يوجد جهاز متصل'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF273469),
                    ),
                  ),
                  Text(
                    appState.tr('Wearable Link', 'رابط الجهاز'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WearerSetupIntroPage()),
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
              child: Center(
                child: Text(
                  appState.tr('+ Add Device', '+ إضافة جهاز'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevicesGrid(AppState appState) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatusCard(
            icon: LucideIcons.watch,
            iconColor: const Color(0xFF1B64F2),
            label: appState.tr('Bracelet', 'السوار'),
            value: appState.tr('Connected', 'متصل'),
            appState: appState,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallStatusCard(
            icon: LucideIcons.battery,
            iconColor: const Color(0xFF22C55E),
            label: appState.tr('Battery', 'البطارية'),
            value: '85%',
            appState: appState,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatusCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required AppState appState,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF273469),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String status,
    required AppState appState,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF273469),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
