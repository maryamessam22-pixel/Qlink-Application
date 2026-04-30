import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart' show getUserAvatarProvider;
import 'package:q_link/services/supabase_service.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class VaultDetailPage extends StatefulWidget {
  final PatientProfile profile;
  final List<Map<String, String>> documents;

  const VaultDetailPage({
    super.key,
    required this.profile,
    required this.documents,
  });

  @override
  State<VaultDetailPage> createState() => _VaultDetailPageState();
}

class _VaultDetailPageState extends State<VaultDetailPage> {
  late List<Map<String, String>> _documents;
  bool _isLoadingDocs = true;

  /// Latest `avatar_url` from Supabase (passed [PatientProfile] can be stale or synthetic).
  String? _avatarUrlOverride;
  bool _avatarImageFailed = false;

  @override
  void initState() {
    super.initState();
    _documents = List<Map<String, String>>.from(widget.documents);
    _loadVaultDocs();
    _refreshAvatarFromServer();
  }

  Future<void> _refreshAvatarFromServer() async {
    final id = widget.profile.id.trim();
    if (id.isEmpty) return;
    try {
      final row = await SupabaseService().fetchPatientProfileById(id);
      if (!mounted || row == null) return;
      final u = (row['avatar_url'] ?? '').toString().trim();
      if (u.isNotEmpty) {
        setState(() {
          _avatarUrlOverride = u;
          _avatarImageFailed = false;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadVaultDocs() async {
    if (widget.profile.id.isEmpty) {
      if (mounted) setState(() => _isLoadingDocs = false);
      return;
    }
    final rows = await SupabaseService().fetchVaultDocuments(widget.profile.id);
    if (!mounted) return;
    setState(() {
      _documents = rows
          .map((row) => {
                'id': (row['id'] ?? '').toString(),
                'title': (row['title'] ?? '').toString(),
                'subtitle':
                    '${(row['file_type'] ?? '').toString()} • ${(row['file_size_kb'] ?? 0).toString()} KB',
                'type': (row['file_type'] ?? '').toString(),
                'file_url': (row['file_url'] ?? '').toString(),
                'file_size_kb': (row['file_size_kb'] ?? 0).toString(),
              })
          .toList();
      _isLoadingDocs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final vPad = (short * 0.028).clamp(12.0, 20.0);
        final barH = (short * 0.175).clamp(56.0, 78.0);
        final vMargin = (short * 0.038).clamp(10.0, 20.0);
        final navReserve = barH + vMargin * 2 + (short * 0.12).clamp(28.0, 44.0);
        final bottomPad = mq.viewInsets.bottom + mq.padding.bottom + navReserve;
        final gapL = (short * 0.055).clamp(18.0, 28.0);
        final gapM = (short * 0.05).clamp(16.0, 24.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          extendBody: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bottomPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context),
                        SizedBox(height: (short * 0.05).clamp(16.0, 24.0)),
                        _buildProfileHeader(widget.profile),
                        SizedBox(height: gapL),
                        _buildMedicalSummary(widget.profile),
                        SizedBox(height: gapL),
                        _buildEmergencyContacts(widget.profile),
                        SizedBox(height: gapL),
                        _buildDocuments(),
                        SizedBox(height: gapM),
                        _buildSecurityNote(),
                        SizedBox(height: (short * 0.03).clamp(8.0, 16.0)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final appState = AppState();
    final short = MediaQuery.of(context).size.shortestSide;
    final backS = (short * 0.058).clamp(20.0, 24.0);
    final titleFs = (short * 0.052).clamp(17.0, 22.0);
    final actionS = (short * 0.062).clamp(22.0, 26.0);
    final gap = (short * 0.04).clamp(12.0, 18.0);

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back,
                color: const Color(0xFF1E3A8A),
                size: backS,
              ),
              SizedBox(width: (short * 0.016).clamp(4.0, 8.0)),
              Text(
                appState.tr('Vault', 'الخزنة'),
                style: TextStyle(
                  fontSize: titleFs,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const LanguageToggle(),
        SizedBox(width: gap),
        GestureDetector(
          onTap: _showUploadDialog,
          child: Icon(
            Icons.file_upload_outlined,
            color: Colors.grey.shade600,
            size: actionS,
          ),
        ),
        SizedBox(width: gap),
        GestureDetector(
          onTap: _shareVault,
          child: Icon(
            Icons.share_outlined,
            color: Colors.grey.shade600,
            size: actionS,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(PatientProfile profile) {
    final appState = AppState();
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final pad = (short * 0.04).clamp(12.0, 18.0);
    final radius = (w * 0.04).clamp(14.0, 18.0);
    final avatarR = (short * 0.082).clamp(28.0, 36.0);
    final statusColor = profile.status ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final statusLabel = profile.status ? appState.tr('SECURE', 'آمن') : appState.tr('ALERT', 'تنبيه');
    final avatarUrl = (_avatarUrlOverride ?? profile.avatarUrl).trim();
    final showPhoto = avatarUrl.isNotEmpty && !_avatarImageFailed;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarR,
            backgroundColor: const Color(0xFFE6F0FE),
            backgroundImage:
                showPhoto ? getUserAvatarProvider(avatarUrl) : null,
            onBackgroundImageError: showPhoto
                ? (_, __) {
                    if (mounted) setState(() => _avatarImageFailed = true);
                  }
                : null,
            child: showPhoto
                ? null
                : Text(
                    profile.profileName.isNotEmpty
                        ? profile.profileName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: (avatarR * 0.68).clamp(16.0, 24.0),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B64F2),
                    ),
                  ),
          ),
          SizedBox(width: (short * 0.035).clamp(10.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.profileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (short * 0.042).clamp(15.0, 18.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: (short * 0.008).clamp(2.0, 5.0)),
                Text(
                  appState.tr('Monitored Since ${profile.createdAt.year}', 'مستخدم مراقب منذ ${profile.createdAt.year}'),
                  style: TextStyle(
                    fontSize: (short * 0.034).clamp(12.0, 14.0),
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: (short * 0.016).clamp(4.0, 8.0)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (short * 0.026).clamp(8.0, 12.0),
                    vertical: (short * 0.008).clamp(2.0, 4.0),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSummary(PatientProfile profile) {
    final appState = AppState();
    final short = MediaQuery.of(context).size.shortestSide;
    final sectionFs = (short * 0.042).clamp(15.0, 18.0);
    final condition = appState.isArabic ? (profile.medicalNotesAr.isNotEmpty ? profile.medicalNotesAr : profile.medicalNotesEn) : profile.medicalNotesEn;
    final allergies = appState.isArabic ? (profile.allergiesAr.isNotEmpty ? profile.allergiesAr : profile.allergiesEn) : profile.allergiesEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Medical Summary', 'الملخص الطبي'),
          style: TextStyle(
            fontSize: sectionFs,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: (short * 0.042).clamp(12.0, 18.0)),
        _buildMedicalRow(
          icon: Icons.bloodtype_outlined,
          iconColor: const Color(0xFFEF4444),
          label: appState.tr('Blood Type', 'فصيلة الدم'),
          value: profile.bloodType.isEmpty
              ? appState.tr('Not set', 'غير محدد')
              : profile.bloodType,
          valueColor: const Color(0xFFEF4444),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        _buildMedicalRow(
          icon: Icons.favorite_outline,
          iconColor: const Color(0xFF6366F1),
          label: appState.tr('Condition', 'الحالة الطبية'),
          value: condition.isEmpty ? appState.tr('None', 'لا يوجد') : condition,
          valueColor: const Color(0xFF1B64F2),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        _buildMedicalRow(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFF59E0B),
          label: appState.tr('Allergies', 'الحساسية'),
          value: allergies.isEmpty ? appState.tr('None', 'لا يوجد') : allergies,
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
    final short = MediaQuery.of(context).size.shortestSide;
    final box = (short * 0.092).clamp(32.0, 40.0);
    final iconS = (box * 0.5).clamp(16.0, 20.0);
    final labelFs = (short * 0.038).clamp(13.5, 16.0);
    final valueFs = (short * 0.034).clamp(12.0, 14.0);
    final vPad = (short * 0.038).clamp(10.0, 16.0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 3shan lw el klam nzl satren, yfdal el icon fo2
        children: [
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: iconS),
          ),
          SizedBox(width: (short * 0.035).clamp(10.0, 16.0)),
          Padding(
            padding: EdgeInsets.only(top: (short * 0.022).clamp(6.0, 10.0)),
            child: Text(
              label,
              style: TextStyle(
                fontSize: labelFs,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(width: (short * 0.04).clamp(10.0, 18.0)),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd, // by-zbot el mkan ymen aw shmal 7asab el lo8a
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (short * 0.026).clamp(8.0, 12.0),
                  vertical: (short * 0.016).clamp(4.0, 8.0),
                ),
                decoration: BoxDecoration(
                  color: valueColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: valueFs,
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

  Widget _buildEmergencyContacts(PatientProfile profile) {
    final appState = AppState();
    final primary = profile.emergencyContacts['primary'] ?? {};
    final secondary = profile.emergencyContacts['secondary'] ?? {};
    final List<Widget> buildResults = [];

    if (primary.isNotEmpty) {
      String primaryName = primary['name'] ?? '';
      
      buildResults.add(_buildContactRow(
        name: primaryName,
        role: appState.tr(primary['relation'] ?? '', primary['relation'] ?? ''),
      ));
    }
    if (secondary.isNotEmpty) {
      String secondaryName = secondary['name'] ?? '';
      
      buildResults.add(_buildContactRow(
        name: secondaryName,
        role: appState.tr(secondary['relation'] ?? '', secondary['relation'] ?? ''),
      ));
    }

    final short = MediaQuery.of(context).size.shortestSide;
    final sectionFs = (short * 0.042).clamp(15.0, 18.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Emergency Contacts', 'جهات اتصال الطوارئ'),
          style: TextStyle(
            fontSize: sectionFs,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: (short * 0.035).clamp(10.0, 16.0)),
        ...buildResults,
      ],
    );
  }

  Widget _buildContactRow({
    required String name,
    required String role,
  }) {
    final short = MediaQuery.of(context).size.shortestSide;
    final avatarR = (short * 0.056).clamp(18.0, 24.0);
    final phoneBox = (short * 0.1).clamp(36.0, 44.0);
    final nameFs = (short * 0.038).clamp(13.5, 16.0);
    final roleFs = (short * 0.034).clamp(12.0, 14.0);

    return Padding(
      padding: EdgeInsets.only(bottom: (short * 0.032).clamp(10.0, 14.0)),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarR,
            backgroundColor: const Color(0xFFE6F0FE),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: const Color(0xFF1B64F2),
                fontWeight: FontWeight.bold,
                fontSize: (avatarR * 0.55).clamp(12.0, 16.0),
              ),
            ),
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: (short * 0.006).clamp(1.0, 4.0)),
                Text(
                  role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: roleFs,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: phoneBox,
            height: phoneBox,
            decoration: const BoxDecoration(
              color: Color(0xFF1B64F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone,
              color: Colors.white,
              size: (phoneBox * 0.45).clamp(16.0, 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments() {
    final appState = AppState();
    final short = MediaQuery.of(context).size.shortestSide;
    final sectionFs = (short * 0.042).clamp(15.0, 18.0);
    final emptyFs = (short * 0.034).clamp(12.0, 14.0);

    if (_isLoadingDocs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_documents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.tr('Documents', 'المستندات'),
            style: TextStyle(
              fontSize: sectionFs,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: (short * 0.032).clamp(10.0, 14.0)),
          Text(
            appState.tr('No documents uploaded yet.', 'لا توجد مستندات مرفوعة بعد.'),
            style: TextStyle(color: Colors.grey.shade500, fontSize: emptyFs),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.tr('Documents', 'المستندات'),
          style: TextStyle(
            fontSize: sectionFs,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: (short * 0.035).clamp(10.0, 16.0)),
        ..._documents.map((doc) => _buildDocumentRow(
              id: doc['id'] ?? '',
              title: doc['title'] ?? '',
              subtitle: doc['subtitle'] ?? '',
              iconColor: _getDocIconColor(doc['type'] ?? ''),
              icon: _getDocIcon(doc['type'] ?? ''),
              onView: () => _openDocumentViewer(doc),
              onDelete: () => _confirmDeleteDocument(doc),
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
    required String id,
    required String title,
    required String subtitle,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onView,
    required VoidCallback onDelete,
  }) {
    final appState = AppState();
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    final box = (short * 0.1).clamp(36.0, 44.0);
    final iconS = (box * 0.48).clamp(17.0, 22.0);
    final titleFs = (short * 0.036).clamp(13.0, 15.0);
    final subFs = (short * 0.032).clamp(11.0, 13.0);
    final actionFs = (short * 0.036).clamp(13.0, 15.0);
    final gap = (short * 0.035).clamp(10.0, 16.0);

    return Padding(
      padding: EdgeInsets.only(bottom: (short * 0.038).clamp(12.0, 16.0)),
      child: Row(
        children: [
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular((w * 0.025).clamp(8.0, 12.0)),
            ),
            child: Icon(icon, color: iconColor, size: iconS),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFs,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: (short * 0.006).clamp(1.0, 4.0)),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subFs,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
              size: iconS,
            ),
          ),
          SizedBox(width: gap),
          GestureDetector(
            onTap: onView,
            child: Text(
              appState.tr('View', 'عرض'),
              style: TextStyle(
                fontSize: actionFs,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B64F2).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    final appState = AppState();
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final pad = (short * 0.045).clamp(14.0, 20.0);
    final radius = (w * 0.035).clamp(12.0, 16.0);
    final lockS = (short * 0.052).clamp(18.0, 22.0);
    final bodyFs = (short * 0.034).clamp(12.0, 14.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(radius),
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
            size: lockS,
          ),
          SizedBox(width: (short * 0.03).clamp(8.0, 14.0)),
          Expanded(
            child: Text(
              appState.tr(
                'You can securely share this vault with medical professionals or emergency helpers when assistance is required. All data is encrypted and only accessible via your permission.',
                'يمكنك مشاركة هذه الخزنة بأمان مع المتخصصين الطبيين أو مساعدي الطوارئ عند الحاجة. جميع البيانات مشفرة ولا يمكن الوصول إليها إلا بإذنك.',
              ),
              style: TextStyle(
                fontSize: bodyFs,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocumentViewer(Map<String, String> doc) async {
    final fileRef = doc['file_url'] ?? '';
    if (fileRef.isEmpty) return;

    try {
      final targetUrl = fileRef.startsWith('http')
          ? fileRef
          : await SupabaseService().createVaultDocumentSignedUrl(fileRef);
      final signedUrl = targetUrl;
      final uri = Uri.parse(signedUrl);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _shareVault() {
    final appState = AppState();
    final summary = StringBuffer()
      ..writeln('QLink Vault - ${widget.profile.profileName}')
      ..writeln('Medical Summary:')
      ..writeln('Blood Type: ${widget.profile.bloodType}')
      ..writeln('Condition: ${widget.profile.medicalNotesEn}')
      ..writeln('Allergies: ${widget.profile.allergiesEn}')
      ..writeln('Documents: ${_documents.length}');
    Clipboard.setData(ClipboardData(text: summary.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.tr('Vault summary copied. You can paste and share it.', 'تم نسخ ملخص الخزنة. يمكنك لصقه ومشاركته.')),
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    final appState = AppState();
    try {
      final result = await FilePicker.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(appState.tr('Failed to read selected file', 'تعذر قراءة الملف المحدد'))),
          );
        }
        return;
      }

      final ext = (file.extension ?? '').toUpperCase();
      final mappedType = ext == 'JPEG' ? 'JPG' : ext;
      final title = (file.name.split('.').first).trim();
      await _createVaultRowAndRefresh(
        title: title.isEmpty ? file.name : title,
        type: mappedType,
        fileName: file.name,
        bytes: bytes,
        fileSizeKb: (file.size / 1024).ceil(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createVaultRowAndRefresh({
    required String title,
    required String type,
    required String fileName,
    required Uint8List bytes,
    required int fileSizeKb,
  }) async {
    try {
      final guardianId = SupabaseService().client.auth.currentUser?.id;
      if (guardianId == null || widget.profile.id.isEmpty) return;

      final contentType = switch (type) {
        'PDF' => 'application/pdf',
        'DOCX' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'PNG' => 'image/png',
        'JPG' => 'image/jpeg',
        _ => 'application/octet-stream',
      };
      final storagePath = await SupabaseService().uploadVaultDocumentBytes(
        bytes: bytes,
        guardianId: guardianId,
        profileId: widget.profile.id,
        fileName: fileName,
        contentType: contentType,
      );

      await SupabaseService().createVaultDocument(
        profileId: widget.profile.id,
        guardianId: guardianId,
        title: title,
        fileUrl: storagePath,
        fileType: type,
        fileSizeKb: fileSizeKb,
      );
      await _loadVaultDocs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDeleteDocument(Map<String, String> doc) async {
    final appState = AppState();
    final docId = doc['id'] ?? '';
    if (docId.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appState.tr('Delete Document', 'حذف المستند')),
        content: Text(
          appState.tr(
            'Are you sure you want to delete this document?',
            'هل أنت متأكد أنك تريد حذف هذا المستند؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appState.tr('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              appState.tr('Delete', 'حذف'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await SupabaseService().deleteVaultDocument(
        documentId: docId,
        storagePath: doc['file_url'],
      );
      await _loadVaultDocs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.tr('Document deleted', 'تم حذف المستند'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}