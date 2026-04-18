import 'package:flutter/material.dart';
import 'package:q_link/features/shared/home/presentation/pages/home_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildMapBackground(),
          _buildTopSection(),
          _buildGeofencingChip(),
          _buildNavigationButton(),
          _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Positioned.fill(
      top: 180,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE8EDEB),
        ),
        child: Stack(
          children: [
            // Simulated map grid lines
            CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(),
            ),
            // Profile markers on map
            _buildProfileMarker(
              left: 80,
              top: 60,
              name: 'MOHAMED SABER',
              imagePath: 'assets/images/Mohamed Saber.png',
              hasStatusDot: false,
            ),
            _buildProfileMarker(
              left: 200,
              top: 160,
              name: 'KARMA AHMED',
              imagePath: 'assets/images/karma.png',
              hasStatusDot: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMarker({
    required double left,
    required double top,
    required String name,
    required String imagePath,
    bool hasStatusDot = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE8D5C4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 23,
                  backgroundImage: AssetImage(imagePath),
                ),
              ),
              if (hasStatusDot)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 16),
                const Text(
                  'Map',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2 Bracelets  Active',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        const VideoLogoWidget(),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/mypic.png'),
        ),
        const Spacer(),
        const Icon(
          Icons.language,
          color: Color(0xFF1E3A8A),
          size: 28,
        ),
        const SizedBox(width: 16),
        Stack(
          children: [
            const Icon(
              Icons.notifications_none,
              color: Color(0xFF1E3A8A),
              size: 28,
            ),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search saved places...',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.my_location,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencingChip() {
    return Positioned(
      left: 20,
      bottom: 130,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.radar,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Geofencing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    return Positioned(
      right: 20,
      bottom: 130,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1B64F2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B64F2).withValues(alpha:0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.navigation,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 20,
      bottom: 200,
      child: Column(
        children: [
          _buildMapControlButton(Icons.add),
          const SizedBox(height: 2),
          Container(
            width: 40,
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 2),
          _buildMapControlButton(Icons.remove),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.grey.shade700,
        size: 20,
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB).withValues(alpha:0.4)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw some road-like lines
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha:0.7)
      ..strokeWidth = 4;

    // Horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      roadPaint,
    );

    // Diagonal road
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
