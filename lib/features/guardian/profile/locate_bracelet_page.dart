import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/core/widgets/language_toggle.dart';

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
        return Scaffold(
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                appState.tr('Locate Bracelet', 'تحديد موقع السوار'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const LanguageToggle(color: Colors.white),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: Center(
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
                                        width: 260 * progress,
                                        height: 260 * progress,
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
                                  width: 80,
                                  height: 80,
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
                                  child: Icon(_isRinging ? Icons.notifications_active : Icons.location_on, color: Colors.white, size: 32),
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
                    padding: const EdgeInsets.all(32),
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
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB).withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(LucideIcons.home, AppState().tr('Home', 'الرئيسية')),
          _buildNavItem(LucideIcons.map, AppState().tr('Map', 'الخريطة')),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF1B64F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          _buildNavItem(LucideIcons.lock, AppState().tr('Vault', 'الخزنة')),
          _buildNavItem(LucideIcons.settings, AppState().tr('Settings', 'الإعدادات')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
