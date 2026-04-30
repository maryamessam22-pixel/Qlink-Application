import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_hardware_link_page.dart';

class WearerHomePage extends StatefulWidget {
  final bool isConnected;
  const WearerHomePage({super.key, this.isConnected = false});

  @override
  State<WearerHomePage> createState() => _WearerHomePageState();
}

class _WearerHomePageState extends State<WearerHomePage> {
  late Future<List<Map<String, dynamic>>> _monitoringFuture;

  void _refreshMonitoring() {
    if (!mounted) return;
    setState(() {
      _monitoringFuture = SupabaseService().fetchAcceptedWearerGuardians();
    });
  }

  @override
  void initState() {
    super.initState();
    _monitoringFuture = SupabaseService().fetchAcceptedWearerGuardians();
    AppState().addListener(_refreshMonitoring);
  }

  @override
  void dispose() {
    AppState().removeListener(_refreshMonitoring);
    super.dispose();
  }

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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final hPad = (w * 0.06).clamp(16.0, 28.0);
    final topPad = (short * 0.12).clamp(20.0, 54.0);
    final bottomPad = mq.padding.bottom + mq.viewInsets.bottom + (short * 0.06).clamp(18.0, 28.0);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, bottomPad),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WearerHeader(),
          SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

          // Greeting
          Text(
            appState.tr('Hello, ${appState.currentUser.name}', 'مرحباً، ${appState.currentUser.name}'),
            style: TextStyle(
              fontSize: (short * 0.065).clamp(20.0, 26.0),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF273469),
            ),
          ),
          SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
          Text(
            appState.tr('Your Safety Circle Command Center', 'مركز قيادة دائرة سلامتك'),
            style: TextStyle(
              fontSize: (short * 0.036).clamp(13.0, 15.0),
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _monitoringFuture,
            builder: (context, snapshot) {
              final guardians = snapshot.data ?? const <Map<String, dynamic>>[];
              if (guardians.isEmpty) return const SizedBox.shrink();
              final first = guardians.first;
              final guardianName = (first['guardian_name'] ?? 'Guardian').toString();
              final guardianEmail = (first['guardian_email'] ?? '').toString();
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all((short * 0.045).clamp(12.0, 18.0)),
                margin: EdgeInsets.only(bottom: (short * 0.04).clamp(12.0, 18.0)),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular((w * 0.04).clamp(12.0, 16.0)),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all((short * 0.025).clamp(8.0, 12.0)),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: const Color(0xFF1E3A8A),
                        size: (short * 0.055).clamp(18.0, 24.0),
                      ),
                    ),
                    SizedBox(width: (short * 0.03).clamp(8.0, 14.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.tr('Monitored By', 'تتم متابعتك بواسطة'),
                            style: TextStyle(
                              fontSize: (short * 0.03).clamp(11.0, 13.0),
                              color: const Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: (short * 0.008).clamp(2.0, 4.0)),
                          Text(
                            guardianName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (short * 0.04).clamp(14.0, 17.0),
                              color: const Color(0xFF273469),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (guardianEmail.isNotEmpty)
                            Text(
                              guardianEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: (short * 0.03).clamp(11.0, 13.0),
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

          // System Status Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all((short * 0.06).clamp(16.0, 24.0)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular((w * 0.06).clamp(16.0, 24.0)),
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
                SizedBox(height: (short * 0.02).clamp(6.0, 10.0)),
                Text(
                  appState.tr('You are Safe', 'أنت في أمان'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (short * 0.07).clamp(22.0, 28.0),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
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
                          color: widget.isConnected ? const Color(0xFF4ADE80) : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: (short * 0.02).clamp(6.0, 10.0)),
                      Text(
                        widget.isConnected 
                          ? appState.tr('Monitoring Active', 'المراقبة نشطة')
                          : appState.tr('Offline', 'غير متصل'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (short * 0.03).clamp(11.0, 13.0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

          // Device Status Section
          if (!widget.isConnected)
            _buildNoDeviceCard(context, appState)
          else
            _buildConnectedDevicesGrid(context, appState),

          SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),

          // Emergency Buttons
          GestureDetector(
            onTap: () => _triggerSOS(context),
            onLongPress: () => _triggerSOS(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: (short * 0.05).clamp(16.0, 22.0)),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular((w * 0.04).clamp(14.0, 18.0)),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (short * 0.052).clamp(18.0, 22.0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
                  Text(
                    appState.tr('Press and hold for 3 seconds', 'اضغط مع الاستمرار لمدة 3 ثوانٍ'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: (short * 0.03).clamp(11.0, 13.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
          Container(
            width: double.infinity,
            height: (short * 0.17).clamp(56.0, 68.0),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular((w * 0.04).clamp(14.0, 18.0)),
            ),
            child: TextButton.icon(
              onPressed: () => _callEmergencyContact(context),
              icon: Icon(LucideIcons.phone, color: Colors.white, size: (short * 0.055).clamp(20.0, 24.0)),
              label: Text(
                appState.tr('Call Emergency Contact', 'اتصل بجهة اتصال الطوارئ'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (short * 0.04).clamp(14.0, 17.0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appState.tr('Recent Activity', 'النشاط الأخير'),
                style: TextStyle(
                  fontSize: (short * 0.046).clamp(16.0, 20.0),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF273469),
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
          SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
          if (appState.scanHistory.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: (short * 0.08).clamp(24.0, 34.0)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular((w * 0.04).clamp(14.0, 18.0)),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Center(
                child: Text(
                  appState.tr('No activity yet', 'لا يوجد نشاط بعد'),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: (short * 0.036).clamp(13.0, 15.0)),
                ),
              ),
            )
          else
            ...appState.scanHistory.take(5).map((item) => Padding(
              padding: EdgeInsets.only(bottom: (short * 0.03).clamp(8.0, 14.0)),
              child: _buildActivityItem(
                context: context,
                icon: LucideIcons.qrCode,
                iconColor: const Color(0xFF1B64F2),
                title: item.title,
                subtitle: item.time,
                status: item.location,
                appState: appState,
              ),
            )),
        ],
      ),
    ),
    );
        },
      ),
    );
      },
    );
  }

  Widget _buildNoDeviceCard(BuildContext context, AppState appState) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((short * 0.06).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.06).clamp(16.0, 24.0)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all((short * 0.03).clamp(10.0, 14.0)),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular((w * 0.04).clamp(12.0, 18.0)),
                ),
                child: Icon(LucideIcons.watch, color: const Color(0xFF1B64F2), size: (short * 0.06).clamp(20.0, 26.0)),
              ),
              SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.tr('No Device Connected', 'لا يوجد جهاز متصل'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: (short * 0.04).clamp(14.0, 17.0),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF273469),
                      ),
                    ),
                    Text(
                      appState.tr('Wearable Link', 'رابط الجهاز'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: (short * 0.033).clamp(12.0, 14.0),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: (short * 0.06).clamp(16.0, 24.0)),
          GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WearerHardwareLinkPage(
                    name: appState.currentUser.name,
                    relationship: 'Self',
                    avatarUrl: appState.currentUser.imagePath,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: (short * 0.145).clamp(48.0, 58.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066CC), Color(0xFF273469)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular((short * 0.07).clamp(22.0, 28.0)),
              ),
              child: Center(
                child: Text(
                  appState.tr('+ Add Device', '+ إضافة جهاز'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (short * 0.04).clamp(14.0, 17.0),
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

  Widget _buildConnectedDevicesGrid(BuildContext context, AppState appState) {
    final short = MediaQuery.of(context).size.shortestSide;
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatusCard(
            context: context,
            icon: LucideIcons.watch,
            iconColor: const Color(0xFF1B64F2),
            label: appState.tr('Bracelet', 'السوار'),
            value: appState.tr('Connected', 'متصل'),
            appState: appState,
          ),
        ),
        SizedBox(width: (short * 0.04).clamp(10.0, 18.0)),
        Expanded(
          child: _buildSmallStatusCard(
            context: context,
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required AppState appState,
  }) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all((short * 0.05).clamp(14.0, 20.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 20.0)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all((short * 0.026).clamp(8.0, 12.0)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: (short * 0.06).clamp(20.0, 26.0)),
          ),
          SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
          Text(
            label,
            style: TextStyle(
              fontSize: (short * 0.033).clamp(12.0, 14.0),
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
          Text(
            value,
            style: TextStyle(
              fontSize: (short * 0.04).clamp(14.0, 17.0),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF273469),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String status,
    required AppState appState,
  }) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all((short * 0.042).clamp(12.0, 18.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.04).clamp(14.0, 18.0)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all((short * 0.026).clamp(8.0, 12.0)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: (short * 0.05).clamp(18.0, 22.0)),
          ),
          SizedBox(width: (short * 0.04).clamp(10.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (short * 0.038).clamp(14.0, 16.0),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF273469),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (short * 0.03).clamp(11.0, 13.0),
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: (short * 0.03).clamp(11.0, 13.0),
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
