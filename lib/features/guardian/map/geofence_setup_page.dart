import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/guardian/profile/add_profile_identity.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
import 'package:q_link/services/supabase_service.dart';

class GeofenceSetupPage extends StatefulWidget {
  const GeofenceSetupPage({super.key});

  @override
  State<GeofenceSetupPage> createState() => _GeofenceSetupPageState();
}

class _GeofenceSetupPageState extends State<GeofenceSetupPage> {
  final MapController _mapController = MapController();
  int _currentStep = 1; // 1: Select Member, 2: Define Zone, 3: Success
  PatientProfile? _selectedMember;
  double _radius = 500;
  bool _alertsEnabled = true;
  final TextEditingController _zoneNameController = TextEditingController(text: 'Home');
  late Future<List<PatientProfile>> _profilesFuture;
  late Future<Map<String, Map<String, double>>> _locationsFuture;
  List<PatientProfile> _profiles = [];
  Map<String, Map<String, double>> _locations = {};
  LatLng? _zoneCenter;

  Future<List<PatientProfile>> _loadProfiles() async {
    final rows = await SupabaseService().fetchPatientProfiles();
    if (mounted) setState(() => _profiles = rows);
    return rows;
  }

  Future<Map<String, Map<String, double>>> _loadLocations() async {
    final rows = await SupabaseService().fetchLatestProfileLocations();
    if (mounted) setState(() => _locations = rows);
    return rows;
  }

  LatLng _selectedMemberCenter() {
    final profileId = _selectedMember?.id;
    if (profileId != null) {
      final loc = _locations[profileId];
      if (loc != null && loc['lat'] != null && loc['lng'] != null) {
        return LatLng(loc['lat']!, loc['lng']!);
      }
    }
    return const LatLng(30.0444, 31.2357);
  }

  LatLng _effectiveZoneCenter() => _zoneCenter ?? _selectedMemberCenter();

  String _formatLatLng(LatLng point) =>
      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

  void _recenterToSelectedMember() {
    final center = _selectedMemberCenter();
    setState(() => _zoneCenter = center);
    _mapController.move(center, _mapController.camera.zoom);
  }

  void _setRadius(double meters) {
    setState(() => _radius = meters);
  }

