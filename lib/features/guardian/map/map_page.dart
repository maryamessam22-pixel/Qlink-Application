import 'package:flutter/material.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:q_link/features/guardian/map/geofence_setup_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
import 'package:q_link/features/shared/pages/notifications_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}
class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final isArabic = appState.isArabic;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _buildRealMap(isArabic), // الخريطة الحقيقية
              _buildTopSection(isArabic, appState),
              _buildGeofencingChip(isArabic, appState),
              _buildNavigationButton(),
              _buildMapControls(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealMap(bool isArabic) {
    return Positioned.fill(
      top: 180, // نفس المسافة بتاعتك عشان تفضل تحت الـ Top Section
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(30.0444, 31.2357), // إحداثيات القاهرة
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.qlink.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(30.0500, 31.2300),
                width: 100,
                height: 100,
                child: _buildProfileMarker(
                  name: isArabic ? 'محمد صابر' : 'MOHAMED SABER',
                  imagePath: 'assets/images/Mohamed Saber.png',
                  hasStatusDot: false,
                ),
              ),
              Marker(
                point: const LatLng(30.0350, 31.2450),
                width: 100,
                height: 100,
                child: _buildProfileMarker(
                  name: isArabic ? 'كارما أحمد' : 'KARMA AHMED',
                  imagePath: 'assets/images/karma.png',
                  hasStatusDot: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شيلنا الـ Positioned من هنا عشان الـ Marker في الخريطة هو اللي بيحدد المكان
  Widget _buildProfileMarker({
    required String name,
    required String imagePath,
    bool hasStatusDot = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                    color: Colors.black.withValues(alpha: 0.15),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(bool isArabic, AppState appState) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                Text(
                  appState.tr('Map', 'الخريطة'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.tr('2 Bracelets Active', '2 أساور نشطة'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSearchBar(appState),
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
        VideoLogoWidget(),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFE6F0FE),
          backgroundImage: getUserAvatarProvider(AppState().currentUser.imagePath),
          onBackgroundImageError: (_, __) {},
        ),
        const Spacer(),
        const LanguageToggle(),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
          child: AnimatedBuilder(
            animation: AppState(),
            builder: (context, _) {
              final unread = AppState().unreadNotificationCount;
              return Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Color(0xFF1E3A8A), size: 28),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppState appState) {
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
            child: TextField(
              controller: _searchController,
              textAlign: appState.isArabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: appState.tr('Search saved places...', 'ابحث عن الأماكن المحفوظة...'),
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appState.tr('Centering on ${value}...', 'يتم التركيز على ${value}...'))),
                  );
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              // Recenter map on user location (simulated Cairo center)
              _mapController.move(const LatLng(30.0444, 31.2357), 13.0);
            },
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 6, left: 6),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencingChip(bool isArabic, AppState appState) {
    return Positioned(
      left: 20,
      bottom: 130,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GeofenceSetupPage()),
          );
        },
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
                color: Colors.black.withValues(alpha: 0.2),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.radar,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                appState.tr('Geofencing', 'السياج الجغرافي'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
              color: const Color(0xFF1B64F2).withValues(alpha: 0.35),
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
          _buildMapControlButton(Icons.add, () {
            // زووم ان
            _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
          }),
          const SizedBox(height: 2),
          Container(
            width: 40,
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 2),
          _buildMapControlButton(Icons.remove, () {
            // زووم اوت
            _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    String q = query.toLowerCase();
    
    // Simulate finding family members
    if (q.contains('moh') || q.contains('صابر')) {
      _mapController.move(const LatLng(30.0444, 31.2357), 16.0);
    } else if (q.contains('kar') || q.contains('كارما')) {
      _mapController.move(const LatLng(30.0480, 31.2390), 16.0);
    }
  }
}
