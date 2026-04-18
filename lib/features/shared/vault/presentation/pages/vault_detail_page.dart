import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart'; // مسار الـ AppState

class VaultDetailPage extends StatelessWidget {
  final String name;
  final String imagePath;
  final String monitoredSince;
  final String statusLabel;
  final Color statusColor;
  final String bloodType;
  final String condition;
  final String allergies;
  final List<Map<String, String>> emergencyContacts;
  final List<Map<String, String>> documents;

  const VaultDetailPage({
    super.key,
    required this.name,
    required this.imagePath,
    required this.monitoredSince,
    required this.statusLabel,
    required this.statusColor,
    required this.bloodType,
    required this.condition,
    required this.allergies,
    required this.emergencyContacts,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppState().isArabic; // متغير اللغة

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, isArabic),
              const SizedBox(height: 20),
              _buildProfileHeader(isArabic),
              const SizedBox(height: 28),
              _buildMedicalSummary(isArabic),
              const SizedBox(height: 28),
              _buildEmergencyContacts(isArabic),
              const SizedBox(height: 28),
              _buildDocuments(isArabic),
              const SizedBox(height: 24),
              _buildSecurityNote(isArabic),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isArabic),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isArabic) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back,
                color: Color(0xFF1E3A8A),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                isArabic ? 'الخزنة' : 'Vault',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Icon(
          Icons.file_upload_outlined,
          color: Colors.grey.shade600,
          size: 24,
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.share_outlined,
          color: Colors.grey.shade600,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildProfileHeader(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isArabic ? 'مستخدم مراقب منذ $monitoredSince' : 'Monitored User Since $monitoredSince',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSummary(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الملخص الطبي' : 'Medical Summary',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _buildMedicalRow(
          icon: Icons.bloodtype_outlined,
          iconColor: const Color(0xFFEF4444),
          label: isArabic ? 'فصيلة الدم' : 'Blood Type',
          value: bloodType,
          valueColor: const Color(0xFFEF4444),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        _buildMedicalRow(
          icon: Icons.favorite_outline,
          iconColor: const Color(0xFF6366F1),
          label: isArabic ? 'الحالة الطبية' : 'Condition',
          value: condition,
          valueColor: const Color(0xFF1B64F2),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        _buildMedicalRow(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFF59E0B),
          label: isArabic ? 'الحساسية' : 'Allergies',
          value: allergies,
          valueColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildMedicalRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'جهات اتصال الطوارئ' : 'Emergency Contacts',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        ...emergencyContacts.map((contact) => _buildContactRow(
              name: contact['name'] ?? '',
              role: contact['role'] ?? '',
              imagePath: contact['image'] ?? 'assets/images/mypic.png',
            )),
      ],
    );
  }

  Widget _buildContactRow({
    required String name,
    required String role,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1B64F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'المستندات' : 'Documents',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        ...documents.map((doc) => _buildDocumentRow(
              title: doc['title'] ?? '',
              subtitle: doc['subtitle'] ?? '',
              iconColor: _getDocIconColor(doc['type'] ?? ''),
              icon: _getDocIcon(doc['type'] ?? ''),
              isArabic: isArabic,
            )),
      ],
    );
  }

  Color _getDocIconColor(String type) {
    switch (type) {
      case 'PDF':
        return const Color(0xFFEF4444);
      case 'DOCX':
        return const Color(0xFF3B82F6);
      case 'JPG':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getDocIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'DOCX':
        return Icons.description_outlined;
      case 'JPG':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Widget _buildDocumentRow({
    required String title,
    required String subtitle,
    required Color iconColor,
    required IconData icon,
    required bool isArabic,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isArabic ? 'عرض' : 'View',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B64F2).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            color: Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isArabic
                  ? 'يمكنك مشاركة هذه الخزنة بأمان مع المتخصصين الطبيين أو مساعدي الطوارئ عند الحاجة. جميع البيانات مشفرة ولا يمكن الوصول إليها إلا بإذنك.'
                  : 'You can securely share this vault with medical professionals or emergency helpers when assistance is required. All data is encrypted and only accessible via your permission.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isArabic) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(35),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(context, icon: LucideIcons.home, label: isArabic ? 'الرئيسية' : 'Home'),
                  _buildNavItem(context, icon: LucideIcons.map, label: isArabic ? 'الخريطة' : 'Map'),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B64F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  _buildNavItem(context,
                      icon: LucideIcons.lock,
                      label: isArabic ? 'الخزنة' : 'Vault',
                      isSelected: true),
                  _buildNavItem(context,
                      icon: LucideIcons.settings, label: isArabic ? 'الإعدادات' : 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF1B64F2)
                  : Colors.grey.shade500,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFF1B64F2)
                    : Colors.grey.shade500,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}