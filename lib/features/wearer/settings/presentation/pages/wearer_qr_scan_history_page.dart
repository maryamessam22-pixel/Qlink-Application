import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class WearerQrScanHistoryPage extends StatelessWidget {
  const WearerQrScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.06).clamp(16.0, 28.0);
        final bottomPad = mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              appState.tr('QR Scan History', 'سجل مسح QR'),
              style: const TextStyle(
                color: Color(0xFF273469),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, bottomPad),
            child: Column(
              children: [
                _buildScanItem(
                  context: context,
                  appState: appState,
                  title: 'Emergency Scan (Mohamed\'s Bracelet)',
                  subtitle: 'Scanned by +20 123 456 7890',
                  location: 'Cairo, Egypt',
                  time: '2 hours ago',
                ),
                SizedBox(height: (short * 0.2).clamp(56.0, 88.0)),
                
                // Clear History Button
                Center(
                  child: Container(
                    width: (w * 0.72).clamp(240.0, 320.0),
                    height: (short * 0.145).clamp(48.0, 58.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular((short * 0.07).clamp(22.0, 28.0)),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        appState.tr('Clear History', 'مسح السجل'),
                        style: TextStyle(
                          color: Color(0xFF273469),
                          fontSize: (short * 0.04).clamp(14.0, 17.0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const WearerBottomNav(),
        );
      },
    );
  }

  Widget _buildScanItem({
    required BuildContext context,
    required AppState appState,
    required String title,
    required String subtitle,
    required String location,
    required String time,
  }) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((short * 0.06).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.06).clamp(16.0, 24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.qrCode, color: Color(0xFF1B64F2), size: 24),
          ),
          SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: (short * 0.04).clamp(14.0, 17.0),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF273469),
                  ),
                ),
                SizedBox(height: (short * 0.02).clamp(6.0, 10.0)),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: (short * 0.036).clamp(13.0, 15.0), color: Colors.grey.shade500),
                    children: [
                      TextSpan(text: appState.tr('Scanned by ', 'تم المسح بواسطة ')),
                      TextSpan(
                        text: '+20 123 456 7890',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
                Text(
                  '$location • $time',
                  style: TextStyle(
                    fontSize: (short * 0.033).clamp(12.0, 14.0),
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
