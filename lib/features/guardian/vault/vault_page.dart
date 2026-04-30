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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final vPad = (short * 0.028).clamp(12.0, 20.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFFF7F9FC)),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.08,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bottomPad),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: FutureBuilder<List<PatientProfile>>(
                          future: SupabaseService().fetchPatientProfiles(),
                          builder: (context, snapshot) {
                            final profiles = snapshot.data ?? [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildAppBar(),
                                SizedBox(height: (short * 0.05).clamp(16.0, 24.0)),
                                _buildSearchBar(),
                                SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                                _buildMonitoredProfilesHeader(profiles.length),
                                SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                                if (snapshot.connectionState == ConnectionState.waiting)
                                  const Center(child: CircularProgressIndicator(color: Color(0xFF1B64F2)))
                                else if (profiles.isEmpty)
                                  Center(child: Text(appState.tr('No profiles found', 'لا توجد ملفات حالياً')))
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: profiles.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                                    itemBuilder: (context, index) {
                                      final profile = profiles[index];
                                      final statusColor =
                                          profile.status ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
                                      final statusLabel = profile.status
                                          ? appState.tr('SECURE', 'آمن')
                                          : appState.tr('ALERT', 'تنبيه');

                                      return _buildProfileCard(
                                        name: profile.profileName,
                                        role: appState.tr(
                                            profile.relationshipToGuardian, profile.relationshipToGuardian),
                                        imagePath: profile.avatarUrl,
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
                                                documents: const [],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                                _buildHealthSecurityTip(),
                                SizedBox(height: (short * 0.03).clamp(8.0, 16.0)),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    final appState = AppState();
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final avatarR = (short * 0.042).clamp(14.0, 18.0);
    final titleFs = (short * 0.052).clamp(17.0, 22.0);
    final bell = (short * 0.072).clamp(24.0, 30.0);
    final gap = (short * 0.022).clamp(6.0, 12.0);

    return Row(
      children: [
        VideoLogoWidget(),
        SizedBox(width: gap),
        CircleAvatar(
          radius: avatarR,
          backgroundColor: const Color(0xFFE6F0FE),
          backgroundImage: appState.currentUser.imagePath.trim().isNotEmpty
              ? getUserAvatarProvider(appState.currentUser.imagePath)
              : null,
          onBackgroundImageError: appState.currentUser.imagePath.trim().isNotEmpty
              ? (_, __) {}
              : null,
          child: appState.currentUser.imagePath.trim().isEmpty
              ? Text(
                  appState.currentUser.name.isNotEmpty
                      ? appState.currentUser.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: (avatarR * 0.72).clamp(10.0, 14.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B64F2),
                  ),
                )
              : null,
        ),
        const Spacer(),
        Text(
          appState.tr('Vault', 'الخزنة'),
          style: TextStyle(
            fontSize: titleFs,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const Spacer(),
        const LanguageToggle(),
        SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
          child: AnimatedBuilder(
            animation: AppState(),
            builder: (context, _) {
              final unread = AppState().unreadNotificationCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none, color: const Color(0xFF1E3A8A), size: bell),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: BoxConstraints(
                          minWidth: (short * 0.042).clamp(14.0, 18.0),
                          minHeight: (short * 0.042).clamp(14.0, 18.0),
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (short * 0.024).clamp(8.0, 10.0),
                            fontWeight: FontWeight.bold,
                          ),
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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final h = (short * 0.125).clamp(44.0, 56.0);
    final radius = (w * 0.035).clamp(12.0, 16.0);
    final iconS = (short * 0.055).clamp(20.0, 24.0);
    final padH = (w * 0.035).clamp(12.0, 16.0);

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
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
          SizedBox(width: padH),
          Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: iconS,
          ),
          SizedBox(width: (short * 0.026).clamp(8.0, 12.0)),
          Expanded(
            child: Text(
              appState.tr('Search records or profiles', 'ابحث في السجلات أو الملفات'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: (short * 0.036).clamp(13.0, 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoredProfilesHeader(int count) {
    final appState = AppState();
    final short = MediaQuery.of(context).size.shortestSide;
    final titleFs = (short * 0.046).clamp(16.0, 20.0);
    final subFs = (short * 0.034).clamp(12.0, 14.0);
    final linkFs = (short * 0.036).clamp(13.0, 15.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.tr('Monitored Profiles', 'الملفات المراقبة'),
                style: TextStyle(
                  fontSize: titleFs,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              SizedBox(height: (short * 0.01).clamp(3.0, 6.0)),
              Text(
                appState.tr('$count active medical profiles linked', 'يوجد $count ملفات طبية نشطة مرتبطة'),
                style: TextStyle(
                  fontSize: subFs,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Text(
          appState.tr('View All', 'عرض الكل'),
          style: TextStyle(
            fontSize: linkFs,
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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final cardPad = (short * 0.045).clamp(14.0, 20.0);
    final avatarR = (short * 0.072).clamp(24.0, 32.0);
    final nameFs = (short * 0.04).clamp(14.0, 17.0);
    final metaFs = (short * 0.033).clamp(11.5, 13.5);
    final smallIcon = (short * 0.036).clamp(12.0, 15.0);
    final btnH = (short * 0.105).clamp(40.0, 48.0);
    final cardRadius = (w * 0.04).clamp(14.0, 18.0);

    return Container(
      padding: EdgeInsets.all(cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
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
                radius: avatarR,
                backgroundImage:
                    imagePath.trim().isNotEmpty ? getUserAvatarProvider(imagePath) : null,
                onBackgroundImageError:
                    imagePath.trim().isNotEmpty ? (_, __) {} : null,
                child: imagePath.trim().isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: const Color(0xFF1B64F2),
                          fontWeight: FontWeight.bold,
                          fontSize: (avatarR * 0.62).clamp(14.0, 20.0),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: (short * 0.035).clamp(10.0, 16.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: nameFs,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: (short * 0.006).clamp(1.0, 4.0)),
                    Text(
                      role,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: metaFs,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: (short * 0.016).clamp(4.0, 8.0)),
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: smallIcon,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: (short * 0.01).clamp(3.0, 6.0)),
                        Flexible(
                          child: Text(
                            appState.tr('$recordCount Records', '$recordCount سجلات'),
                            style: TextStyle(
                              fontSize: metaFs,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: (short * 0.03).clamp(8.0, 14.0)),
                        Icon(
                          Icons.access_time,
                          size: smallIcon,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: (short * 0.01).clamp(3.0, 6.0)),
                        Flexible(
                          child: Text(
                            lastUpdate,
                            style: TextStyle(
                              fontSize: metaFs,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                    fontSize: (short * 0.028).clamp(10.0, 12.0),
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpenVault,
                  child: Container(
                    height: btnH,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0066CC),
                          Color(0xFF273469),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular((short * 0.026).clamp(8.0, 12.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          color: Colors.white,
                          size: (btnH * 0.42).clamp(16.0, 20.0),
                        ),
                        SizedBox(width: (short * 0.02).clamp(6.0, 10.0)),
                        Text(
                          appState.tr('Open Vault', 'فتح الخزنة'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (short * 0.036).clamp(13.0, 15.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: (short * 0.03).clamp(8.0, 14.0)),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appState.tr('Open the profile vault to share documents', 'افتح خزنة الملف لمشاركة المستندات')),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: Colors.grey.shade600,
                      size: (short * 0.045).clamp(16.0, 20.0),
                    ),
                    SizedBox(width: (short * 0.016).clamp(4.0, 8.0)),
                    Text(
                      appState.tr('Share', 'مشاركة'),
                      style: TextStyle(
                        fontSize: (short * 0.036).clamp(13.0, 15.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: (short * 0.02).clamp(4.0, 10.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSecurityTip() {
    final appState = AppState();
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final pad = (short * 0.05).clamp(16.0, 22.0);
    final iconBox = (short * 0.1).clamp(36.0, 44.0);
    final iconIn = (iconBox * 0.5).clamp(18.0, 22.0);
    final titleFs = (short * 0.038).clamp(14.0, 16.0);
    final bodyFs = (short * 0.034).clamp(12.0, 14.0);
    final radius = (w * 0.04).clamp(14.0, 18.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE6F7EE),
            const Color(0xFFE6F7EE).withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFFB4E6C9).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              color: const Color(0xFF22C55E),
              size: iconIn,
            ),
          ),
          SizedBox(width: (short * 0.035).clamp(10.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.tr('Health Security Tip', 'نصيحة أمنية صحية'),
                  style: TextStyle(
                    fontSize: titleFs,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                ),
                SizedBox(height: (short * 0.016).clamp(4.0, 8.0)),
                Text(
                  appState.tr(
                    'Ensure two-factor authentication is active to protect\nsensitive medical history files.',
                    'تأكد من تفعيل المصادقة الثنائية لحماية\nملفات التاريخ الطبي الحساسة.',
                  ),
                  style: TextStyle(
                    fontSize: bodyFs,
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
