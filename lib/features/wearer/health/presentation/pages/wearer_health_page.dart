import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';

class WearerHealthPage extends StatefulWidget {
  const WearerHealthPage({super.key});

  @override
  State<WearerHealthPage> createState() => _WearerHealthPageState();
}

class _WearerHealthPageState extends State<WearerHealthPage> {
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
        final topPad = (short * 0.12).clamp(20.0, 54.0);
        final bottomPad = mq.padding.bottom + mq.viewInsets.bottom + (short * 0.06).clamp(18.0, 28.0);
        final titleFs = (short * 0.07).clamp(22.0, 28.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
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
                  SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),

                  Text(
                    appState.tr('Health Monitoring', 'مراقبة الصحة'),
                    style: TextStyle(
                      fontSize: titleFs,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF273469),
                    ),
                  ),
                  SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),

                  // Heart Rate Card
                  Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.tr('Heart Rate', 'ضربات القلب'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  '72',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF273469),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  appState.tr('BPM', 'ن.ق'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(LucideIcons.heart, color: Color(0xFFE11D48), size: 32),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.05).clamp(14.0, 22.0)),

                  // Secondary Status Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: LucideIcons.watch,
                          iconColor: const Color(0xFF1B64F2),
                          label: appState.tr('Connection', 'الاتصال'),
                          value: appState.tr('Connected', 'متصل'),
                          appState: appState,
                        ),
                      ),
                      SizedBox(width: (short * 0.04).clamp(10.0, 18.0)),
                      Expanded(
                        child: _buildInfoCard(
                          icon: LucideIcons.battery,
                          iconColor: const Color(0xFF22C55E),
                          label: appState.tr('Bracelet Battery', 'بطارية السوار'),
                          value: '85%',
                          appState: appState,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: (short * 0.05).clamp(14.0, 22.0)),

                  // Sensors Status Card
                  Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.tr('Sensors Status', 'حالة الحساسات'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appState.tr('Active', 'نشط'),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF273469),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0FDF4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.checkCircle2, color: Color(0xFF22C55E), size: 24),
                            ),
                          ],
                        ),
                        SizedBox(height: (short * 0.06).clamp(16.0, 24.0)),
                        Wrap(
                          spacing: (short * 0.02).clamp(6.0, 10.0),
                          runSpacing: (short * 0.02).clamp(6.0, 10.0),
                          children: [
                            _buildSensorPill('Optical', appState),
                            _buildSensorPill('Accelerometer', appState),
                            _buildSensorPill('GPS', appState),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: (short * 0.08).clamp(22.0, 34.0)),

                  // Status Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: (short * 0.03).clamp(8.0, 14.0)),
                      Expanded(
                        child: Text(
                          appState.tr('All sensors are working normally.', 'جميع الحساسات تعمل بشكل طبيعي.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (short * 0.036).clamp(13.0, 15.0),
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required AppState appState,
  }) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    final pad = (short * 0.05).clamp(14.0, 20.0);
    final iconS = (short * 0.06).clamp(20.0, 26.0);
    final labelFs = (short * 0.032).clamp(12.0, 14.0);
    final valueFs = (short * 0.04).clamp(14.0, 17.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 20.0)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all((short * 0.026).clamp(8.0, 12.0)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: iconS),
          ),
          SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: labelFs,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueFs,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF273469),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorPill(String label, AppState appState) {
    final short = MediaQuery.of(context).size.shortestSide;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (short * 0.04).clamp(12.0, 18.0),
        vertical: (short * 0.02).clamp(6.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular((short * 0.05).clamp(16.0, 22.0)),
      ),
      child: Text(
        appState.tr(label, label), // Assuming same for both for these technical terms
        style: TextStyle(
          color: const Color(0xFF16A34A),
          fontSize: (short * 0.03).clamp(11.0, 13.0),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
