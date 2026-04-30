import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';

class LocateBraceletPage extends StatefulWidget {
  final ProfileData profile;

  const LocateBraceletPage({super.key, required this.profile});

  @override
  State<LocateBraceletPage> createState() => _LocateBraceletPageState();
}

class _LocateBraceletPageState extends State<LocateBraceletPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isRinging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerRing() {
    setState(() {
      _isRinging = true;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRinging = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasDevice = widget.profile.hasDevice;
    final device = hasDevice ? widget.profile.devices.first : null;

    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          backgroundColor: const Color(0xFF131A2A),
          body: Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF273469), Color(0xFF131A2A)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: (w * 0.055).clamp(16.0, 28.0),
                            vertical: (short * 0.028).clamp(8.0, 14.0),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              SizedBox(width: (w * 0.02).clamp(4.0, 10.0)),
                              Expanded(
                                child: Text(
                                  appState.tr('Locate Bracelet', 'تحديد موقع السوار'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: (w * 0.045).clamp(16.0, 19.0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const LanguageToggle(color: Colors.white),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final maxRing = (constraints.biggest.shortestSide * 0.88).clamp(180.0, 300.0);
                              final centerDot = (maxRing * 0.28).clamp(64.0, 96.0);
                              return Center(
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                ...List.generate(3, (index) {
                                  return AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      double progress = (_animationController.value + index / 3) % 1;
                                      return Container(
                                        width: maxRing * progress,
                                        height: maxRing * progress,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _isRinging 
                                                ? Colors.green.withValues(alpha: (1 - progress) * 0.5) 
                                                : Colors.white.withValues(alpha: (1 - progress) * 0.3),
                                            width: _isRinging ? 3 : 2,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                                Container(
                                  width: centerDot,
                                  height: centerDot,
                                  decoration: BoxDecoration(
                                    color: _isRinging ? Colors.green : const Color(0xFF1B64F2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isRinging ? Colors.green : const Color(0xFF1B64F2)).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isRinging ? Icons.notifications_active : Icons.location_on,
                                    color: Colors.white,
                                    size: (centerDot * 0.38).clamp(26.0, 36.0),
                                  ),
                                ),
                                Positioned(
                                  bottom: -15, 
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      _isRinging 
                                          ? appState.tr('RINGING...', 'جاري الرنين...')
                                          : appState.tr('SCANNING...', 'جاري المسح...'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      (w * 0.07).clamp(20.0, 36.0),
                      (short * 0.07).clamp(22.0, 36.0),
                      (w * 0.07).clamp(20.0, 36.0),
                      mq.viewInsets.bottom + mq.padding.bottom + (short * 0.26).clamp(80.0, 112.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.profile.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF273469),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: device?.isConnected == true ? Colors.green : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        device?.isConnected == true ? appState.tr('Connected', 'متصل') : appState.tr('Disconnected', 'غير متصل'),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      device != null ? '${device.batteryLevel}%' : '--%',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF273469),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.battery_std, color: device != null && device.batteryLevel > 20 ? Colors.green.shade400 : Colors.red.shade400, size: 28),
                                  ],
                                ),
                                Text(
                                  appState.tr('BATTERY LEVEL', 'مستوى البطارية'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        Text(
                          device?.isConnected == true
                              ? appState.tr(
                                  'Bracelet is nearby. You can trigger a sound to help the wearer locate it.',
                                  'السوار قريب. يمكنك تفعيل صوت لمساعدة مرتدي السوار في العثور عليه.',
                                )
                              : appState.tr(
                                  'Bracelet is out of range or turned off.',
                                  'السوار خارج النطاق أو مغلق.',
                                ),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                appState.tr('Signal Strength', 'قوة الإشارة'),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                device != null ? appState.tr(device.signalStrength, device.signalStrength) : '--',
                                style: const TextStyle(
                                  color: Color(0xFF273469),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Row(
                                children: [
                                  Icon(Icons.signal_cellular_alt, color: Colors.green, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        ElevatedButton.icon(
                          onPressed: (device?.isConnected == true && !_isRinging) ? _triggerRing : null,
                          icon: Icon(_isRinging ? Icons.volume_up : Icons.notifications_active_outlined, color: Colors.white),
                          label: Text(
                            _isRinging ? appState.tr('STOP RINGING', 'إيقاف الرنين') : appState.tr('Ring Bracelet', 'رنين السوار'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRinging ? Colors.red : const Color(0xFF1B64F2),
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          appState.tr(
                            'The bracelet will vibrate and emit a sound.',
                            'سيهتز السوار ويصدر صوتاً.',
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }

}
