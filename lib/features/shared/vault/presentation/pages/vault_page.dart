import 'package:flutter/material.dart';
import 'package:q_link/features/shared/home/presentation/pages/home_page.dart'; // تأكدي من المسار ده 
import 'package:q_link/features/shared/vault/presentation/pages/vault_detail_page.dart'; // تأكدي من المسار ده
import 'package:q_link/core/state/app_state.dart'; // مسار الـ AppState

// ملحوظة: لو عندك ويدجت اسمها VideoLogoWidget، اتأكدي إنك عاملة ليها import فوق هنا 

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  @override
  Widget build(BuildContext context) {
    final isArabic = AppState().isArabic; // متغير اللغة

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
              _buildAppBar(isArabic),
              const SizedBox(height: 20),
              _buildSearchBar(isArabic),
              const SizedBox(height: 24),
              _buildMonitoredProfilesHeader(isArabic),
              const SizedBox(height: 16),
              _buildProfileCard(
                name: isArabic ? 'محمد صابر' : 'Mohamed Saber',
                role: isArabic ? 'مستخدم مراقب' : 'Monitored User',
                imagePath: 'assets/images/Mohamed Saber.png',
                recordCount: 12,
                lastUpdate: isArabic ? 'منذ ساعتين' : '2h ago',
                statusLabel: isArabic ? 'آمن' : 'SECURE',
                statusColor: const Color(0xFF22C55E),
                isArabic: isArabic,
                onOpenVault: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VaultDetailPage(
                        name: isArabic ? 'محمد صابر' : 'Mohamed Saber',
                        imagePath: 'assets/images/Mohamed Saber.png',
                        monitoredSince: '2024',
                        statusLabel: isArabic ? 'آمن' : 'SECURE',
                        statusColor: const Color(0xFF22C55E),
                        bloodType: 'A+',
                        condition: isArabic ? 'ضغط الدم' : 'Hypertension',
                        allergies: isArabic ? 'أسبرين' : 'Aspirin',
                        emergencyContacts: [
                          {'name': isArabic ? 'أحمد عصام' : 'Ahmed Essam', 'role': isArabic ? 'حفيد' : 'Grandson', 'image': 'assets/images/mypic.png'},
                          {'name': isArabic ? 'أحمد مازن' : 'Ahmed Mazen', 'role': isArabic ? 'ابن' : 'Son', 'image': 'assets/images/Wire Frames + Mobile App/Ahmed Mazen.png'},
                        ],
                        documents: [
                          {'title': isArabic ? 'تقرير طبي 2024' : 'Medical Report 2024', 'subtitle': 'PDF • 3.1 MB', 'type': 'PDF'},
                          {'title': isArabic ? 'نتائج القلب' : 'Cardiology Results', 'subtitle': 'DOCX • 1.8 MB', 'type': 'DOCX'},
                          {'title': isArabic ? 'بطاقة التأمين' : 'Insurance Card', 'subtitle': 'JPG • 920 KB', 'type': 'JPG'},
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildProfileCard(
                name: isArabic ? 'كارما أحمد' : 'Karma Ahmed',
                role: isArabic ? 'مستخدم مراقب' : 'Monitored User',
                imagePath: 'assets/images/karma.png',
                recordCount: 8,
                lastUpdate: isArabic ? 'الآن' : 'Just now',
                statusLabel: isArabic ? 'مُحدث' : 'UPDATED',
                statusColor: const Color(0xFF1B64F2),
                isArabic: isArabic,
                onOpenVault: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VaultDetailPage(
                        name: isArabic ? 'كارما أحمد' : 'Karma Ahmed',
                        imagePath: 'assets/images/karma.png',
                        monitoredSince: '2025',
                        statusLabel: isArabic ? 'آمن' : 'SECURE',
                        statusColor: const Color(0xFF22C55E),
                        bloodType: 'O+',
                        condition: isArabic ? 'سكر من النوع الأول' : 'Diabetes Type 1',
                        allergies: isArabic ? 'بنسلين' : 'Penicillin',
                        emergencyContacts: [
                          {'name': isArabic ? 'أحمد عصام' : 'Ahmed Essam', 'role': isArabic ? 'زوج' : 'Husband', 'image': 'assets/images/mypic.png'},
                          {'name': isArabic ? 'أحمد مازن' : 'Ahmed Mazen', 'role': isArabic ? 'أب' : 'Father', 'image': 'assets/images/Wire Frames + Mobile App/Ahmed Mazen.png'},
                        ],
                        documents: [
                          {'title': isArabic ? 'تقرير طبي 2020' : 'Medical Report 2020', 'subtitle': 'PDF • 2.4 MB', 'type': 'PDF'},
                          {'title': isArabic ? 'أحدث روشتة' : 'Latest Prescription', 'subtitle': 'DOCX • 1.1 MB', 'type': 'DOCX'},
                          {'title': isArabic ? 'بطاقة التأمين' : 'Insurance Card', 'subtitle': 'JPG • 850 KB', 'type': 'JPG'},
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildHealthSecurityTip(isArabic),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isArabic) {
    return Row(
      children: [
        // const VideoLogoWidget(), // لغيته مؤقتاً عشان ميديليكيش إيرور، رجعيه لو عاملة ليه import
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/mypic.png'),
        ),
        const Spacer(),
        Text(
          isArabic ? 'الخزنة' : 'Vault',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.language,
          color: Color(0xFF1E3A8A),
          size: 28,
        ),
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

  Widget _buildSearchBar(bool isArabic) {
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
              isArabic ? 'ابحث في السجلات أو الملفات' : 'Search records or profiles',
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

  Widget _buildMonitoredProfilesHeader(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الملفات المراقبة' : 'Monitored Profiles',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isArabic ? 'يوجد 2 ملفات طبية نشطة مرتبطة' : '2 active medical profiles linked',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        Text(
          isArabic ? 'عرض الكل' : 'View All',
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
    required bool isArabic,
    required VoidCallback onOpenVault,
  }) {
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
                          isArabic ? '$recordCount سجلات' : '$recordCount Records',
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
                          isArabic ? 'فتح الخزنة' : 'Open Vault',
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
                      isArabic ? 'مشاركة' : 'Share',
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

  Widget _buildHealthSecurityTip(bool isArabic) {
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
                  isArabic ? 'نصيحة أمنية صحية' : 'Health Security Tip',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isArabic 
                    ? 'تأكد من تفعيل المصادقة الثنائية لحماية\nملفات التاريخ الطبي الحساسة.'
                    : 'Ensure two-factor authentication is active to protect\nsensitive medical history files.',
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