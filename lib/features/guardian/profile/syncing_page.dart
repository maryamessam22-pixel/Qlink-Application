import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';

class SyncingPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onComplete;

  const SyncingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onComplete,
  });

  @override
  State<SyncingPage> createState() => _SyncingPageState();
}

class _SyncingPageState extends State<SyncingPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startSyncing();
  }

  void _startSyncing() async {
    // Simulate progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _progress = i / 100;
        });
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.08).clamp(24.0, 48.0);
        final logoW = (w * 0.42).clamp(140.0, 200.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    (short * 0.04).clamp(12.0, 24.0),
                    hPad,
                    mq.viewInsets.bottom + mq.padding.bottom + (short * 0.04).clamp(12.0, 24.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - mq.padding.vertical),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: const LanguageToggle(),
                        ),
                        Positioned.fill(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: (short * 0.06).clamp(16.0, 32.0)),
                            Image.asset(
                              'assets/images/qlink_logo.png',
                              width: logoW,
                            ),
                            SizedBox(height: (short * 0.08).clamp(32.0, 64.0)),
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (w * 0.06).clamp(20.0, 26.0),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF273469),
                              ),
                            ),
                            SizedBox(height: (short * 0.03).clamp(10.0, 20.0)),
                            Text(
                              widget.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (w * 0.038).clamp(13.0, 16.0),
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: (short * 0.08).clamp(32.0, 64.0)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF273469)),
                                minHeight: (short * 0.02).clamp(6.0, 10.0),
                              ),
                            ),
                            SizedBox(height: (short * 0.04).clamp(14.0, 24.0)),
                            Text(
                              AppState().tr('Loading..', 'جاري التحميل..'),
                              style: TextStyle(
                                fontSize: (w * 0.035).clamp(12.0, 15.0),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: (short * 0.04).clamp(12.0, 24.0)),
                          ],
                        ),
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
}
