import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';

class LinkedDevicesPage extends StatefulWidget {
  const LinkedDevicesPage({super.key});

  @override
  State<LinkedDevicesPage> createState() => _LinkedDevicesPageState();
}

class _LinkedDevicesPageState extends State<LinkedDevicesPage> {
  late Future<List<_LinkedDevice>> _devicesFuture;
  String _searchQuery = '';
  String _typeFilter = 'All';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _devicesFuture = _fetchLinkedDevices();
  }

  Future<List<_LinkedDevice>> _fetchLinkedDevices() async {
    final profiles = await SupabaseService().fetchPatientProfiles();
    final List<_LinkedDevice> devices = [];

    for (final profile in profiles) {
      final localProfile = AppState().profiles.where((p) => p.id == profile.id).toList();

      if (localProfile.isNotEmpty && localProfile.first.devices.isNotEmpty) {
        for (final device in localProfile.first.devices) {
          devices.add(_LinkedDevice(
            name: _getDeviceName(device.deviceType, device.code),
            type: device.deviceType,
            linkedProfile: profile.profileName,
            profileAvatar: profile.avatarUrl,
            isActive: device.isConnected,
            batteryLevel: device.batteryLevel,
            profileId: profile.id,
          ));
        }
      } else if (profile.status) {
        devices.add(_LinkedDevice(
          name: 'Qlink Bracelet',
          type: 'Qlink Bracelet',
          linkedProfile: profile.profileName,
          profileAvatar: profile.avatarUrl,
          isActive: true,
          batteryLevel: 85,
          profileId: profile.id,
        ));
      }
    }
    return devices;
  }

  String _getDeviceName(String type, String code) {
    final shortCode = code.length > 4 ? code.substring(code.length - 4) : code;
    return '$type #$shortCode';
  }

  List<_LinkedDevice> _applyFilters(List<_LinkedDevice> devices) {
    return devices.where((d) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!d.name.toLowerCase().contains(q) &&
            !d.linkedProfile.toLowerCase().contains(q) &&
            !d.type.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_typeFilter != 'All' && d.type != _typeFilter) return false;
      if (_statusFilter == 'Active' && !d.isActive) return false;
      if (_statusFilter == 'Inactive' && d.isActive) return false;
      return true;
    }).toList();
  }

  void _refresh() {
    setState(() {
      _devicesFuture = _fetchLinkedDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<_LinkedDevice>>(
                future: _devicesFuture,
                builder: (context, snapshot) {
                  final allDevices = snapshot.data ?? [];
                  final devices = _applyFilters(allDevices);
                  final activeCount = allDevices.where((d) => d.isActive).length;
                  final avgBattery = allDevices.isEmpty
                      ? 0
                      : (allDevices.fold<int>(0, (s, d) => s + d.batteryLevel) / allDevices.length).round();

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(appState),
                              const SizedBox(height: 8),
                              Text(
                                appState.tr(
                                  '$activeCount active of ${allDevices.length} · avg battery $avgBattery%',
                                  '$activeCount نشط من ${allDevices.length} · متوسط البطارية $avgBattery%',
                                ),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              _buildTitle(appState),
                              const SizedBox(height: 16),
                              _buildStatsRow(appState, allDevices.length, activeCount, avgBattery),
                              const SizedBox(height: 20),
                              _buildSearchAndFilters(appState, allDevices),
                              const SizedBox(height: 16),
                              _buildTableHeader(appState),
                            ],
                          ),
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (devices.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.watch, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  appState.tr('No devices found', 'لا توجد أجهزة'),
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final device = devices[index];
                                return _buildDeviceRow(appState, device, index == devices.length - 1);
                              },
                              childCount: devices.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  );
                },
              ),
            ),
            const BottomNavWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 4),
              Text(appState.tr('Back', 'رجوع'),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            ],
          ),
        ),
        const Spacer(),
        const LanguageToggle(),
      ],
    );
  }

  Widget _buildTitle(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Manage Devices', 'إدارة الأجهزة'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 4),
        Text(
          appState.tr(
            'Manage all connected devices and their status',
            'إدارة جميع الأجهزة المتصلة وحالتها',
          ),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsRow(AppState appState, int total, int active, int avgBattery) {
    return Row(
      children: [
        _buildStatCard(
          icon: LucideIcons.watch,
          label: appState.tr('Total', 'الإجمالي'),
          value: '$total',
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: LucideIcons.activity,
          label: appState.tr('Active', 'نشط'),
          value: '$active',
          color: const Color(0xFF22C55E),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: LucideIcons.battery,
          label: appState.tr('Avg Battery', 'متوسط البطارية'),
          value: '$avgBattery%',
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(AppState appState, List<_LinkedDevice> allDevices) {
    final types = {'All', ...allDevices.map((d) => d.type)}.toList();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: appState.tr('Search devices...', 'بحث عن أجهزة...'),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFilterDropdown(appState.tr('All types', 'كل الأنواع'), types, _typeFilter, (v) {
              setState(() => _typeFilter = v ?? 'All');
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildFilterDropdown(appState.tr('All status', 'كل الحالات'),
                ['All', 'Active', 'Inactive'], _statusFilter, (v) {
              setState(() => _statusFilter = v ?? 'All');
            })),
            const SizedBox(width: 12),
            Text(
              appState.tr(
                'Showing ${_applyFilters(allDevices).length} of ${allDevices.length}',
                'عرض ${_applyFilters(allDevices).length} من ${allDevices.length}',
              ),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String hint, List<String> items, String current, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTableHeader(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF273469),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(appState.tr('Device Name', 'اسم الجهاز'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(appState.tr('Type', 'النوع'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(appState.tr('Linked Profile', 'الملف المرتبط'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(appState.tr('Status', 'الحالة'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(appState.tr('Battery', 'البطارية'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text(appState.tr('Actions', 'إجراءات'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildDeviceRow(AppState appState, _LinkedDevice device, bool isLast) {
    final statusColor = device.isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final batteryColor = device.batteryLevel > 50
        ? const Color(0xFF22C55E)
        : device.batteryLevel > 20
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(12)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.watch, size: 18, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(device.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: device.type.contains('Apple')
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                device.type.contains('Apple')
                    ? appState.tr('Apple Watch', 'ساعة أبل')
                    : appState.tr('Qlink Bracelet', 'سوار كيو لينك'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: device.type.contains('Apple')
                      ? const Color(0xFF0369A1)
                      : const Color(0xFF15803D),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(device.linkedProfile,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                SizedBox(
                  width: 36, height: 20,
                  child: Switch(
                    value: device.isActive,
                    onChanged: (v) async {
                      if (device.profileId.isNotEmpty) {
                        await SupabaseService().client
                            .from('patient_profiles')
                            .update({'status': v}).eq('id', device.profileId);
                        AppState().markProfilesDirty();
                        _refresh();
                      }
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF22C55E),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  device.isActive
                      ? appState.tr('Active', 'نشط')
                      : appState.tr('Inactive', 'غير نشط'),
                  style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(LucideIcons.battery, size: 14, color: batteryColor),
                const SizedBox(width: 4),
                Text('${device.batteryLevel}%',
                    style: TextStyle(fontSize: 12, color: batteryColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                final newStatus = !device.isActive;
                if (device.profileId.isNotEmpty) {
                  await SupabaseService().client
                      .from('patient_profiles')
                      .update({'status': newStatus}).eq('id', device.profileId);
                  AppState().markProfilesDirty();
                  _refresh();
                }
              },
              child: Text(
                device.isActive
                    ? appState.tr('Disconnect', 'قطع الاتصال')
                    : appState.tr('Connect', 'اتصال'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: device.isActive ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedDevice {
  final String name;
  final String type;
  final String linkedProfile;
  final String profileAvatar;
  final bool isActive;
  final int batteryLevel;
  final String profileId;

  _LinkedDevice({
    required this.name,
    required this.type,
    required this.linkedProfile,
    required this.profileAvatar,
    required this.isActive,
    required this.batteryLevel,
    required this.profileId,
  });
}
