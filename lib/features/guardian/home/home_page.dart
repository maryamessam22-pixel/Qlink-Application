import 'package:flutter/material.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:video_player/video_player.dart';
import 'package:q_link/features/guardian/profile/add_profile_identity.dart';
import 'package:q_link/features/guardian/profile/connect_device_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/profile/profile_management_page.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PatientProfile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = SupabaseService().fetchPatientProfiles();
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
    });
  }

  Widget _buildInitials(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProfileAvatar(PatientProfile profile) {
    final url = profile.avatarUrl;
    if (url.isEmpty) return _buildInitials(profile.profileName);

    if (url.startsWith('assets')) {
      return SizedBox(
        width: 60, height: 60,
        child: Image.asset(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(profile.profileName),
        ),
      );
    }

    return SizedBox(
      width: 60, height: 60,
      child: Image.network(url, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(profile.profileName),
      ),
    );
  }

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
        child: AnimatedBuilder(
          animation: AppState(),
          builder: (context, _) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar Header
                HeaderWidget(),

                // Dynamic Stats and Status
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
                        // Welcome Text
                        Text(
                          appState.tr(
                            'Hello, Mariam Essam',
                            'مرحباً، مريم عصام',
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appState.tr(
                            'Your Safety Circle Command Center',
                            'مركز قيادة دائرة الأمان الخاصة بك',
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.devices_outlined,
                                          color: Color(0xFF1B64F2),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: activeDeviceCount > 0
                                                  ? Colors.white
                                                  : const Color(0xFF4B5563),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '$activeDeviceCount',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B64F2),
                                      ),
                                    ),
                                    Text(
                                      appState.tr(
                                        'Active Devices',
                                        'أجهزة نشطة',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1B64F2),
                                      ),
                                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.group_outlined,
                                          color: Color(0xFF0E9F6E),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '$actualProfileCount',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E9F6E),
                                      ),
                                    ),
                                    Text(
                                      appState.tr(
                                        'Protected Members',
                                        'الأعضاء المحميون',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF0E9F6E),
                                      ),
                                    ),
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
                            color: activeDeviceCount > 0
                                ? const Color(0xFFDEF7EC)
                                : const Color(0xFFEAF8F0),
                            border: Border.all(
                              color: activeDeviceCount > 0
                                  ? const Color(0xFF84E1BC)
                                  : const Color(0xFFB4E6C9),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: activeDeviceCount > 0
                                    ? const Color(0xFF0E9F6E)
                                    : const Color(0xFF0E9F6E),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 13,
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
                const SizedBox(height: 24),

                // Dynamic Protected Member Section
                FutureBuilder<List<PatientProfile>>(
                  future: _profilesFuture,
                  builder: (context, snapshot) {
                    final appState = AppState();
                    final profiles = snapshot.data ?? [];
                    if (profiles.isEmpty &&
                        snapshot.connectionState != ConnectionState.waiting)
                      return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appState.tr('Protected Member', 'العضو المحمي'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
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
                        const SizedBox(height: 12),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...profiles.asMap().entries.map((entry) {
                            return _buildProtectedMemberCard(
                              context,
                              entry.key,
                              entry.value,
                            );
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
                    if (AppState().profiles.isNotEmpty)
                      return const SizedBox.shrink();
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
                                  color: Colors.white.withValues(alpha: 0.9),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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

                // Connect Bracelet Card
                AnimatedBuilder(
                  animation: AppState(),
                  builder: (context, _) {
                    final appState = AppState();
                    return Container(
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
                          Text(
                            appState.tr('Connect a Bracelet', 'توصيل سوار'),
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
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              if (appState.profileCount == 0) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      appState.tr(
                                        'Profile Required',
                                        'مطلوب ملف تعريف',
                                      ),
                                    ),
                                    content: Text(
                                      appState.tr(
                                        'You must create a profile first before connecting a bracelet.',
                                        'يجب إنشاء ملف تعريف أولاً قبل توصيل السوار.',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          appState.tr('Cancel', 'إلغاء'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ConnectDevicePage(),
                                ),
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
                                  const Icon(
                                    Icons.add,
                                    color: Color(0xFF273469),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    appState.deviceCount > 0
                                        ? appState.tr(
                                            'Add Bracelet',
                                            'إضافة سوار',
                                          )
                                        : appState.tr(
                                            'Add First Bracelet',
                                            'إضافة أول سوار',
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
                            Text(
                              appState.tr('Recent Activity', 'النشاط الأخير'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                hasDevice
                                    ? appState.tr('View All', 'عرض الكل')
                                    : appState.tr('See all', 'عرض الكل'),
                                style: TextStyle(
                                  color: hasDevice
                                      ? const Color(0xFF1B64F2)
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
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
        );
          },
        ),
      ),
    );
  }

  Widget _buildProtectedMemberCard(
    BuildContext context,
    int index,
    PatientProfile profile,
  ) {
    final appState = AppState();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProfileAvatar(profile),
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
                          profile.profileName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
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
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to profile management - passing converted data for now
                    List<String> emergencyContactsList = [];
                    if (profile.emergencyContacts.isNotEmpty) {
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
                          code: 'QLINK-PULSE-${profile.id.substring(0, 6).toUpperCase()}',
                          connectedAt: profile.createdAt,
                        ),
                      ];
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
                            birthYear: profile.birthYear.toString(),
                            bloodType: profile.bloodType,
                            condition: profile.medicalNotesEn,
                            allergies: profile.allergiesEn,
                            emergencyContacts: emergencyContactsList,
                            devices: matchedDevices,
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFF3F4F6)),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppState().tr('View Profile', 'عرض الملف'),
                    style: const TextStyle(
                      color: Color(0xFF1B64F2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: profile.status
                    ? OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.purple,
                          size: 18,
                        ),
                        label: Text(
                          AppState().tr('Added Device', 'جهاز مضاف'),
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: Colors.purple.withValues(alpha: 0.1),
                          ),
                          backgroundColor: Colors.purple.withValues(
                            alpha: 0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConnectDevicePage(
                                    targetProfileIndex: index,
                                    targetProfileId: profile.id,
                                  ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: Colors.purple.withValues(alpha: 0.1),
                          ),
                          backgroundColor: Colors.purple.withValues(
                            alpha: 0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppState().tr('+ Add Device', '+ إضافة جهاز'),
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                appState.tr('Last update: Today', 'آخر تحديث: اليوم'),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
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
            Text(
              AppState().tr('No activity yet', 'لا يوجد نشاط بعد'),
              style: TextStyle(color: Colors.grey.shade500),
            ),
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
              AnimatedBuilder(
                animation: AppState(),
                builder: (context, _) {
                  final appState = AppState();
                  return Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B64F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_pin_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appState.tr(
                                '1 active pin near you',
                                'دبوس نشط واحد بالقرب منك',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
            color: Colors.black.withValues(alpha: 0.03),
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
              color: color.withValues(alpha: 0.1),
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
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
