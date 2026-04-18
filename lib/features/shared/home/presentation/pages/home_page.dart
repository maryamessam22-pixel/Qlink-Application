import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:video_player/video_player.dart';
import 'package:q_link/features/shared/profile/presentation/pages/add_profile_identity.dart';
import 'package:q_link/features/shared/profile/presentation/pages/connect_device_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FC), // fallback
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom App Bar Header
              Row(
                children: [
                  const VideoLogoWidget(),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/mypic.png'),
                  ),
                  const Spacer(),
                  const Icon(Icons.language, color: Color(0xFF1E3A8A), size: 28),
                  const SizedBox(width: 16),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none, color: Color(0xFF1E3A8A), size: 28),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Welcome Text
              const Text(
                'Hello, Mariam Essam',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your Safety Circle Command Center',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.devices_outlined, color: Color(0xFF1B64F2)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1D5DB).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'OFFLINE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B64F2))),
                          const Text('Active Devices', style: TextStyle(fontSize: 13, color: Color(0xFF1B64F2))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F8EE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.group_outlined, color: Color(0xFF0E9F6E)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0E9F6E))),
                          const Text('Protected Members', style: TextStyle(fontSize: 13, color: Color(0xFF0E9F6E))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // System Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F0),
                  border: Border.all(color: const Color(0xFFB4E6C9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF0E9F6E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('System Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E9F6E))),
                          const SizedBox(height: 4),
                          Text('No devices connected till now. No alerts detected.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Create Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E9F6E), Color(0xFF046C4E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create a Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      'Create a medical ID for a loved one to activate their emergency QR protection immediately.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProfileIdentityPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFF0E9F6E)),
                            SizedBox(width: 8),
                            Text('Add First Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E9F6E))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Connect Bracelet Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3F83F8), Color(0xFF5850EC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connect a Bracelet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      'Pair a Qlink bracelet to start protecting your loved ones in real time and expand your safety circle.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConnectDevicePage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFF3F83F8)),
                            SizedBox(width: 8),
                            Text('Add First Bracelet', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F83F8))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Recent Activity Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  Text('See all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E3A8A).withOpacity(0.8))),
                ],
              ),
              const SizedBox(height: 16),

              // Dashed Box Activity
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Colors.grey.shade300,
                  strokeWidth: 1.5,
                  dashPattern: const [8, 4],
                  radius: const Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No activity yet', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),

              // Padding to allow scrolling over the bottom nav bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class VideoLogoWidget extends StatefulWidget {
  const VideoLogoWidget({super.key});

  @override
  State<VideoLogoWidget> createState() => _VideoLogoWidgetState();
}

class _VideoLogoWidgetState extends State<VideoLogoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/logos/vid-icon.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: _controller.value.isInitialized
          ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          : const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A8A)),
              ),
            ),
    );
  }
}
