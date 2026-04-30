import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';

import 'package:q_link/features/guardian/profile/locate_bracelet_page.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/services/supabase_service.dart';

class ConnectedDevicePage extends StatelessWidget {
  final ProfileData profile;
  const ConnectedDevicePage({super.key, required this.profile});

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
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);
        final imgOuter = (short * 0.38).clamp(120.0, 168.0);
        final imgInner = (imgOuter * 0.62).clamp(72.0, 110.0);

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
                      children: [
                        // Header
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

                        // Device Image & Status
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: imgOuter,
                              height: imgOuter,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade100, width: 2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/pulse.png',
                                  width: imgInner,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.watch_outlined,
                                    size: (imgInner * 0.55).clamp(44.0, 64.0),
                                    color: const Color(0xFF273469),
                                  ),
                                ),
                              ),
                            ),
                            if (profile.hasDevice && profile.devices.first.isConnected)
                              Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 15, bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: (short * 0.045).clamp(14.0, 22.0)),
                        Text(
                          profile.hasDevice ? profile.devices.first.deviceType : 'Unknown Device',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (w * 0.055).clamp(18.0, 24.0),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              profile.hasDevice && profile.devices.first.isConnected ? Icons.check_circle : Icons.error_outline,
                              color: profile.hasDevice && profile.devices.first.isConnected ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              profile.hasDevice && profile.devices.first.isConnected
                                  ? appState.tr('Connected via Bluetooth', 'متصل عبر البلوتوث')
                                  : appState.tr('Disconnected', 'غير متصل'),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Battery Status Card
                        _buildStatusCard(
                          context,
                          icon: Icons.battery_charging_full,
                          iconColor: profile.hasDevice && profile.devices.first.batteryLevel > 20 ? Colors.green : Colors.red,
                          title: appState.tr('Battery Status', 'حالة البطارية'),
                          value: profile.hasDevice ? '${profile.devices.first.batteryLevel}%' : '--%',
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: profile.hasDevice ? profile.devices.first.batteryLevel / 100.0 : 0.0,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    profile.hasDevice && profile.devices.first.batteryLevel > 20 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                profile.hasDevice 
                                  ? appState.tr('Real-time battery monitoring active', 'مراقبة البطارية في الوقت الفعلي نشطة')
                                  : appState.tr('No device data available', 'لا توجد بيانات للجهاز'),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Connection Strength Card
                        _buildStatusCard(
                          context,
                          icon: Icons.signal_cellular_alt,
                          iconColor: Colors.green,
                          title: appState.tr('Connection Strength', 'قوة الاتصال'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                profile.hasDevice ? profile.devices.first.signalStrength : '--',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF273469)),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.signal_cellular_alt, color: Colors.green, size: 20),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Device Information
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appState.tr('Device Information', 'معلومات الجهاز'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(appState.tr('Serial Number', 'الرقم التسلسلي'), profile.hasDevice ? profile.devices.first.code : 'N/A'),
                        _buildInfoRow(appState.tr('Firmware Version', 'إصدار البرنامج'), 'v2.4.12-rc', isBadge: true),
                        _buildInfoRow(appState.tr('Connected At', 'تاريخ الاتصال'), profile.hasDevice ? profile.devices.first.connectedAt.toString().split(' ')[0] : 'N/A'),

                        const SizedBox(height: 32),

                        // Actions
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocateBraceletPage(profile: profile),
                              ),
                            );
                          },
                          icon: const Icon(Icons.my_location, color: Colors.white, size: 20),
                          label: Row(
                            children: [
                              const Spacer(),
                              Text(appState.tr('Find My Bracelet', 'البحث عن سواري'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                        ),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: () {
                            final appState = AppState();
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                title: Text(appState.tr('Disconnect Device', 'قطع اتصال الجهاز')),
                                content: Text(appState.tr(
                                  'Are you sure you want to disconnect this device?',
                                  'هل أنت متأكد أنك تريد قطع اتصال هذا الجهاز؟',
                                )),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx),
                                    child: Text(appState.tr('Cancel', 'إلغاء')),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Update Supabase status to disconnected
                                      if (profile.id != null && profile.id!.isNotEmpty) {
                                        try {
                                          await SupabaseService().client
                                              .from('patient_profiles')
                                              .update({'status': false})
                                              .eq('id', profile.id!);
                                        } catch (e) {
                                          debugPrint('Error disconnecting: $e');
                                        }
                                      }
                                      profile.devices.clear();
                                      AppState().markProfilesDirty();
                                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                                      if (context.mounted) Navigator.pop(context, true);
                                    },
                                    child: Text(
                                      appState.tr('Disconnect', 'قطع الاتصال'),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.bluetoothOff, color: Colors.red, size: 20),
                          label: Row(
                            children: [
                              const Spacer(),
                              Text(appState.tr('Disconnect Device', 'قطع اتصال الجهاز'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.red),
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),

                        SizedBox(height: (short * 0.03).clamp(8.0, 16.0)),
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

  Widget _buildStatusCard(BuildContext context, {required IconData icon, required Color iconColor, required String title, String? value, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 15)),
              const Spacer(),
              if (value != null)
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E3A8A))),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              const Spacer(),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
              if (isBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LATEST', style: TextStyle(color: Color(0xFF1B64F2), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }

}
