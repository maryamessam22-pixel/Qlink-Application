import 'package:flutter/material.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/services/supabase_service.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/guardian/vault/vault_detail_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
import 'package:q_link/features/shared/pages/notifications_page.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FC),
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
                opacity: 0.08,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: FutureBuilder<List<PatientProfile>>(
                future: SupabaseService().fetchPatientProfiles(),
                builder: (context, snapshot) {
                  final profiles = snapshot.data ?? [];
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAppBar(),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildMonitoredProfilesHeader(profiles.length),
                      const SizedBox(height: 16),
                      
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator(color: Color(0xFF1B64F2)))
                      else if (profiles.isEmpty)
                        Center(child: Text(appState.tr('No profiles found', 'لا توجد ملفات حالياً')))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: profiles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final profile = profiles[index];
                            final statusColor = profile.status ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
                            final statusLabel = profile.status ? appState.tr('SECURE', 'آمن') : appState.tr('ALERT', 'تنبيه');
                            
                            return _buildProfileCard(
                              name: profile.profileName,
                              role: appState.tr(profile.relationshipToGuardian, profile.relationshipToGuardian),
                              imagePath: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : 'assets/images/mypic.png',
                              recordCount: 5, // Mock for now, could be fetched
                              lastUpdate: appState.tr('Latest', 'الأحدث'),
                              statusLabel: statusLabel,
                              statusColor: statusColor,
                              onOpenVault: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VaultDetailPage(
                                      profile: profile,
                                      documents: [
                                        {'title': appState.tr('Medical Report', 'تقرير طبي'), 'subtitle': 'PDF • 3.1 MB', 'type': 'PDF'},
                                        {'title': appState.tr('Insurance Card', 'بطاقة التأمين'), 'subtitle': 'JPG • 850 KB', 'type': 'JPG'},
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      
                      const SizedBox(height: 24),
                      _buildHealthSecurityTip(),
                      const SizedBox(height: 120),
                    ],
                  );
                },
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    final appState = AppState();
    return Row(
      children: [
        VideoLogoWidget(),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFE6F0FE),
          backgroundImage: getUserAvatarProvider(appState.currentUser.imagePath),
          onBackgroundImageError: (_, __) {},
        ),
        const Spacer(),
        Text(
          appState.tr('Vault', 'الخزنة'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
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

  Widget _buildSearchBar() {
    final appState = AppState();
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              appState.tr('Search records or profiles', 'ابحث في السجلات أو الملفات'),
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoredProfilesHeader(int count) {
    final appState = AppState();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.tr('Monitored Profiles', 'الملفات المراقبة'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appState.tr('$count active medical profiles linked', 'يوجد $count ملفات طبية نشطة مرتبطة'),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        Text(
          appState.tr('View All', 'عرض الكل'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String role,
    required String imagePath,
    required int recordCount,
    required String lastUpdate,
    required String statusLabel,
    required Color statusColor,
    required VoidCallback onOpenVault,
  }) {
    final appState = AppState();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: getUserAvatarProvider(imagePath),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appState.tr('$recordCount Records', '$recordCount سجلات'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lastUpdate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpenVault,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0066CC),
                          Color(0xFF273469),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder_open,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appState.tr('Open Vault', 'فتح الخزنة'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      appState.tr('Share', 'مشاركة'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSecurityTip() {
    final appState = AppState();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE6F7EE),
            const Color(0xFFE6F7EE).withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB4E6C9).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user,
              color: Color(0xFF22C55E),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.tr('Health Security Tip', 'نصيحة أمنية صحية'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  appState.tr(
                    'Ensure two-factor authentication is active to protect\nsensitive medical history files.',
                    'تأكد من تفعيل المصادقة الثنائية لحماية\nملفات التاريخ الطبي الحساسة.'
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
