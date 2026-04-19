import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/core/models/patient_profile.dart';

class VaultDetailPage extends StatelessWidget {
  final PatientProfile profile;
  final List<Map<String, String>> documents;

  const VaultDetailPage({
    super.key,
    required this.profile,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
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
                  _buildTopBar(context),
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 28),
                  _buildMedicalSummary(),
                  const SizedBox(height: 28),
                  _buildEmergencyContacts(),
                  const SizedBox(height: 28),
                  _buildDocuments(),
                  const SizedBox(height: 24),
                  _buildSecurityNote(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final appState = AppState();
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
                appState.tr('Vault', 'الخزنة'),
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
        const LanguageToggle(),
        const SizedBox(width: 16),
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

  Widget _buildProfileHeader() {
    final appState = AppState();
    final statusColor = profile.status ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final statusLabel = profile.status ? appState.tr('SECURE', 'آمن') : appState.tr('ALERT', 'تنبيه');
    
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
            backgroundImage: profile.avatarUrl.isEmpty
                ? const AssetImage('assets/images/mypic.png')
                : (profile.avatarUrl.startsWith('http')
                    ? NetworkImage(profile.avatarUrl)
                    : AssetImage(profile.avatarUrl)) as ImageProvider,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.profileName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  appState.tr('Monitored Since ${profile.createdAt.year}', 'مستخدم مراقب منذ ${profile.createdAt.year}'),
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

  Widget _buildMedicalSummary() {
    final appState = AppState();
    final condition = appState.isArabic ? (profile.medicalNotesAr.isNotEmpty ? profile.medicalNotesAr : profile.medicalNotesEn) : profile.medicalNotesEn;
    final allergies = appState.isArabic ? (profile.allergiesAr.isNotEmpty ? profile.allergiesAr : profile.allergiesEn) : profile.allergiesEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Medical Summary', 'الملخص الطبي'),
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
          label: appState.tr('Blood Type', 'فصيلة الدم'),
          value: profile.bloodType ?? 'N/A',
          valueColor: const Color(0xFFEF4444),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        _buildMedicalRow(
          icon: Icons.favorite_outline,
          iconColor: const Color(0xFF6366F1),
          label: appState.tr('Condition', 'الحالة الطبية'),
          value: condition.isEmpty ? 'None' : condition,
          valueColor: const Color(0xFF1B64F2),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        _buildMedicalRow(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFF59E0B),
          label: appState.tr('Allergies', 'الحساسية'),
          value: allergies.isEmpty ? 'None' : allergies,
          valueColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  // --- Hna b2a el ta3deel elly sal7 el Overflow Error ---
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
        crossAxisAlignment: CrossAxisAlignment.start, // 3shan lw el klam nzl satren, yfdal el icon fo2
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded( // El Expanded da hwa el btal elly mn3 el overflow!
            child: Align(
              alignment: AlignmentDirectional.centerEnd, // by-zbot el mkan ymen aw shmal 7asab el lo8a
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: valueColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                    height: 1.4, // Msafa ben el stoor lw el klam kbeer
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    final appState = AppState();
    final primary = profile.emergencyContacts['primary'] ?? {};
    final secondary = profile.emergencyContacts['secondary'] ?? {};
    final List<Widget> buildResults = [];

    if (primary.isNotEmpty) {
      String primaryName = primary['name'] ?? '';
      String primaryImage = 'assets/images/mypic.png';
      if (primaryName.toLowerCase().contains('mariam')) primaryImage = 'assets/images/mypic.png';
      if (primaryName.toLowerCase().contains('saber')) primaryImage = 'assets/images/Ahmed Saber.png';
      if (primaryName.toLowerCase().contains('mazen')) primaryImage = 'assets/images/Ahmed Mazen.png';
      
      buildResults.add(_buildContactRow(
        name: primaryName,
        role: appState.tr(primary['relation'] ?? '', primary['relation'] ?? ''),
        imagePath: primaryImage,
      ));
    }
    if (secondary.isNotEmpty) {
      String secondaryName = secondary['name'] ?? '';
      String secondaryImage = 'assets/images/mypic.png';
      if (secondaryName.toLowerCase().contains('mariam')) secondaryImage = 'assets/images/mypic.png';
      if (secondaryName.toLowerCase().contains('saber')) secondaryImage = 'assets/images/Ahmed Saber.png';
      if (secondaryName.toLowerCase().contains('mazen')) secondaryImage = 'assets/images/Ahmed Mazen.png';
      
      buildResults.add(_buildContactRow(
        name: secondaryName,
        role: appState.tr(secondary['relation'] ?? '', secondary['relation'] ?? ''),
        imagePath: secondaryImage,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Emergency Contacts', 'جهات اتصال الطوارئ'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        ...buildResults,
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

  Widget _buildDocuments() {
    final appState = AppState();
    if (documents.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Documents', 'المستندات'),
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
  }) {
    final appState = AppState();

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
            appState.tr('View', 'عرض'),
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

  Widget _buildSecurityNote() {
    final appState = AppState();
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
              appState.tr(
                'You can securely share this vault with medical professionals or emergency helpers when assistance is required. All data is encrypted and only accessible via your permission.',
                'يمكنك مشاركة هذه الخزنة بأمان مع المتخصصين الطبيين أو مساعدي الطوارئ عند الحاجة. جميع البيانات مشفرة ولا يمكن الوصول إليها إلا بإذنك.'
              ),
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
}