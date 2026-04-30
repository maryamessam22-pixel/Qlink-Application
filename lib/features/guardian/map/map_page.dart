import 'package:flutter/material.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/features/guardian/map/geofence_setup_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
import 'package:q_link/features/shared/pages/notifications_page.dart';
import 'package:q_link/services/supabase_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<PatientProfile>> _profilesFuture;
  late Future<Map<String, Map<String, double>>> _locationsFuture;
  List<PatientProfile> _profiles = [];

  // Placeholder offsets around Cairo since no real GPS data exists yet
  static const List<LatLng> _placeholderCoords = [
    LatLng(30.0500, 31.2300),
    LatLng(30.0350, 31.2450),
    LatLng(30.0430, 31.2180),
    LatLng(30.0560, 31.2560),
    LatLng(30.0280, 31.2340),
  ];

  @override
  void initState() {
    super.initState();
    _profilesFuture = _loadProfiles();
    _locationsFuture = SupabaseService().fetchLatestProfileLocations();
    AppState().addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() {
    if (!mounted || !AppState().profilesDirty) return;
    setState(() {
      _profilesFuture = _loadProfiles();
      _locationsFuture = SupabaseService().fetchLatestProfileLocations();
    });
    AppState().clearProfilesDirty();
  }

  Future<List<PatientProfile>> _loadProfiles() async {
    final profiles = await SupabaseService().fetchPatientProfiles();
    if (mounted) setState(() => _profiles = profiles);
    return profiles;
  }

  @override
  void dispose() {
    AppState().removeListener(_onAppStateChanged);
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

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _buildRealMap(context),
              _buildTopSection(context, appState),
              _buildGeofencingChip(context, appState),
              _buildNavigationButton(context),
              _buildMapControls(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealMap(BuildContext context) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final mapTop = (mq.size.height * 0.21).clamp(132.0, 228.0);
    final markerWidth = (short * 0.26).clamp(72.0, 118.0);
    // Marker box must fit Column: avatar + gap + label (square width was too short in height).
    final avatarBox = (short * 0.132).clamp(44.0, 58.0);
    final gapAfterAvatar = (short * 0.015).clamp(4.0, 8.0);
    final nameFs = (short * 0.022).clamp(8.0, 11.0);
    final labelPadV = (short * 0.005).clamp(1.0, 4.0) * 2;
    final markerHeight = (avatarBox +
            gapAfterAvatar +
            labelPadV +
            nameFs * 1.45 +
            10)
        .clamp(markerWidth * 1.12, markerWidth * 1.55);

    return Positioned.fill(
      top: mapTop,
      child: FutureBuilder<List<PatientProfile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeProfiles = (snapshot.data ?? [])
              .where((p) => p.status)
              .toList();

          final markers = <Marker>[];

          return FutureBuilder<Map<String, Map<String, double>>>(
            future: _locationsFuture,
            builder: (context, locSnapshot) {
              final locations = locSnapshot.data ?? const <String, Map<String, double>>{};
              markers.clear();
              for (int i = 0; i < activeProfiles.length; i++) {
                final profile = activeProfiles[i];
                final loc = locations[profile.id];
                final coord = (loc != null)
                    ? LatLng(loc['lat']!, loc['lng']!)
                    : _placeholderCoords[i % _placeholderCoords.length];
                markers.add(Marker(
                  point: coord,
                  width: markerWidth,
                  height: markerHeight,
                  child: _buildProfileMarker(
                    context,
                    name: profile.profileName.toUpperCase(),
                    avatarUrl: profile.avatarUrl,
                    hasStatusDot: true,
                    maxLabelWidth: markerWidth - 4,
                  ),
                ));
              }

              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(30.0444, 31.2357),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.qlink.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileMarker(
    BuildContext context, {
    required String name,
    required String avatarUrl,
    bool hasStatusDot = false,
    double? maxLabelWidth,
  }) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final avatarBox = (short * 0.132).clamp(44.0, 58.0);
    final borderW = (short * 0.007).clamp(2.0, 3.5);
    final innerR = (avatarBox * 0.42).clamp(18.0, 25.0);
    final initialFs = (avatarBox * 0.32).clamp(14.0, 19.0);
    final dot = (short * 0.03).clamp(9.0, 14.0);
    final nameFs = (short * 0.022).clamp(8.0, 11.0);

    ImageProvider? imageProvider;
    if (avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('assets')) {
        imageProvider = AssetImage(avatarUrl);
      } else if (avatarUrl.startsWith('http')) {
        imageProvider = NetworkImage(avatarUrl);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarBox,
              height: avatarBox,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8D5C4), width: borderW),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: (short * 0.02).clamp(6.0, 10.0),
                    offset: Offset(0, (short * 0.008).clamp(2.0, 4.0)),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: innerR,
                backgroundColor: const Color(0xFF273469),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: initialFs,
                        ),
                      )
                    : null,
              ),
            ),
            if (hasStatusDot)
              Positioned(
                right: (short * 0.005).clamp(1.0, 3.0),
                bottom: (short * 0.005).clamp(1.0, 3.0),
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: (dot * 0.14).clamp(1.5, 2.5)),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: (short * 0.015).clamp(4.0, 8.0)),
        Container(
          constraints: maxLabelWidth != null
              ? BoxConstraints(maxWidth: maxLabelWidth)
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: (short * 0.016).clamp(4.0, 8.0),
            vertical: (short * 0.005).clamp(1.0, 4.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular((short * 0.028).clamp(8.0, 12.0)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              name,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: nameFs,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF374151),
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context, AppState appState) {
    final activeCount = _profiles.where((p) => p.status).length;
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final hPad = (w * 0.05).clamp(14.0, 24.0);
    final vPad = (short * 0.028).clamp(8.0, 14.0);
    final titleFs = (w * 0.055).clamp(18.0, 24.0);
    final subtitleFs = (w * 0.036).clamp(12.0, 15.0);
    final gapAfterBar = (short * 0.038).clamp(12.0, 18.0);
    final gapSmall = (short * 0.01).clamp(3.0, 6.0);
    final gapBeforeSearch = (short * 0.03).clamp(10.0, 14.0);
    final kb = mq.viewInsets.bottom;

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
              blurRadius: (short * 0.024).clamp(6.0, 12.0),
              offset: Offset(0, (short * 0.005).clamp(1.0, 3.0)),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: kb > 0 ? kb + 8 : 0),
            physics: kb > 0
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  SizedBox(height: gapAfterBar),
                  Text(
                    appState.tr('Map', 'الخريطة'),
                    style: TextStyle(
                      fontSize: titleFs,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: gapSmall),
                  Text(
                    activeCount == 0
                        ? appState.tr('No active bracelets', 'لا توجد أساور نشطة')
                        : appState.tr(
                            '$activeCount Bracelet${activeCount == 1 ? '' : 's'} Active',
                            '$activeCount أسورة نشطة',
                          ),
                    style: TextStyle(
                      fontSize: subtitleFs,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: gapBeforeSearch),
                  _buildSearchBar(context, appState),
                  SizedBox(height: (short * 0.02).clamp(6.0, 12.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final gapLogo = (w * 0.02).clamp(6.0, 10.0);
    final avatarR = (short * 0.042).clamp(14.0, 18.0);
    final notifIcon = (short * 0.068).clamp(24.0, 30.0);
    final badgeMin = (short * 0.04).clamp(14.0, 18.0);
    final badgeFs = (short * 0.022).clamp(8.0, 10.0);
    final trailingGap = (w * 0.04).clamp(10.0, 18.0);

    return Row(
      children: [
        const VideoLogoWidget(),
        SizedBox(width: gapLogo),
        CircleAvatar(
          radius: avatarR,
          backgroundColor: const Color(0xFFE6F0FE),
          backgroundImage: getUserAvatarProvider(AppState().currentUser.imagePath),
          onBackgroundImageError: (_, __) {},
        ),
        const Spacer(),
        const LanguageToggle(),
        SizedBox(width: trailingGap),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
          child: AnimatedBuilder(
            animation: AppState(),
            builder: (context, _) {
              final unread = AppState().unreadNotificationCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none,
                      color: const Color(0xFF1E3A8A), size: notifIcon),
                  if (unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all((short * 0.005).clamp(1.0, 3.0)),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        constraints:
                            BoxConstraints(minWidth: badgeMin, minHeight: badgeMin),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFs,
                              fontWeight: FontWeight.bold),
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

  Widget _buildSearchBar(BuildContext context, AppState appState) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final barH = (short * 0.12).clamp(44.0, 54.0);
    final hintFs = (w * 0.035).clamp(12.0, 15.0);
    final iconPad = (w * 0.035).clamp(10.0, 16.0);
    final searchIcon = (short * 0.055).clamp(20.0, 24.0);
    final locBtn = (short * 0.092).clamp(32.0, 40.0);
    final locIcon = (locBtn * 0.48).clamp(16.0, 20.0);
    final marginH = (w * 0.014).clamp(4.0, 8.0);

    return Container(
      height: barH,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((short * 0.032).clamp(10.0, 14.0)),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(width: iconPad),
          Icon(Icons.search, color: Colors.grey.shade400, size: searchIcon),
          SizedBox(width: (w * 0.024).clamp(6.0, 12.0)),
          Expanded(
            child: TextField(
              controller: _searchController,
              textAlign: appState.isArabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: appState.tr(
                    'Search members...', 'ابحث عن الأعضاء...'),
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: hintFs),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: (barH * 0.2).clamp(8.0, 14.0),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) _performSearch(value);
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              _mapController.move(const LatLng(30.0444, 31.2357), 13.0);
            },
            child: Container(
              width: locBtn,
              height: locBtn,
              margin: EdgeInsets.only(right: marginH, left: marginH),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.my_location,
                  color: Colors.grey.shade600, size: locIcon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencingChip(BuildContext context, AppState appState) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final leftPad = (w * 0.05).clamp(14.0, 24.0);
    final bottomFab = mq.padding.bottom + (short * 0.24).clamp(92.0, 128.0);

    return Positioned(
      left: leftPad,
      bottom: bottomFab,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const GeofenceSetupPage())),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.04).clamp(12.0, 18.0),
            vertical: (short * 0.024).clamp(8.0, 12.0),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular((short * 0.06).clamp(18.0, 28.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: (short * 0.03).clamp(8.0, 14.0),
                offset: Offset(0, (short * 0.01).clamp(3.0, 6.0)),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: (short * 0.065).clamp(20.0, 28.0),
                height: (short * 0.065).clamp(20.0, 28.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.radar,
                  color: Colors.white,
                  size: (short * 0.038).clamp(12.0, 16.0),
                ),
              ),
              SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
              Text(
                appState.tr('Geofencing', 'السياج الجغرافي'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (w * 0.032).clamp(11.0, 14.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final rightPad = (w * 0.05).clamp(14.0, 24.0);
    final bottomFab = mq.padding.bottom + (short * 0.24).clamp(92.0, 128.0);
    final btn = (short * 0.14).clamp(46.0, 58.0);
    final iconSz = (btn * 0.46).clamp(20.0, 28.0);

    return Positioned(
      right: rightPad,
      bottom: bottomFab,
      child: Container(
        width: btn,
        height: btn,
        decoration: BoxDecoration(
          color: const Color(0xFF1B64F2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B64F2).withValues(alpha: 0.35),
              blurRadius: (short * 0.035).clamp(10.0, 16.0),
              offset: Offset(0, (short * 0.012).clamp(4.0, 7.0)),
            ),
          ],
        ),
        child: Icon(Icons.navigation, color: Colors.white, size: iconSz),
      ),
    );
  }

  Widget _buildMapControls(BuildContext context) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final rightPad = (w * 0.05).clamp(14.0, 24.0);
    final navClear = mq.padding.bottom + (short * 0.24).clamp(92.0, 128.0);
    final controlsBottom = navClear + (short * 0.16).clamp(56.0, 80.0);
    final gap = (short * 0.006).clamp(1.0, 4.0);

    return Positioned(
      right: rightPad,
      bottom: controlsBottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMapControlButton(context, Icons.add, () {
            _mapController.move(
                _mapController.camera.center, _mapController.camera.zoom + 1);
          }),
          SizedBox(height: gap),
          Container(
            width: (short * 0.1).clamp(34.0, 44.0),
            height: 1,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: gap),
          _buildMapControlButton(context, Icons.remove, () {
            _mapController.move(
                _mapController.camera.center, _mapController.camera.zoom - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final side = (short * 0.1).clamp(36.0, 44.0);
    final iconSz = (side * 0.48).clamp(18.0, 22.0);
    final radius = (short * 0.02).clamp(6.0, 10.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: (short * 0.016).clamp(4.0, 8.0),
              offset: Offset(0, (short * 0.005).clamp(1.0, 3.0)),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: iconSz),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty || _profiles.isEmpty) return;
    final q = query.toLowerCase();

    // Find first matching profile by name
    for (int i = 0; i < _profiles.length; i++) {
      if (_profiles[i].profileName.toLowerCase().contains(q)) {
        final coord = _placeholderCoords[i % _placeholderCoords.length];
        // Exact coordinates come from app_locations when available.
        _mapController.move(coord, 16.0);

        final appState = AppState();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appState.tr(
            'Centering on ${_profiles[i].profileName}',
            'التركيز على ${_profiles[i].profileName}',
          )),
          duration: const Duration(seconds: 2),
        ));
        return;
      }
    }
  }
}
