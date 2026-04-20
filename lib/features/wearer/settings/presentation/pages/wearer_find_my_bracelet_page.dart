import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_bottom_nav.dart';

class WearerFindMyBraceletPage extends StatefulWidget {
  const WearerFindMyBraceletPage({super.key});

  @override
  State<WearerFindMyBraceletPage> createState() =>
      _WearerFindMyBraceletPageState();
}

class _WearerFindMyBraceletPageState extends State<WearerFindMyBraceletPage> {
  bool _isRinging = false;

  void _ringBracelet() {
    setState(() => _isRinging = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bracelet is ringing and vibrating...'),
        duration: Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isRinging = false);
    });
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF273469),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appState.tr('Find My Bracelet', 'البحث عن سواري'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF273469),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bracelet Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.tr('Bracelet Name', 'اسم السوار'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qlink Bracelet',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF273469),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.tr(
                                      'Connection Status',
                                      'حالة الاتصال',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0E9F6E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        appState.tr('Connected', 'متصل'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0E9F6E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.tr(
                                      'Battery Level',
                                      'مستوى البطارية',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF0E9F6E,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.battery_full,
                                          color: Color(0xFF0E9F6E),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '82%',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF273469),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1E9FF)),
                    ),
                    child: Text(
                      appState.tr(
                        'Your bracelet is nearby. You can make it ring to help locate it.',
                        'سوارك قريب منك. يمكنك جعله يرن للمساعدة في تحديد موقعه.',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Signal Strength
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.tr('Signal Strength', 'قوة الإشارة'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              appState.tr('Strong Signal', 'إشارة قوية'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF273469),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                ...List.generate(
                                  4,
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Container(
                                      width: 3,
                                      height: 10 + (index * 2).toDouble(),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0E9F6E),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Ring Bracelet Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isRinging ? null : _ringBracelet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B64F2),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: _isRinging ? 0 : 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRinging
                                ? Icons.notifications_active
                                : Icons.notifications,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isRinging
                                ? appState.tr('Ringing...', 'جاري الرنين...')
                                : appState.tr('Ring My Bracelet', 'رن سواري'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ringing info
                  Center(
                    child: Text(
                      appState.tr(
                        'Your bracelet will vibrate and make a sound.',
                        'سيهتز السوار الخاص بك ويصدر صوتاً.',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reconnect Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              appState.tr(
                                'Reconnecting to bracelet...',
                                'إعادة الاتصال بالسوار...',
                              ),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        appState.tr('Reconnect Bracelet', 'إعادة توصيل السوار'),
                        style: const TextStyle(
                          color: Color(0xFF273469),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const WearerBottomNav(),
        );
      },
    );
  }
}
