import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/core/utils/emergency_profile_parse.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:q_link/features/guardian/profile/add_profile_identity.dart';
import 'package:q_link/features/guardian/profile/connect_device_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/profile/profile_management_page.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart';
import 'package:q_link/features/wearer/profile/presentation/pages/wearer_identity_page.dart';
import 'package:q_link/features/guardian/map/map_page.dart';
import 'package:q_link/features/guardian/profile/quick_create_wearer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PatientProfile>> _profilesFuture;
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  late Future<Map<String, Map<String, double>>> _locationsFuture;
  bool _sendingLinkRequest = false;

  @override
  void initState() {
    super.initState();
    _profilesFuture = SupabaseService().fetchPatientProfiles();
    _notificationsFuture = _fetchGuardianNotifications();
    _locationsFuture = SupabaseService().fetchLatestProfileLocations();
    AppState().addListener(_checkProfileRefresh);
  }

  @override
  void dispose() {
    AppState().removeListener(_checkProfileRefresh);
    super.dispose();
  }

  void _checkProfileRefresh() {
    if (AppState().profilesDirty) {
      AppState().clearProfilesDirty();
      _refreshProfiles();
    }
  }

  void _refreshProfiles() {
    setState(() {
      _profilesFuture = SupabaseService().fetchPatientProfiles();
      _notificationsFuture = _fetchGuardianNotifications();
      _locationsFuture = SupabaseService().fetchLatestProfileLocations();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchGuardianNotifications() async {
    final guardianId = SupabaseService().client.auth.currentUser?.id;
    if (guardianId == null) return [];

    final rows = await SupabaseService()
        .client
        .from('notifications')
        .select('title, body, created_at, type')
        .eq('guardian_id', guardianId)
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<void> _showLinkExistingWearerDialog() async {
    final appState = AppState();
    final controller = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final kb = MediaQuery.viewInsetsOf(context).bottom;
            return AlertDialog(
              title: Text(
                appState.tr('Link Existing Wearer', 'ربط مستخدم Wearer موجود'),
              ),
              content: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: kb),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appState.tr(
                        'Enter wearer account email to send a link request.',
                        'أدخل بريد حساب الـ Wearer لإرسال طلب الربط.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: appState.tr(
                          'wearer@email.com',
                          'wearer@email.com',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _sendingLinkRequest
                      ? null
                      : () => Navigator.pop(dialogCtx),
                  child: Text(appState.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  onPressed: _sendingLinkRequest
                      ? null
                      : () async {
                          final email = controller.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  appState.tr(
                                    'Enter a valid email.',
                                    'أدخل بريداً صحيحاً.',
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          final dialogNavigator = Navigator.of(dialogCtx);
                          setState(() => _sendingLinkRequest = true);
                          setDialogState(() {});
                          try {
                            await SupabaseService()
                                .sendWearerLinkRequestByEmail(email);
                            if (mounted) {
                              dialogNavigator.pop();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appState.tr(
                                      'Request sent successfully.',
                                      'تم إرسال الطلب بنجاح.',
                                    ),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _sendingLinkRequest = false);
                              setDialogState(() {});
                            }
                          }
                        },
                  child: _sendingLinkRequest
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(appState.tr('Send Request', 'إرسال الطلب')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToConnectBracelet(List<PatientProfile> profiles) async {
    final navigator = Navigator.of(context);
    if (profiles.length == 1) {
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ConnectDevicePage(
            targetProfileIndex: 0,
            targetProfileId: profiles[0].id,
          ),
        ),
      );
      return;
    }

    final availableProfileIndices = profiles
        .asMap()
        .entries
        .where((entry) => !entry.value.status)
        .map((entry) => entry.key)
        .toList();
    int selectedIndex = availableProfileIndices.isNotEmpty
        ? availableProfileIndices.first
        : 0;
    final chosenProfileIndex = await showDialog<int>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final selectedProfile = profiles[selectedIndex];
            final hasSelectedBracelet = selectedProfile.status;
            return AlertDialog(
              title: Text(AppState().tr('Select profile', 'اختر الملف الشخصي')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (availableProfileIndices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          AppState().tr(
                            'All profiles already have linked bracelets.',
                            'جميع الملفات الشخصية لديها أساور مرتبطة بالفعل.',
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ...profiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final profile = entry.value;
                      final hasBracelet = profile.status;
                      return RadioListTile<int>(
                        value: index,
                        groupValue: selectedIndex,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.profileName,
                                style: TextStyle(
                                  color: hasBracelet
                                      ? Colors.grey.shade500
                                      : Colors.black,
                                ),
                              ),
                            ),
                            if (hasBracelet) ...[
                              const SizedBox(width: 8),
                              Text(
                                AppState().tr('Already linked', 'مرتبط بالفعل'),
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(profile.relationshipToGuardian),
                        onChanged: hasBracelet
                            ? null
                            : (value) {
                                setState(() {
                                  selectedIndex = value ?? selectedIndex;
                                });
                              },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(AppState().tr('Cancel', 'إلغاء')),
                ),
                TextButton(
                  onPressed: hasSelectedBracelet
                      ? null
                      : () {
                          Navigator.pop(dialogCtx, selectedIndex);
                        },
                  child: Text(AppState().tr('Connect', 'ربط')),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || chosenProfileIndex == null) {
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ConnectDevicePage(
          targetProfileIndex: chosenProfileIndex,
          targetProfileId: profiles[chosenProfileIndex].id,
        ),
      ),
    );
  }

  Widget _buildInitials(String name, double fontSize) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, PatientProfile profile) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final side = (short * 0.15).clamp(48.0, 68.0);
    final initialsFs = (side * 0.38).clamp(17.0, 26.0);
    final url = profile.avatarUrl;
    if (url.isEmpty) return _buildInitials(profile.profileName, initialsFs);

    if (url.startsWith('assets')) {
      return SizedBox(
        width: side,
        height: side,
        child: Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildInitials(profile.profileName, initialsFs),
        ),
      );
    }

    return SizedBox(
      width: side,
      height: side,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildInitials(profile.profileName, initialsFs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: AnimatedBuilder(
          animation: AppState(),
          builder: (context, _) {
            final mq = MediaQuery.of(context);
            final w = mq.size.width;
            final short = mq.size.shortestSide;
            final hPad = (w * 0.05).clamp(16.0, 24.0);
            final vPad = (short * 0.035).clamp(12.0, 20.0);
            final scrollBottom =
                mq.viewInsets.bottom +
                mq.padding.bottom +
                (short * 0.06).clamp(18.0, 28.0);
            final welcomeFs = (w * 0.058).clamp(18.0, 26.0);
            final taglineFs = (w * 0.036).clamp(12.0, 15.0);
            final cardPad = (short * 0.04).clamp(12.0, 18.0);
            final cardRadius = (short * 0.04).clamp(14.0, 18.0);
            final statNumFs = (w * 0.058).clamp(20.0, 26.0);
            final statLabelFs = (w * 0.034).clamp(11.0, 14.0);

            return SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, scrollBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HeaderWidget(),
                    FutureBuilder<List<PatientProfile>>(
                      future: _profilesFuture,
                      builder: (context, snapshot) {
                        final appState = AppState();
                        final profiles = snapshot.data ?? [];
                        final actualProfileCount = profiles.length;
                        final activeDeviceCount = profiles
                            .where((p) => p.status)
                            .length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              appState.tr(
                                'Hello, ${appState.currentUser.name}',
                                'مرحباً، ${appState.currentUser.name}',
                              ),
                              style: TextStyle(
                                fontSize: welcomeFs,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                            SizedBox(height: (short * 0.015).clamp(4.0, 8.0)),
                            Text(
                              appState.tr(
                                'Your Safety Circle Command Center',
                                'مركز قيادة دائرة الأمان الخاصة بك',
                              ),
                              style: TextStyle(
                                fontSize: taglineFs,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(cardPad),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F0FE),
                                      borderRadius: BorderRadius.circular(
                                        cardRadius,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Icon(
                                              Icons.devices_outlined,
                                              color: Color(0xFF1B64F2),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (activeDeviceCount > 0
                                                            ? const Color(
                                                                0xFF0E9F6E,
                                                              )
                                                            : const Color(
                                                                0xFFD1D5DB,
                                                              ))
                                                        .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                appState.tr(
                                                  activeDeviceCount > 0
                                                      ? 'ONLINE'
                                                      : 'OFFLINE',
                                                  activeDeviceCount > 0
                                                      ? 'متصل'
                                                      : 'غير متصل',
                                                ),
                                                style: TextStyle(
                                                  fontSize: (w * 0.026).clamp(
                                                    9.0,
                                                    11.0,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                  color: activeDeviceCount > 0
                                                      ? Colors.white
                                                      : const Color(0xFF4B5563),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: (short * 0.04).clamp(
                                            12.0,
                                            18.0,
                                          ),
                                        ),
                                        Text(
                                          '$activeDeviceCount',
                                          style: TextStyle(
                                            fontSize: statNumFs,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B64F2),
                                          ),
                                        ),
                                        Text(
                                          appState.tr(
                                            'Active Devices',
                                            'أجهزة نشطة',
                                          ),
                                          style: TextStyle(
                                            fontSize: statLabelFs,
                                            color: const Color(0xFF1B64F2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: (w * 0.04).clamp(12.0, 18.0)),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(cardPad),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2F8EE),
                                      borderRadius: BorderRadius.circular(
                                        cardRadius,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.group_outlined,
                                              color: Color(0xFF0E9F6E),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: (short * 0.04).clamp(
                                            12.0,
                                            18.0,
                                          ),
                                        ),
                                        Text(
                                          '$actualProfileCount',
                                          style: TextStyle(
                                            fontSize: statNumFs,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0E9F6E),
                                          ),
                                        ),
                                        Text(
                                          appState.tr(
                                            'Protected Members',
                                            'الأعضاء المحميون',
                                          ),
                                          style: TextStyle(
                                            fontSize: statLabelFs,
                                            color: const Color(0xFF0E9F6E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: (short * 0.05).clamp(16.0, 24.0)),
                            Container(
                              padding: EdgeInsets.all(cardPad),
                              decoration: BoxDecoration(
                                color: activeDeviceCount > 0
                                    ? const Color(0xFFDEF7EC)
                                    : const Color(0xFFEAF8F0),
                                border: Border.all(
                                  color: activeDeviceCount > 0
                                      ? const Color(0xFF84E1BC)
                                      : const Color(0xFFB4E6C9),
                                ),
                                borderRadius: BorderRadius.circular(
                                  (short * 0.032).clamp(10.0, 14.0),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: (short * 0.055).clamp(20.0, 26.0),
                                    color: activeDeviceCount > 0
                                        ? const Color(0xFF0E9F6E)
                                        : const Color(0xFF0E9F6E),
                                  ),
                                  SizedBox(width: (w * 0.03).clamp(8.0, 14.0)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appState.tr(
                                            'System Status',
                                            'حالة النظام',
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0E9F6E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          activeDeviceCount > 0
                                              ? appState.tr(
                                                  'System fully active. $activeDeviceCount device(s) linked.',
                                                  'النظام يعمل بالكامل. $activeDeviceCount جهاز متصل.',
                                                )
                                              : appState.tr(
                                                  'No devices connected till now. No alerts detected.',
                                                  'لا توجد أجهزة متصلة حتى الآن. لم يتم رصد أي تنبيهات.',
                                                ),
                                          style: TextStyle(
                                            fontSize: statLabelFs,
                                            color: Colors.grey.shade700,
                                          ),
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
                    SizedBox(height: (short * 0.06).clamp(20.0, 28.0)),
                    FutureBuilder<List<PatientProfile>>(
                      future: _profilesFuture,
                      builder: (context, snapshot) {
                        final appState = AppState();
                        final profiles = snapshot.data ?? [];
                        if (profiles.isEmpty &&
                            snapshot.connectionState !=
                                ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    appState.tr(
                                      'Protected Member',
                                      'العضو المحمي',
                                    ),
                                    style: TextStyle(
                                      fontSize: (w * 0.045).clamp(16.0, 19.0),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddProfileIdentityPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    appState.tr('+ Add Member', '+ إضافة عضو'),
                                    style: const TextStyle(
                                      color: Color(0xFF1B64F2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: (short * 0.03).clamp(10.0, 14.0)),
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const Center(child: CircularProgressIndicator())
                            else
                              ...profiles.asMap().entries.map((entry) {
                                return _buildProtectedMemberCard(
                                  context,
                                  entry.key,
                                  entry.value,
                                );
                              }),
                            SizedBox(height: (short * 0.06).clamp(18.0, 28.0)),
                          ],
                        );
                      },
                    ),

                    // Create Profile Card (only when there are no profiles yet)
                    FutureBuilder<List<PatientProfile>>(
                      future: _profilesFuture,
                      builder: (context, snapshot) {
                        final profiles = snapshot.data ?? [];
                        final loading =
                            snapshot.connectionState == ConnectionState.waiting;
                        if (loading || profiles.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0E9F6E),
                                    Color(0xFF046C4E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppState().tr(
                                      'Create a Profile',
                                      'إنشاء ملف تعريف',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppState().tr(
                                      'Create a medical ID for a loved one to activate their emergency QR protection immediately.',
                                      'أنشئ بطاقة معرف طبية لأحد أحبائك لتفعيل الحماية الطارئة QR فوراً.',
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AddProfileIdentityPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_box,
                                            color: Color(0xFF0E9F6E),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppState().tr(
                                              'Add Profile',
                                              'إضافة الملف ',
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF0E9F6E),
                                              fontWeight: FontWeight.bold,
                                            ),
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

                    // Connect Bracelet Card (uses Supabase profile list — AppState.profileCount can be out of sync)
                    FutureBuilder<List<PatientProfile>>(
                      future: _profilesFuture,
                      builder: (context, snapshot) {
                        return AnimatedBuilder(
                          animation: AppState(),
                          builder: (context, _) {
                            final appState = AppState();
                            final profiles = snapshot.data ?? [];
                            final loading =
                                snapshot.connectionState ==
                                ConnectionState.waiting;

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4285F4),
                                    Color(0xFF273469),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.tr(
                                      'Connect a Bracelet',
                                      'توصيل سوار',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appState.tr(
                                      'Pair a Qlink bracelet to start protecting your loved ones in real time and expand your safety circle.',
                                      'قم بإقران سوار كيولينك للبدء في حماية أحبائك في الوقت الفعلي وتوسيع دائرة الأمان.',
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      if (loading) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              appState.tr(
                                                'Loading profiles…',
                                                'جاري تحميل الملفات…',
                                              ),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (profiles.isEmpty) {
                                        showDialog<void>(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: Text(
                                              appState.tr(
                                                'Profile Required',
                                                'مطلوب ملف تعريف',
                                              ),
                                            ),
                                            content: Text(
                                              appState.tr(
                                                'Please create a wearer profile before linking a new hardware device.',
                                                'يرجى إنشاء ملف تعريف للمرافق قبل ربط جهاز جديد.',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                                child: Text(
                                                  appState.tr(
                                                    'Cancel',
                                                    'إلغاء',
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const AddProfileIdentityPage(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  appState.tr(
                                                    'Create Profile',
                                                    'إنشاء ملف تعريف',
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      _navigateToConnectBracelet(profiles);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add,
                                            color: Color(0xFF273469),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            appState.tr(
                                              'Add Bracelet',
                                              'إضافة سوار',
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF273469),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Add / Link Wearer
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7E22CE), Color(0xFF5B21B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppState().tr(
                              'Add a Wearer',
                              'إضافة مستخدم Wearer',
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppState().tr(
                              'Create a new wearer account or link an existing one to your safety circle.',
                              'أنشئ حساب Wearer جديداً أو اربط حساباً موجوداً بدائرة الأمان الخاصة بك.',
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QuickCreateWearerPage(),
                                ),
                              ).then((_) {
                                _refreshProfiles();
                              });
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
                                  const Icon(
                                    Icons.person_add_alt_1,
                                    color: Color(0xFF6D28D9),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppState().tr(
                                      'Add New Wearer',
                                      'إضافة Wearer جديد',
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF6D28D9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton.icon(
                              onPressed: _sendingLinkRequest
                                  ? null
                                  : _showLinkExistingWearerDialog,
                              icon: const Icon(Icons.link, size: 18),
                              label: Text(
                                AppState().tr(
                                  'Link Existing Wearer',
                                  'ربط Wearer موجود',
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Activity Section
                    FutureBuilder<List<PatientProfile>>(
                      future: _profilesFuture,
                      builder: (context, snapshot) {
                        final appState = AppState();
                        final profiles = snapshot.data ?? [];
                        final hasActiveDevice = profiles.any((p) => p.status);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    appState.tr(
                                      'Recent Activity',
                                      'النشاط الأخير',
                                    ),
                                    style: TextStyle(
                                      fontSize: (w * 0.045).clamp(16.0, 19.0),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    hasActiveDevice
                                        ? appState.tr('View All', 'عرض الكل')
                                        : appState.tr('See all', 'عرض الكل'),
                                    style: TextStyle(
                                      color: hasActiveDevice
                                          ? const Color(0xFF1B64F2)
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const Center(child: CircularProgressIndicator())
                            else if (!hasActiveDevice)
                              _buildEmptyActivity(context)
                            else
                              _buildRealActivity(
                                context,
                                profiles,
                                _notificationsFuture,
                                _locationsFuture,
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: (short * 0.05).clamp(16.0, 28.0)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteProfileConfirm(
    BuildContext context,
    int index,
    PatientProfile profile,
  ) {
    final appState = AppState();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(appState.tr('Delete Profile', 'حذف الملف الشخصي')),
        content: Text(
          appState.tr(
            'Are you sure you want to delete ${profile.profileName}? This action cannot be undone.',
            'هل أنت متأكد أنك تريد حذف ${profile.profileName}؟ لا يمكن التراجع عن هذا الإجراء.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(appState.tr('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () async {
              if (profile.id.isNotEmpty) {
                try {
                  await SupabaseService().client
                      .from('devices')
                      .delete()
                      .eq('profile_id', profile.id);
                  await SupabaseService().client
                      .from('bracelets')
                      .delete()
                      .eq('assigned_profile_id', profile.id);
                  await SupabaseService().client
                      .from('patient_profiles')
                      .delete()
                      .eq('id', profile.id);
                } catch (e) {
                  debugPrint('Error deleting profile: $e');
                }
              }
              AppState().markProfilesDirty();
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: Text(
              appState.tr('Delete', 'حذف'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectedMemberCard(
    BuildContext context,
    int index,
    PatientProfile profile,
  ) {
    final appState = AppState();
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final avatarOuter = (short * 0.15).clamp(52.0, 68.0);
    final cardPad = (short * 0.048).clamp(14.0, 22.0);
    final nameFs = (w * 0.045).clamp(15.0, 19.0);
    final marginB = (short * 0.04).clamp(12.0, 18.0);

    return Container(
      margin: EdgeInsets.only(bottom: marginB),
      padding: EdgeInsets.all(cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((short * 0.04).clamp(14.0, 18.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: (short * 0.025).clamp(8.0, 12.0),
            offset: Offset(0, (short * 0.012).clamp(3.0, 6.0)),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: avatarOuter,
                height: avatarOuter,
                decoration: BoxDecoration(
                  color: const Color(0xFF273469),
                  borderRadius: BorderRadius.circular(
                    (short * 0.032).clamp(10.0, 14.0),
                  ),
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    (short * 0.032).clamp(10.0, 14.0),
                  ),
                  child: _buildProfileAvatar(context, profile),
                ),
              ),
              SizedBox(width: (w * 0.04).clamp(10.0, 18.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.profileName,
                            style: TextStyle(
                              fontSize: nameFs,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        if (profile.status) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.circle,
                            color: Color(0xFF0E9F6E),
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appState.tr('Active', 'نشط'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.tr(
                        profile.relationshipToGuardian,
                        profile.relationshipToGuardian,
                      ),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showDeleteProfileConfirm(context, index, profile),
                child: Container(
                  padding: EdgeInsets.all((short * 0.016).clamp(4.0, 8.0)),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: (short * 0.055).clamp(18.0, 24.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (short * 0.05).clamp(14.0, 22.0)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to profile management - passing converted data for now
                    final dialRows = emergencyDialRowsFromContactsJson(
                      profile.emergencyContacts,
                    );
                    final List<String> emergencyContactsList = [];
                    if (dialRows.isNotEmpty) {
                      for (final d in dialRows) {
                        if (d.phone.isNotEmpty) {
                          emergencyContactsList.add(
                            d.title.isNotEmpty
                                ? '${d.title}\n${d.phone}'
                                : d.phone,
                          );
                        } else if (d.title.isNotEmpty) {
                          emergencyContactsList.add(d.title);
                        }
                      }
                    } else if (profile.emergencyContacts.isNotEmpty) {
                      profile.emergencyContacts.forEach((key, value) {
                        if (value is Map && value.containsKey('name')) {
                          emergencyContactsList.add(value['name'].toString());
                        }
                      });
                    }

                    // Find matching devices from AppState by profile ID
                    List<DeviceData> matchedDevices = [];
                    for (var appProfile in AppState().profiles) {
                      if (appProfile.id == profile.id) {
                        matchedDevices = List.from(appProfile.devices);
                        break;
                      }
                    }

                    // If Supabase says device connected (status=true) but no local devices, create placeholder
                    if (matchedDevices.isEmpty && profile.status) {
                      matchedDevices = [
                        DeviceData(
                          deviceType: 'Qlink Smart Bracelet "Pulse"',
                          code:
                              'QLINK-PULSE-${profile.id.substring(0, 6).toUpperCase()}',
                          connectedAt: profile.createdAt,
                        ),
                      ];
                    }

                    VisibilitySettings? mergedVisibility;
                    final cachedVis = AppState().qrVisibilitySettingsFor(
                      profile.id,
                    );
                    if (cachedVis != null) {
                      mergedVisibility = VisibilitySettings.copyOf(cachedVis);
                    } else {
                      for (final ap in AppState().profiles) {
                        if (ap.id != null &&
                            ap.id!.isNotEmpty &&
                            ap.id == profile.id) {
                          mergedVisibility = VisibilitySettings.copyOf(
                            ap.visibility,
                          );
                          break;
                        }
                      }
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileManagementPage(
                          profileIndex: index,
                          profile: ProfileData(
                            id: profile.id,
                            name: profile.profileName,
                            imagePath: profile.avatarUrl,
                            relationship: profile.relationshipToGuardian,
                            birthYear: birthYearStringFromRowField(
                              profile.birthYear,
                            ),
                            bloodType: profile.bloodType,
                            condition: profile.medicalNotesEn,
                            allergies: profile.allergiesEn,
                            emergencyContacts: emergencyContactsList,
                            emergencyDialRows: dialRows,
                            devices: matchedDevices,
                            visibility: mergedVisibility,
                          ),
                        ),
                      ),
                    ).then((result) {
                      // Re-fetch from Supabase when profile was edited or deleted
                      if (result == true) {
                        _refreshProfiles();
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: (short * 0.032).clamp(10.0, 14.0),
                    ),
                    side: const BorderSide(color: Color(0xFFF3F4F6)),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        (short * 0.022).clamp(6.0, 10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    AppState().tr('View Profile', 'عرض الملف'),
                    style: TextStyle(
                      fontSize: (w * 0.032).clamp(11.0, 14.0),
                      color: const Color(0xFF1B64F2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: (w * 0.03).clamp(8.0, 14.0)),
              Expanded(
                child: profile.status
                    ? OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.purple,
                          size: (short * 0.048).clamp(16.0, 20.0),
                        ),
                        label: Text(
                          AppState().tr('Added Device', 'جهاز مضاف'),
                          style: TextStyle(
                            fontSize: (w * 0.032).clamp(11.0, 14.0),
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: (short * 0.032).clamp(10.0, 14.0),
                          ),
                          side: BorderSide(
                            color: Colors.purple.withValues(alpha: 0.1),
                          ),
                          backgroundColor: Colors.purple.withValues(
                            alpha: 0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              (short * 0.022).clamp(6.0, 10.0),
                            ),
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectDevicePage(
                                targetProfileIndex: index,
                                targetProfileId: profile.id,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: (short * 0.032).clamp(10.0, 14.0),
                          ),
                          side: BorderSide(
                            color: Colors.purple.withValues(alpha: 0.1),
                          ),
                          backgroundColor: Colors.purple.withValues(
                            alpha: 0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              (short * 0.022).clamp(6.0, 10.0),
                            ),
                          ),
                        ),
                        child: Text(
                          AppState().tr('+ Add Device', '+ إضافة جهاز'),
                          style: TextStyle(
                            fontSize: (w * 0.032).clamp(11.0, 14.0),
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
          Row(
            children: [
              Text(
                appState.tr('Last update: Today', 'آخر تحديث: اليوم'),
                style: TextStyle(
                  fontSize: (w * 0.028).clamp(10.0, 12.0),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final vPad = (short * 0.11).clamp(28.0, 48.0);
    final iconSz = (short * 0.1).clamp(32.0, 44.0);

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: Colors.grey.shade300,
        strokeWidth: 1.5,
        dashPattern: const [8, 4],
        radius: Radius.circular((short * 0.032).clamp(10.0, 14.0)),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: iconSz, color: Colors.grey.shade400),
            SizedBox(height: (short * 0.03).clamp(8.0, 14.0)),
            Text(
              AppState().tr('No activity yet', 'لا يوجد نشاط بعد'),
              style: TextStyle(
                fontSize: (MediaQuery.sizeOf(context).width * 0.034).clamp(
                  12.0,
                  14.0,
                ),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealActivity(
    BuildContext context,
    List<PatientProfile> profiles,
    Future<List<Map<String, dynamic>>> notificationsFuture,
    Future<Map<String, Map<String, double>>> locationsFuture,
  ) {
    final firstName = profiles.isNotEmpty ? profiles.first.profileName : '-';
    final appState = AppState();
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final bannerH = (mq.size.height * 0.19).clamp(120.0, 200.0);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: notificationsFuture,
      builder: (context, notiSnap) {
        final notifications = notiSnap.data ?? const <Map<String, dynamic>>[];

        List<Widget> activityWidgets = [];
        if (notiSnap.connectionState == ConnectionState.waiting) {
          activityWidgets.add(
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (notifications.isEmpty) {
          activityWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                appState.tr('No recent notifications', 'لا توجد إشعارات حديثة'),
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          for (int i = 0; i < notifications.length && i < 3; i++) {
            final n = notifications[i];
            final type = (n['type'] ?? '').toString();
            final nTitle = (n['title'] ?? '').toString();
            final nBody = (n['body'] ?? '').toString();
            final createdAt = n['created_at'];

            DateTime? timeDate;
            if (createdAt != null) {
              timeDate = DateTime.tryParse(createdAt.toString());
            }

            String timeStr = '';
            if (timeDate != null) {
              final now = DateTime.now();
              final diff = now.difference(timeDate);
              if (diff.inDays > 0) {
                timeStr = appState.tr(
                  '${diff.inDays}d ago',
                  'منذ ${diff.inDays} يوم',
                );
              } else if (diff.inHours > 0) {
                timeStr = appState.tr(
                  '${diff.inHours}h ago',
                  'منذ ${diff.inHours} ساعة',
                );
              } else if (diff.inMinutes > 0) {
                timeStr = appState.tr(
                  '${diff.inMinutes}m ago',
                  'منذ ${diff.inMinutes} دقيقة',
                );
              } else {
                timeStr = appState.tr('Just now', 'الآن');
              }
            }

            IconData iconData = Icons.notifications_none;
            Color iconColor = const Color(0xFF1B64F2);
            String headerTitle = appState.tr('Alert', 'تنبيه');

            if (type == 'qr_scan' || type == 'emergency') {
              iconData = Icons.error_outline;
              iconColor = Colors.red;
              headerTitle = appState.tr('Emergency', 'طوارئ');
            } else if (type == 'zone_entry' ||
                type == 'safe_zone' ||
                type == 'zone_exit') {
              iconData = Icons.location_on_outlined;
              iconColor = Colors.green;
              headerTitle = appState.tr('Location', 'الموقع');
            } else if (type == 'device_status') {
              iconData = Icons.battery_alert;
              iconColor = Colors.orange;
              headerTitle = appState.tr('Device', 'الجهاز');
            } else if (type == 'link_request') {
              iconData = Icons.link;
              iconColor = Colors.purple;
              headerTitle = appState.tr('Request', 'طلب');
            }

            activityWidgets.add(
              _buildActivityRow(
                context,
                icon: iconData,
                color: iconColor,
                title: headerTitle,
                subtitle: nTitle.isNotEmpty ? nTitle : headerTitle,
                details: nBody,
                time: timeStr,
              ),
            );

            if (i < notifications.length - 1 && i < 2) {
              activityWidgets.add(
                SizedBox(height: (short * 0.03).clamp(10.0, 14.0)),
              );
            }
          }
        }

        return Column(
          children: [
            ...activityWidgets,
            SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<Map<String, Map<String, double>>>(
                future: locationsFuture,
                builder: (context, locSnap) {
                  final locations =
                      locSnap.data ?? const <String, Map<String, double>>{};
                  final displayProfiles = profiles;
                  final activePins = displayProfiles.length;
                  final pinText = activePins <= 1
                      ? appState.tr(
                          '1 profile pin near you',
                          'دبوس ملف شخصي قريب منك',
                        )
                      : '$activePins ${appState.tr('profile pins near you', 'دبابيس ملفات شخصية قريبة منك')}';

                  const placeholderCoords = [
                    LatLng(30.0500, 31.2300),
                    LatLng(30.0350, 31.2450),
                    LatLng(30.0430, 31.2180),
                    LatLng(30.0560, 31.2560),
                    LatLng(30.0280, 31.2340),
                  ];

                  final markerWidth = (short * 0.26).clamp(72.0, 118.0);
                  final avatarBox = (short * 0.132).clamp(44.0, 58.0);
                  final gapAfterAvatar = (short * 0.015).clamp(4.0, 8.0);
                  final nameFs = (short * 0.022).clamp(8.0, 11.0);
                  final labelPadV = (short * 0.005).clamp(1.0, 4.0) * 2;
                  final markerHeight =
                      (avatarBox +
                              gapAfterAvatar +
                              labelPadV +
                              nameFs * 1.45 +
                              10)
                          .clamp(markerWidth * 1.12, markerWidth * 1.55);

                  final markers = <Marker>[];
                  final points = <LatLng>[];

                  for (int i = 0; i < displayProfiles.length; i++) {
                    final profile = displayProfiles[i];
                    final loc = locations[profile.id];
                    final coord = (loc != null)
                        ? LatLng(loc['lat']!, loc['lng']!)
                        : placeholderCoords[i % placeholderCoords.length];
                    points.add(coord);
                    markers.add(
                      Marker(
                        point: coord,
                        width: markerWidth,
                        height: markerHeight,
                        child: _buildProfileMarker(
                          context,
                          name: profile.profileName.toUpperCase(),
                          avatarUrl: profile.avatarUrl,
                          hasStatusDot: profile.status,
                          maxLabelWidth: markerWidth - 4,
                        ),
                      ),
                    );
                  }

                  final center = points.isNotEmpty
                      ? points.first
                      : const LatLng(30.0444, 31.2357);

                  return Stack(
                    children: [
                      SizedBox(
                        height: bannerH,
                        width: double.infinity,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: points.isNotEmpty ? 12 : 10,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.qlink.app',
                            ),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                      ),
                      Container(
                        height: bannerH,
                        width: double.infinity,
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: (w * 0.03).clamp(10.0, 14.0),
                            vertical: (short * 0.016).clamp(4.0, 8.0),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B64F2),
                            borderRadius: BorderRadius.circular(
                              (short * 0.055).clamp(16.0, 22.0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: (short * 0.042).clamp(14.0, 18.0),
                              ),
                              SizedBox(width: (w * 0.012).clamp(3.0, 6.0)),
                              Text(
                                pinText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: (w * 0.028).clamp(10.0, 12.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildActivityRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String details,
    required String time,
  }) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final pad = (short * 0.04).clamp(12.0, 18.0);
    final iconSz = (short * 0.055).clamp(20.0, 26.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((short * 0.04).clamp(14.0, 18.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: (short * 0.025).clamp(6.0, 12.0),
            offset: Offset(0, (short * 0.006).clamp(1.0, 3.0)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all((short * 0.028).clamp(8.0, 12.0)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                (short * 0.028).clamp(8.0, 12.0),
              ),
            ),
            child: Icon(icon, color: color, size: iconSz),
          ),
          SizedBox(width: (w * 0.04).clamp(10.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: (w * 0.036).clamp(12.0, 15.0),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: (w * 0.028).clamp(10.0, 12.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (short * 0.01).clamp(3.0, 6.0)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (w * 0.034).clamp(11.0, 14.0),
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: (short * 0.006).clamp(2.0, 4.0)),
                Text(
                  details,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: (w * 0.032).clamp(11.0, 13.0),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                border: Border.all(
                  color: const Color(0xFFE8D5C4),
                  width: borderW,
                ),
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
                    border: Border.all(
                      color: Colors.white,
                      width: (dot * 0.14).clamp(1.5, 2.5),
                    ),
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
            borderRadius: BorderRadius.circular(
              (short * 0.028).clamp(8.0, 12.0),
            ),
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
}