  void _goToSuccess(AppState appState) {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.tr('Please select a member first.', 'اختر عضواً أولاً.'))),
      );
      return;
    }
    if (_zoneNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.tr('Zone name is required.', 'اسم المنطقة مطلوب.'))),
      );
      return;
    }
    setState(() => _currentStep = 3);
  }

  @override
  void initState() {
    super.initState();
    _profilesFuture = _loadProfiles();
    _locationsFuture = _loadLocations();
    AppState().addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() {
    if (!mounted || !AppState().profilesDirty) return;
    setState(() {
      _profilesFuture = _loadProfiles();
      _locationsFuture = _loadLocations();
    });
    AppState().clearProfilesDirty();
  }

  @override
  void dispose() {
    AppState().removeListener(_onAppStateChanged);
    _mapController.dispose();
    _zoneNameController.dispose();
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
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, appState),
                Expanded(
                  child: _buildCurrentStep(context, appState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    String title = '';
    if (_currentStep == 1) title = appState.tr('Geofence Setup', 'إعداد السياج الجغرافي');
    if (_currentStep == 2) title = appState.tr('Define Zone', 'تحديد المنطقة');
    if (_currentStep == 3) title = appState.tr('Setup Complete', 'اكتمل الإعداد');

    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final hPad = (w * 0.04).clamp(12.0, 20.0);
    final vPad = (short * 0.018).clamp(6.0, 12.0);
    final titleFs = (w * 0.048).clamp(16.0, 22.0);
    final trail = (w * 0.02).clamp(6.0, 12.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_currentStep > 1 && _currentStep < 3) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleFs,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF273469),
              ),
            ),
          ),
          const LanguageToggle(),
          SizedBox(width: trail),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, AppState appState) {
    switch (_currentStep) {
      case 1:
        return _buildMemberSelection(context, appState);
      case 2:
        return _buildDefineZone(context, appState);
      case 3:
        return _buildSuccess(context, appState);
      default:
        return Container();
    }
  }

  Widget _buildMemberSelection(BuildContext context, AppState appState) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final pad = (w * 0.055).clamp(16.0, 28.0);

    return FutureBuilder<List<PatientProfile>>(
      future: _profilesFuture,
      builder: (context, snapshot) {
        final profiles = snapshot.data ?? _profiles;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            pad,
            pad,
            pad,
            pad + mq.viewInsets.bottom + mq.padding.bottom,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(appState.tr('Member Selection', 'اختيار العضو'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            Text('${appState.tr('Step', 'خطوة')} 1 ${appState.tr('of', 'من')} 3', style: const TextStyle(color: Color(0xFF1B64F2), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.33,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B64F2)),
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 32),
        Text(
          appState.tr('Select a family member', 'اختر فردًا من العائلة'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 12),
        Text(
          appState.tr('Choose the profile you want to monitor with a safe zone perimeter.', 'اختر الملف الشخصي الذي تريد مراقبته بمحيط منطقة آمنة.'),
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 32),
        
        if (snapshot.connectionState == ConnectionState.waiting)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (profiles.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              appState.tr('No profiles found. Add a member first.', 'لا توجد ملفات حالياً. أضف عضواً أولاً.'),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          )
        else
          ...profiles.map((profile) => _buildMemberCard(context, appState, profile)),

        _buildAddMemberCard(context, appState),
        
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _selectedMember != null ? () => setState(() => _currentStep = 2) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B64F2),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: (short * 0.045).clamp(14.0, 20.0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((short * 0.08).clamp(22.0, 32.0)),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  appState.tr('Continue to Map', 'المتابعة إلى الخريطة'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (w * 0.04).clamp(14.0, 17.0),
                  ),
                ),
              ),
              SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
              Icon(Icons.arrow_forward, size: (short * 0.05).clamp(18.0, 22.0)),
            ],
          ),
        ),
          ],
        );
      },
    );
  }

  Widget _buildMemberCard(BuildContext context, AppState appState, PatientProfile profile) {
    final isSelected = _selectedMember?.id == profile.id;
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final avR = (short * 0.078).clamp(24.0, 32.0);
    final cardPad = (short * 0.04).clamp(12.0, 18.0);
    final nameFs = (w * 0.042).clamp(15.0, 18.0);
    final subFs = (w * 0.034).clamp(11.0, 14.0);

    return GestureDetector(
      onTap: () => setState(() {
        _selectedMember = profile;
        _zoneCenter = null;
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: (short * 0.04).clamp(12.0, 18.0)),
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular((short * 0.05).clamp(16.0, 22.0)),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B64F2) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: (short * 0.024).clamp(6.0, 12.0),
              offset: Offset(0, (short * 0.01).clamp(3.0, 6.0)),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avR,
              backgroundImage: profile.avatarUrl.trim().isNotEmpty
                  ? getUserAvatarProvider(profile.avatarUrl)
                  : null,
              child: profile.avatarUrl.trim().isEmpty
                  ? Text(
                      profile.profileName.isNotEmpty
                          ? profile.profileName[0].toUpperCase()
                          : '?',
                      style: TextStyle(fontSize: avR * 0.85, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            SizedBox(width: (w * 0.04).clamp(10.0, 18.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.profileName,
                    style: TextStyle(
                      fontSize: nameFs,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: (short * 0.01).clamp(3.0, 6.0)),
                  Text(
                    profile.status
                        ? appState.tr('Device connected', 'الجهاز متصل')
                        : appState.tr('No connected device yet', 'لا يوجد جهاز متصل بعد'),
                    style: TextStyle(fontSize: subFs, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: const Color(0xFF1B64F2), size: (short * 0.07).clamp(24.0, 30.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberCard(BuildContext context, AppState appState) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProfileIdentityPage()),
        ).then((_) {
          setState(() {
            _profilesFuture = _loadProfiles();
          });
        });
      },
      child: DottedBorderSimulation(
        child: Builder(
          builder: (ctx) {
            final short = MediaQuery.sizeOf(ctx).shortestSide;
            final w = MediaQuery.sizeOf(ctx).width;
            final box = (short * 0.13).clamp(44.0, 56.0);
            final iconSz = (box * 0.44).clamp(20.0, 26.0);
            return Container(
              padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
              child: Row(
                children: [
                  Container(
                    width: box,
                    height: box,
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: Icon(LucideIcons.userPlus, color: const Color(0xFF64748B), size: iconSz),
                  ),
                  SizedBox(width: (w * 0.04).clamp(12.0, 18.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.tr('Add New Member', 'إضافة عضو جديد'),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        Text(
                          appState.tr('Register a new device', 'تسجيل جهاز جديد'),
                          style: TextStyle(fontSize: (w * 0.032).clamp(11.0, 13.0), color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefineZone(BuildContext context, AppState appState) {
    final center = _effectiveZoneCenter();
    final selected = _selectedMember;
    final hasLocation = selected != null && _locations.containsKey(selected.id);
    final mq = MediaQuery.of(context);
    final h = mq.size.height;
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final mapH = (h * 0.30).clamp(200.0, 320.0);
    final listPad = (w * 0.055).clamp(16.0, 28.0);
    final markerExtent = (short * 0.21).clamp(64.0, 96.0);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              listPad,
              listPad,
              listPad,
              listPad + mq.viewInsets.bottom + mq.padding.bottom,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: (short * 0.01).clamp(3.0, 5.0), backgroundColor: const Color(0xFFE5E7EB)),
                    SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
                    CircleAvatar(radius: (short * 0.01).clamp(3.0, 5.0), backgroundColor: const Color(0xFF1B64F2)),
                    SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
                    CircleAvatar(radius: (short * 0.01).clamp(3.0, 5.0), backgroundColor: const Color(0xFFE5E7EB)),
                  ],
                ),
              ),
              SizedBox(height: (short * 0.055).clamp(16.0, 28.0)),
              // Map Preview
              Container(
                height: mapH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((short * 0.06).clamp(18.0, 28.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: (short * 0.05).clamp(12.0, 22.0),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14.5,
                        onTap: (_, point) => setState(() => _zoneCenter = point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.qlink.app',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: center,
                              radius: _radius,
                              useRadiusInMeter: true,
                              color: const Color(0xFF1B64F2).withValues(alpha: 0.15),
                              borderColor: const Color(0xFF1B64F2),
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            if (_selectedMember != null)
                              Marker(
                                point: center,
                                width: markerExtent,
                                height: markerExtent,
                                child: _buildProfileMarker(
                                  context,
                                  name: _selectedMember!.profileName,
                                  imagePath: _selectedMember!.avatarUrl,
                                  hasStatusDot: true,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: (w * 0.03).clamp(8.0, 16.0),
                      top: (w * 0.03).clamp(8.0, 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMapToolButton(context, Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
                          SizedBox(height: (short * 0.02).clamp(6.0, 10.0)),
                          _buildMapToolButton(context, Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
                        ],
                      ),
                    ),
                    Positioned(
                      right: (w * 0.03).clamp(8.0, 16.0),
                      bottom: (w * 0.03).clamp(8.0, 16.0),
                      child: _buildMapToolButton(context, Icons.layers, () {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  appState.tr('Drag the circle to reposition or use the slider below', 'اسحب الدائرة لتغيير موقعها أو استخدم الشريط أدناه'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: (w * 0.03).clamp(10.0, 13.0), color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 16),
              if (selected != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: selected.avatarUrl.trim().isNotEmpty
                            ? getUserAvatarProvider(selected.avatarUrl)
                            : null,
                        child: selected.avatarUrl.trim().isEmpty
                            ? Text(selected.profileName.isNotEmpty ? selected.profileName[0].toUpperCase() : '?')
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.profileName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                            const SizedBox(height: 2),
                            Text(
                              hasLocation
                                  ? _formatLatLng(_selectedMemberCenter())
                                  : appState.tr('No live location yet (using fallback center)', 'لا يوجد موقع حي حالياً (يتم استخدام مركز افتراضي)'),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _recenterToSelectedMember,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: Text(appState.tr('Use member location', 'استخدم موقع العضو')),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
              _buildInputLabel(appState.tr('Zone Name', 'اسم المنطقة')),
              TextField(
                controller: _zoneNameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.home, size: 20, color: Color(0xFF1B64F2)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, color: Color(0xFF1B64F2)),
                            const SizedBox(width: 12),
                            Text(appState.tr('Radius (meters)', 'نطاق المسافة (أمتار)'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          ],
                        ),
                        Text('${_radius.toInt()}m', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B64F2))),
                      ],
                    ),
                    Slider(
                      value: _radius,
                      min: 100,
                      max: 2000,
                      activeColor: const Color(0xFF1B64F2),
                      onChanged: _setRadius,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('100m', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                        Text('2000m', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildRadiusChip('200m', 200),
                        _buildRadiusChip('500m', 500),
                        _buildRadiusChip('1km', 1000),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(LucideIcons.bell, color: Color(0xFF1B64F2)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appState.tr('Entry & Exit Alerts', 'تنبيهات الدخول والخروج'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          Text(appState.tr('Notify when crossing boundary', 'تنبيه عند تجاوز الحدود'), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _alertsEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF3F83F8),
                      onChanged: (v) => setState(() => _alertsEnabled = v),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _selectedMember != null && _zoneNameController.text.trim().isNotEmpty
                    ? () => _goToSuccess(appState)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: (short * 0.045).clamp(14.0, 20.0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular((short * 0.08).clamp(22.0, 32.0)),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.save, size: (short * 0.05).clamp(18.0, 22.0)),
                    SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
                    Flexible(
                      child: Text(
                        appState.tr('Save Zone', 'حفظ المنطقة'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: (w * 0.04).clamp(14.0, 17.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(child: TextButton(onPressed: () => setState(() => _currentStep = 1), child: Text(appState.tr('Cancel and back', 'إلغاء والرجوع'), style: TextStyle(color: Colors.grey.shade500)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context, AppState appState) {
    final center = _selectedMemberCenter();
    final mq = MediaQuery.of(context);
    final h = mq.size.height;
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final pad = (w * 0.055).clamp(16.0, 28.0);
    final previewH = (h * 0.22).clamp(150.0, 240.0);
    final markerExtent = (short * 0.16).clamp(52.0, 72.0);
    final successIcon = (short * 0.18).clamp(52.0, 72.0);
    final titleFs = (w * 0.058).clamp(18.0, 26.0);
    final bodyFs = (w * 0.038).clamp(13.0, 16.0);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        pad,
        pad,
        pad,
        pad + mq.viewInsets.bottom + mq.padding.bottom,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: (short * 0.01).clamp(3.0, 5.0), backgroundColor: const Color(0xFFE5E7EB)),
              SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
              CircleAvatar(radius: (short * 0.01).clamp(3.0, 5.0), backgroundColor: const Color(0xFFE5E7EB)),
              SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
              CircleAvatar(radius: (short * 0.01).clamp(3.0, 5.0), backgroundColor: const Color(0xFF1B64F2)),
            ],
          ),
        ),
        SizedBox(height: (short * 0.12).clamp(32.0, 52.0)),
        Center(
          child: Container(
            padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
            decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: Icon(Icons.check_circle, color: const Color(0xFF059669), size: successIcon),
          ),
        ),
        SizedBox(height: (short * 0.08).clamp(24.0, 36.0)),
        Text(
          appState.tr('Safe Zone Created Successfully!', 'تم إنشاء المنطقة الآمنة بنجاح!'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: titleFs, fontWeight: FontWeight.w900, color: const Color(0xFF1E3A8A)),
        ),
        SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
        Text(
          appState.tr('The tracker will now notify you when the device enters or leaves this area.', 'سيقوم المتتبع الآن بتنبيهك عندما يدخل الجهاز هذا المكان أو يغادره.'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: bodyFs, color: Colors.grey.shade500),
        ),
        SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
        Container(
          height: previewH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((short * 0.05).clamp(16.0, 22.0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: (short * 0.025).clamp(6.0, 12.0)),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Disable movement on success screen
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.qlink.app',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: center,
                    radius: _radius,
                    useRadiusInMeter: true,
                    color: const Color(0xFF1B64F2).withValues(alpha: 0.15),
                    borderColor: const Color(0xFF1B64F2),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (_selectedMember != null)
                    Marker(
                      point: center,
                      width: markerExtent,
                      height: markerExtent,
                      child: _buildProfileMarker(
                        context,
                        name: _selectedMember!.profileName,
                        imagePath: _selectedMember!.avatarUrl,
                        hasStatusDot: true,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
        Text(
          appState.tr('Zone Details', 'تفاصيل المنطقة'),
          style: TextStyle(
            fontSize: (w * 0.045).clamp(16.0, 19.0),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailTile(
          LucideIcons.user,
          appState.tr('Assigned To', 'مخصص لـ'),
          _selectedMember?.profileName ?? appState.tr('No member selected', 'لا يوجد عضو محدد'),
        ),
        _buildDetailTile(LucideIcons.home, appState.tr('Zone Name', 'اسم المنطقة'), _zoneNameController.text),
        _buildDetailTile(LucideIcons.bell, appState.tr('Notifications', 'التنبيهات'), appState.tr('Entry & Exit Alerts Enabled', 'تم تفعيل تنبيهات الدخول والخروج')),
        
        SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B64F2),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: (short * 0.045).clamp(14.0, 20.0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((short * 0.08).clamp(22.0, 32.0)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.map, size: (short * 0.05).clamp(18.0, 22.0)),
              SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
              Flexible(
                child: Text(
                  appState.tr('Back to Map', 'العودة إلى الخريطة'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (w * 0.04).clamp(14.0, 17.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF1B64F2), size: 18),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
    );
  }

  Widget _buildRadiusChip(String label, double value) {
    final isSelected = (_radius - value).abs() < 1;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _setRadius(value),
      selectedColor: const Color(0xFFE0EAFF),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1B64F2) : const Color(0xFF475569),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF1B64F2) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildMapToolButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final side = (short * 0.092).clamp(32.0, 42.0);
    final iconSz = (side * 0.52).clamp(17.0, 22.0);
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
              blurRadius: (short * 0.012).clamp(3.0, 6.0),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E3A8A), size: iconSz),
      ),
    );
  }

  Widget _buildProfileMarker(
    BuildContext context, {
    required String name,
    required String imagePath,
    bool hasStatusDot = false,
  }) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final outer = (short * 0.11).clamp(36.0, 50.0);
    final borderW = (short * 0.005).clamp(1.5, 2.5);
    final innerR = (outer * 0.42).clamp(14.0, 20.0);
    final dot = (short * 0.026).clamp(8.0, 12.0);
    final nameFs = (short * 0.022).clamp(7.0, 10.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: outer,
              height: outer,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: borderW),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: (short * 0.012).clamp(3.0, 6.0)),
                ],
              ),
              child: CircleAvatar(
                radius: innerR,
                backgroundImage: imagePath.trim().isNotEmpty
                    ? getUserAvatarProvider(imagePath)
                    : null,
                child: imagePath.trim().isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: innerR * 0.85,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            if (hasStatusDot)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: (dot * 0.18).clamp(1.5, 2.5)),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: (short * 0.012).clamp(3.0, 6.0),
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular((short * 0.022).clamp(6.0, 10.0)),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: nameFs,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ),
      ],
    );
  }
}

class DottedBorderSimulation extends StatelessWidget {
  final Widget child;
  const DottedBorderSimulation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid), // Simplified dotted
      ),
      child: child,
    );
  }
}
