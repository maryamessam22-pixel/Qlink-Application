import 'package:flutter/material.dart';
import 'package:q_link/features/guardian/home/home_page.dart';
import 'package:q_link/features/shared/widgets/video_logo_widget.dart';
import 'package:q_link/features/guardian/vault/vault_detail_page.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';

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
          backgroundColor: const Color(0xFFF7F9FC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildMonitoredProfilesHeader(),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    name: appState.tr('Mohamed Saber', 'محمد صابر'),
                    role: appState.tr('Monitored User', 'مستخدم مراقب'),
                    imagePath: 'assets/images/Mohamed Saber.png',
                    recordCount: 12,
                    lastUpdate: appState.tr('2h ago', 'منذ ساعتين'),
                    statusLabel: appState.tr('SECURE', 'آمن'),
                    statusColor: const Color(0xFF22C55E),
                    onOpenVault: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VaultDetailPage(
                            name: appState.tr('Mohamed Saber', 'محمد صابر'),
                            imagePath: 'assets/images/Mohamed Saber.png',
                            monitoredSince: '2024',
                            statusLabel: appState.tr('SECURE', 'آمن'),
                            statusColor: const Color(0xFF22C55E),
                            bloodType: 'A+',
                            condition: appState.tr('Hypertension', 'ضغط الدم'),
                            allergies: appState.tr('Aspirin', 'أسبرين'),
                            emergencyContacts: [
                              {'name': appState.tr('Mariam Essam', 'مريم عصام'), 'role': appState.tr('Guardian', 'وصي'), 'image': 'assets/images/mypic.png'},
                              {'name': appState.tr('Ahmed Saber', 'أحمد صابر'), 'role': appState.tr('Brother', 'أخ'), 'image': 'assets/images/Ahmed Saber.png'},
                            ],
                            documents: [
                              {'title': appState.tr('Medical Report 2024', 'تقرير طبي 2024'), 'subtitle': 'PDF • 3.1 MB', 'type': 'PDF'},
                              {'title': appState.tr('Cardiology Results', 'نتائج القلب'), 'subtitle': 'DOCX • 1.8 MB', 'type': 'DOCX'},
                              {'title': appState.tr('Insurance Card', 'بطاقة التأمين'), 'subtitle': 'JPG • 920 KB', 'type': 'JPG'},
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    name: appState.tr('Karma Ahmed', 'كارما أحمد'),
                    role: appState.tr('Monitored User', 'مستخدم مراقب'),
                    imagePath: 'assets/images/karma.png',
                    recordCount: 8,
                    lastUpdate: appState.tr('Just now', 'الآن'),
                    statusLabel: appState.tr('UPDATED', 'مُحدث'),
                    statusColor: const Color(0xFF1B64F2),
                    onOpenVault: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VaultDetailPage(
                            name: appState.tr('Karma Ahmed', 'كارما أحمد'),
                            imagePath: 'assets/images/karma.png',
                            monitoredSince: '2025',
                            statusLabel: appState.tr('SECURE', 'آمن'),
                            statusColor: const Color(0xFF22C55E),
                            bloodType: 'O+',
                            condition: appState.tr('Diabetes Type 1', 'سكر من النوع الأول'),
                            allergies: appState.tr('Penicillin', 'بنسلين'),
                            emergencyContacts: [
                              {'name': appState.tr('Mariam Essam', 'مريم عصام'), 'role': appState.tr('Mom', 'أم'), 'image': 'assets/images/mypic.png'},
                              {'name': appState.tr('Ahmed Mazen', 'أحمد مازن'), 'role': appState.tr('Dad', 'أب'), 'image': 'assets/images/Ahmed Mazen.png'},
                            ],
                            documents: [
                              {'title': appState.tr('Medical Report 2020', 'تقرير طبي 2020'), 'subtitle': 'PDF • 2.4 MB', 'type': 'PDF'},
                              {'title': appState.tr('Latest Prescription', 'أحدث روشتة'), 'subtitle': 'DOCX • 1.1 MB', 'type': 'DOCX'},
                              {'title': appState.tr('Insurance Card', 'بطاقة التأمين'), 'subtitle': 'JPG • 850 KB', 'type': 'JPG'},
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildHealthSecurityTip(),
                  const SizedBox(height: 120),
                ],
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
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/mypic.png'),
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

  Widget _buildMonitoredProfilesHeader() {
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
              appState.tr('2 active medical profiles linked', 'يوجد 2 ملفات طبية نشطة مرتبطة'),
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
                backgroundImage: AssetImage(imagePath),
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
