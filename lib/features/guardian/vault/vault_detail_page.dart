import 'package:flutter/material.dart';
import 'dart:typed_data';
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

  @override
  void initState() {
    super.initState();
    _documents = List<Map<String, String>>.from(widget.documents);
    _loadVaultDocs();
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
                  _buildProfileHeader(widget.profile),
                  const SizedBox(height: 28),
                  _buildMedicalSummary(widget.profile),
                  const SizedBox(height: 28),
                  _buildEmergencyContacts(widget.profile),
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
        GestureDetector(
          onTap: _showUploadDialog,
          child: Icon(
            Icons.file_upload_outlined,
            color: Colors.grey.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _shareVault,
          child: Icon(
            Icons.share_outlined,
            color: Colors.grey.shade600,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(PatientProfile profile) {
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
            backgroundImage: getUserAvatarProvider(
              profile.avatarUrl.isNotEmpty ? profile.avatarUrl : 'assets/images/mypic.png',
            ),
            onBackgroundImageError: (_, __) {},
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

  Widget _buildMedicalSummary(PatientProfile profile) {
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
          Expanded(
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE6F0FE),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFF1B64F2),
                fontWeight: FontWeight.bold,
              ),
            ),
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
    if (_isLoadingDocs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_documents.isEmpty) {
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
          const SizedBox(height: 12),
          Text(
            appState.tr('No documents uploaded yet.', 'لا توجد مستندات مرفوعة بعد.'),
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      );
    }
    
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
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onView,
            child: Text(
              appState.tr('View', 'عرض'),
              style: TextStyle(
                fontSize: 14,
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