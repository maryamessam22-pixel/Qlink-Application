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
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(appState),
                Expanded(
                  child: _buildCurrentStep(appState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppState appState) {
    String title = '';
    if (_currentStep == 1) title = appState.tr('Geofence Setup', 'إعداد السياج الجغرافي');
    if (_currentStep == 2) title = appState.tr('Define Zone', 'تحديد المنطقة');
    if (_currentStep == 3) title = appState.tr('Setup Complete', 'اكتمل الإعداد');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF273469),
            ),
          ),
          const Spacer(),
          const LanguageToggle(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(AppState appState) {
    switch (_currentStep) {
      case 1:
        return _buildMemberSelection(appState);
      case 2:
        return _buildDefineZone(appState);
      case 3:
        return _buildSuccess(appState);
      default:
        return Container();
    }
  }

  Widget _buildMemberSelection(AppState appState) {
    return FutureBuilder<List<PatientProfile>>(
      future: _profilesFuture,
      builder: (context, snapshot) {
        final profiles = snapshot.data ?? _profiles;
        return ListView(
          padding: const EdgeInsets.all(24),
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
          ...profiles.map((profile) => _buildMemberCard(appState, profile)),

        _buildAddMemberCard(appState),
        
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _selectedMember != null ? () => setState(() => _currentStep = 2) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B64F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(appState.tr('Continue to Map', 'المتابعة إلى الخريطة'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
          ],
        );
      },
    );
  }

  Widget _buildMemberCard(AppState appState, PatientProfile profile) {
    bool isSelected = _selectedMember?.id == profile.id;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMember = profile;
        _zoneCenter = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B64F2) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: profile.avatarUrl.trim().isNotEmpty
                  ? getUserAvatarProvider(profile.avatarUrl)
                  : null,
              child: profile.avatarUrl.trim().isEmpty
                  ? Text(
                      profile.profileName.isNotEmpty
                          ? profile.profileName[0].toUpperCase()
                          : '?',
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.profileName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 4),
                  Text(
                    profile.status
                        ? appState.tr('Device connected', 'الجهاز متصل')
                        : appState.tr('No connected device yet', 'لا يوجد جهاز متصل بعد'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1B64F2), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberCard(AppState appState) {
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
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: const Icon(LucideIcons.userPlus, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appState.tr('Add New Member', 'إضافة عضو جديد'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  Text(appState.tr('Register a new device', 'تسجيل جهاز جديد'), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefineZone(AppState appState) {
    final center = _effectiveZoneCenter();
    final selected = _selectedMember;
    final hasLocation = selected != null && _locations.containsKey(selected.id);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFFE5E7EB)),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF1B64F2)),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFFE5E7EB)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Map Preview
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 20)],
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
                            // Show ONLY the selected member at the center
                            if (_selectedMember != null)
                              Marker(
                                point: center,
                                width: 80,
                                height: 80,
                                child: _buildProfileMarker(
                                  name: _selectedMember!.profileName,
                                  imagePath: _selectedMember!.avatarUrl,
                                  hasStatusDot: true,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Zoom Controls
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Column(
                        children: [
                          _buildMapToolButton(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
                          const SizedBox(height: 8),
                          _buildMapToolButton(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
                        ],
                      ),
                    ),
                    // Layers Toggle Icon (Static)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _buildMapToolButton(Icons.layers, () {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(appState.tr('Drag the circle to reposition or use the slider below', 'اسحب الدائرة لتغيير موقعها أو استخدم الشريط أدناه'), style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
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
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.save, size: 20),
                    const SizedBox(width: 8),
                    Text(appState.tr('Save Zone', 'حفظ المنطقة'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildSuccess(AppState appState) {
    final center = _selectedMemberCenter();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: Color(0xFFE5E7EB)),
              SizedBox(width: 8),
              CircleAvatar(radius: 4, backgroundColor: Color(0xFFE5E7EB)),
              SizedBox(width: 8),
              CircleAvatar(radius: 4, backgroundColor: Color(0xFF1B64F2)),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Color(0xFF059669), size: 64),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          appState.tr('Safe Zone Created Successfully!', 'تم إنشاء المنطقة الآمنة بنجاح!'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 12),
        Text(
          appState.tr('The tracker will now notify you when the device enters or leaves this area.', 'سيقوم المتتبع الآن بتنبيهك عندما يدخل الجهاز هذا المكان أو يغادره.'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 40),
        
        // Final Preview Map
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
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
                      width: 60,
                      height: 60,
                      child: _buildProfileMarker(
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
        
        const SizedBox(height: 40),
        Text(appState.tr('Zone Details', 'تفاصيل المنطقة'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 16),
        _buildDetailTile(
          LucideIcons.user,
          appState.tr('Assigned To', 'مخصص لـ'),
          _selectedMember?.profileName ?? appState.tr('No member selected', 'لا يوجد عضو محدد'),
        ),
        _buildDetailTile(LucideIcons.home, appState.tr('Zone Name', 'اسم المنطقة'), _zoneNameController.text),
        _buildDetailTile(LucideIcons.bell, appState.tr('Notifications', 'التنبيهات'), appState.tr('Entry & Exit Alerts Enabled', 'تم تفعيل تنبيهات الدخول والخروج')),
        
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B64F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.map, size: 20),
              const SizedBox(width: 8),
              Text(appState.tr('Back to Map', 'العودة إلى الخريطة'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildMapToolButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
        child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
      ),
    );
  }

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: imagePath.trim().isNotEmpty
                    ? getUserAvatarProvider(imagePath)
                    : null,
                child: imagePath.trim().isEmpty
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                    : null,
              ),
            ),
            if (hasStatusDot)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            name,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
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
