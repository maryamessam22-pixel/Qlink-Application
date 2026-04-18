import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/qlink_logo.png',
                width: 180,
              ),
              const SizedBox(height: 60),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF273469),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF273469)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading..',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
