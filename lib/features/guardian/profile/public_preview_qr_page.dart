import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/widgets/language_toggle.dart';
import 'package:q_link/core/utils/emergency_profile_parse.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class PublicPreviewQrPage extends StatefulWidget {
  final ProfileData profile;

  /// When `true`, server (RPC) or another path already sent the `qr_scan` notification.
  final bool skipGuardianNotify;

  const PublicPreviewQrPage({
    super.key,
    required this.profile,
    this.skipGuardianNotify = false,
  });

  @override
  State<PublicPreviewQrPage> createState() => _PublicPreviewQrPageState();
}

class _PublicPreviewQrPageState extends State<PublicPreviewQrPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.skipGuardianNotify) {
      _notifyGuardian();
    }
  }

  Future<void> _notifyGuardian() async {
    final client = Supabase.instance.client;
    String? guardianId;
    if (widget.profile.id != null && widget.profile.id!.isNotEmpty) {
      try {
        final patient = await client
            .from('patient_profiles')
            .select('guardian_id')
            .eq('id', widget.profile.id!)
            .maybeSingle();
        guardianId = patient?['guardian_id']?.toString();
      } catch (_) {}
    }
    guardianId ??= client.auth.currentUser?.id;
    if (guardianId == null || guardianId.isEmpty) return;

    try {
      await client.from('notifications').insert({
        'id': const Uuid().v4(),
        'guardian_id': guardianId,
        'profile_id': widget.profile.id ?? guardianId,
        'title': 'Bracelet Scanned! 🚨',
        'body': 'Someone is viewing the profile of ${widget.profile.name}',
        'type': 'qr_scan',
        'is_read': false,
      });
    } catch (e) {
      debugPrint('[Notify] error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: const Color(0xFF131A2A), // Dark blue background
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Red Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F), // Red background
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(appState.tr('Close Preview', 'إغلاق المعاينة'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const LanguageToggle(),
                        ],
                      ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(AppState().tr('Emergency Info', 'معلومات الطوارئ'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.profile.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppState().tr('This is what rescues see when they scan\nthe QR code', 'هذا ما يراه المنقذون عند مسح\nرمز QR الخاص بك'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                  if (_previewVisibility().showRelationship && widget.profile.relationship.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.profile.relationship,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildPublicEmergencyCards(),
              ),
            ),

            // Footer Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              color: const Color(0xFF1E293B), // Slightly lighter dark blue for footer
              child: Column(
                children: [
                  Text(
                    AppState().tr('Stay Protected with Qlink!', 'ابقَ محميًا مع كيولينك!'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppState().tr(
                      'Qlink helps protect you and your loved ones\nby providing instant access to critical\nMedical information during emergencies.',
                      'تساعد شركة كيولينك في حمايتك وحماية أحبائك\nمن خلال توفير وصول فوري إلى المعلومات\nالطبية الهامة أثناء حالات الطوارئ.'
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(AppState().tr('Install the App', 'تثبيت التطبيق'), style: const TextStyle(color: Color(0xFF131A2A), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(AppState().tr('Create Account', 'إنشاء حساب'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(AppState().tr('Privacy Policy', 'سياسة الخصوصية'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text(AppState().tr('Terms of Service', 'شروط الخدمة'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text(AppState().tr('Support', 'الدعم'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(AppState().tr('© 2026 Qlink Emergency. All rights reserved.', '© 2026 كيولينك لخدمات الطوارئ. جميع الحقوق محفوظة.'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  /// Uses per-profile cached toggles from [AppState] when set (privacy screen), else [ProfileData.visibility].
  VisibilitySettings _previewVisibility() {
    return AppState().qrVisibilitySettingsFor(widget.profile.id) ?? widget.profile.visibility;
  }

  /// Cards shown after a QR scan respect [ProfileData.visibility] (privacy toggles).
  List<Widget> _buildPublicEmergencyCards() {
    final v = _previewVisibility();
    final showAllergiesCard = v.showAllergies && widget.profile.allergies.isNotEmpty;
    final showBloodCard = v.showBloodType && widget.profile.bloodType.isNotEmpty;
    final showAgeCard = v.showBirthYear && widget.profile.birthYear.isNotEmpty;
    final showMedical = v.showMedicalNotes && widget.profile.condition.isNotEmpty;
    final showContacts = v.showEmergencyContacts &&
        (widget.profile.emergencyDialRows.isNotEmpty || widget.profile.emergencyContacts.isNotEmpty);

    final children = <Widget>[];

    if (showAllergiesCard) {
      children.add(_buildInfoCard(AppState().tr('Allergies', 'الحساسية'), widget.profile.allergies));
    }

    if (showBloodCard || showAgeCard) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 16));
      children.add(
        Row(
          children: [
            if (showBloodCard)
              Expanded(
                child: _buildInfoCard(
                  AppState().tr('Blood Type', 'فصيلة الدم'),
                  widget.profile.bloodType,
                ),
              ),
            if (showBloodCard && showAgeCard) const SizedBox(width: 16),
            if (showAgeCard)
              Expanded(
                child: _buildInfoCard(
                  AppState().tr('Age', 'العمر'),
                  _calculateAge(widget.profile.birthYear),
                ),
              ),
          ],
        ),
      );
    }

    if (showMedical) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 16));
      children.add(_buildInfoCard(AppState().tr('Medical Notes', 'ملاحظات طبية'), widget.profile.condition));
    }

    if (showContacts) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 16));
      children.add(_buildEmergencyContactsSection());
    }

    return children;
  }

  String _calculateAge(String birthYearField) {
    final y = parseBirthYearFromRowField(birthYearField);
    if (y == null) {
      return birthYearField.trim().isEmpty ? '—' : birthYearField.trim();
    }
    final age = DateTime.now().year - y;
    if (age < 0 || age > 130) return '—';
    return '$age ${AppState().tr('years', 'سنة')}';
  }

  Future<void> _dialPhone(String raw) async {
    final cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoCard(String title, String content) {
    // Basic formatting constraint to match mockup style
    List<String> items = content.split('\n');
    if (items.length == 1 && items[0].contains(',')) {
      items = items[0].split(',').map((e) => e.trim()).toList();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          const SizedBox(height: 12),
          if (items.length > 1)
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $item', style: const TextStyle(color: Colors.white, fontSize: 14)),
                ))
          else
            Text(content, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    if (widget.profile.emergencyDialRows.isNotEmpty) {
      return _buildEmergencyDialRows(widget.profile.emergencyDialRows);
    }
    return _buildLegacyEmergencyStrings(widget.profile.emergencyContacts);
  }

  Widget _buildEmergencyDialRows(List<EmergencyDialRow> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppState().tr('Emergency Contacts', 'جهات اتصال الطوارئ'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (row.title.isNotEmpty)
                              Text(
                                row.title,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            if (row.phone.isNotEmpty)
                              Text(
                                row.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 0.8),
                              )
                            else if (row.title.isNotEmpty)
                              Text(
                                row.title,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
                          ],
                        ),
                      ),
                      if (row.canDial)
                        Material(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _dialPhone(row.phone),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.call, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLegacyEmergencyStrings(List<String> contacts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppState().tr('Emergency Contacts', 'جهات اتصال الطوارئ'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          const SizedBox(height: 16),
          ...contacts.map((contact) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(contact, style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1.1)),
                    ),
                    Material(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _dialPhone(contact),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.call, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
