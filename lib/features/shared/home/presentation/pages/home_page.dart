import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:video_player/video_player.dart';
import 'package:q_link/features/shared/profile/presentation/pages/add_profile_identity.dart';
import 'package:q_link/features/shared/profile/presentation/pages/connect_device_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/shared/profile/presentation/pages/profile_management_page.dart';

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

              // Dynamic Stats and Status
              AnimatedBuilder(
                animation: AppState(),
                builder: (context, _) {
                  final appState = AppState();
                  return Column(
                    children: [
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
                                          color: (appState.deviceCount > 0 
                                            ? const Color(0xFF0E9F6E) 
                                            : const Color(0xFFD1D5DB)).withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          appState.deviceCount > 0 ? 'ONLINE' : 'OFFLINE',
                                          style: TextStyle(
                                            fontSize: 10, 
                                            fontWeight: FontWeight.bold, 
                                            color: appState.deviceCount > 0 ? Colors.white : const Color(0xFF4B5563)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text('${appState.deviceCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B64F2))),
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
                                  Text('${appState.profileCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0E9F6E))),
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
                          color: appState.deviceCount > 0 ? const Color(0xFFDEF7EC) : const Color(0xFFEAF8F0),
                          border: Border.all(color: appState.deviceCount > 0 ? const Color(0xFF84E1BC) : const Color(0xFFB4E6C9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, color: appState.deviceCount > 0 ? const Color(0xFF0E9F6E) : const Color(0xFF0E9F6E)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('System Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E9F6E))),
                                  const SizedBox(height: 4),
                                  Text(
                                    appState.deviceCount > 0 
                                      ? 'System fully active. ${appState.deviceCount} device(s) linked.' 
                                      : 'No devices connected till now. No alerts detected.', 
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Dynamic Protected Member Section
              AnimatedBuilder(
                animation: AppState(),
                builder: (context, _) {
                  final appState = AppState();
                  if (appState.profiles.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Protected Member',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddProfileIdentityPage()),
                              );
                            },
                            child: const Text('+ Add Member', style: TextStyle(color: Color(0xFF1B64F2), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...appState.profiles.asMap().entries.map((entry) {
                        return _buildProtectedMemberCard(context, entry.key, entry.value);
                      }),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Create Profile Card (Show only if no profiles exist)
              AnimatedBuilder(
                animation: AppState(),
                builder: (context, _) {
                  if (AppState().profiles.isNotEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
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
                                  MaterialPageRoute(builder: (context) => const AddProfileIdentityPage()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_box, color: Color(0xFF0E9F6E), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add First Profile',
                                      style: TextStyle(color: Color(0xFF0E9F6E), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),

              // Connect Bracelet Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF273469)],
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
                        if (AppState().profileCount == 0) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Profile Required'),
                              content: const Text('You must create a profile first before connecting a bracelet.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddProfileIdentityPage()),
                                    );
                                  },
                                  child: const Text('Create Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConnectDevicePage()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: Color(0xFF273469), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              AppState().deviceCount > 0 ? 'Add Bracelet' : 'Add First Bracelet',
                              style: const TextStyle(color: Color(0xFF273469), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity Section
              AnimatedBuilder(
                animation: AppState(),
                builder: (context, _) {
                  final appState = AppState();
                  final hasDevice = appState.deviceCount > 0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              hasDevice ? 'View All' : 'See all',
                              style: TextStyle(
                                color: hasDevice ? const Color(0xFF1B64F2) : Colors.grey,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!hasDevice)
                        _buildEmptyActivity()
                      else
                        _buildRealActivity(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // Padding to allow scrolling over the bottom nav bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildProtectedMemberCard(BuildContext context, int index, ProfileData profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF273469),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: profile.imagePath.contains('mypic') 
                  ? Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?', 
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(profile.imagePath, fit: BoxFit.cover, width: 60, height: 60),
                    ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        if (profile.hasDevice) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, color: Color(0xFF0E9F6E), size: 10),
                          const SizedBox(width: 4),
                          Text(
                            profile.devices.first.deviceType.contains('"') 
                              ? profile.devices.first.deviceType.split('"')[1]
                              : profile.devices.first.deviceType, 
                            style: const TextStyle(fontSize: 12, color: Colors.grey)
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(profile.relationship, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileManagementPage(
                          profileIndex: index,
                          profile: profile,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFF3F4F6)),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Profile', style: TextStyle(color: Color(0xFF1B64F2), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: profile.hasDevice 
                  ? OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle, color: Colors.purple, size: 18),
                      label: const Text('Added Device', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.purple.withOpacity(0.1)),
                        backgroundColor: Colors.purple.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ConnectDevicePage(targetProfileIndex: index)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.purple.withOpacity(0.1)),
                        backgroundColor: Colors.purple.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('+ Add Device', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Home - Just now', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return DottedBorder(
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
    );
  }

  Widget _buildRealActivity() {
    return Column(
      children: [
        _buildActivityRow(
          icon: Icons.error_outline,
          color: Colors.red,
          title: 'Emergency',
          subtitle: 'Emergency QR Scanned',
          details: 'Mohamed Saber • Downtown Metro',
          time: '10:30 AM',
        ),
        const SizedBox(height: 12),
        _buildActivityRow(
          icon: Icons.location_on_outlined,
          color: Colors.green,
          title: 'Safe Zone',
          subtitle: 'Safe Zone Entry',
          details: 'Mohamed Saber arrived at Home',
          time: 'Yesterday',
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/home_bg.png', 
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B64F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_pin_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('1 active pin near you', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String details,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                const SizedBox(height: 2),
                Text(details, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ],
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
