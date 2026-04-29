import 'package:flutter/material.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/supabase_service.dart';

class WearerPublicPreviewQrPage extends StatefulWidget {
  const WearerPublicPreviewQrPage({super.key});

  @override
  State<WearerPublicPreviewQrPage> createState() =>
      _WearerPublicPreviewQrPageState();
}

class _WearerPublicPreviewQrPageState extends State<WearerPublicPreviewQrPage> {
  late Future<PatientProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SupabaseService().fetchWearerPatientProfile();
  }

  Widget _buildAvatar(PatientProfile profile) {
    final url = profile.avatarUrl;
    if (url.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFF273469),
        child: Text(
          profile.profileName.isNotEmpty
              ? profile.profileName[0].toUpperCase()
              : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
        ),
      );
    }
    if (url.startsWith('assets')) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(url),
      );
    }
    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF273469)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              appState.tr('Public Preview', 'معاينة عامة'),
              style: const TextStyle(
                color: Color(0xFF273469),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: FutureBuilder<PatientProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = snapshot.data;

              if (profile == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          appState.tr(
                            'No profile found. Ask your guardian to create one.',
                            'لم يتم العثور على ملف شخصي. اطلب من وليك إنشاء واحد.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Build contact tiles from emergency_contacts map
              final contacts = <Widget>[];
              profile.emergencyContacts.forEach((key, value) {
                if (value is Map) {
                  final name = value['name']?.toString() ?? '';
                  final phone = value['phone']?.toString() ?? '';
                  if (name.isNotEmpty || phone.isNotEmpty) {
                    contacts.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildContactTile(name, phone),
                      ),
                    );
                  }
                }
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildAvatar(profile),
                            const SizedBox(height: 16),
                            Text(
                              profile.profileName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF273469),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.tr(
                                  'Emergency Profile', 'ملف الطوارئ الشخصي'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (profile.bloodType.isNotEmpty)
                      _buildInfoTile(
                        appState,
                        Icons.bloodtype,
                        appState.tr('Blood Type', 'فصيلة الدم'),
                        profile.bloodType,
                      ),
                    if (appState.isArabic
                        ? profile.allergiesAr.isNotEmpty
                        : profile.allergiesEn.isNotEmpty)
                      _buildInfoTile(
                        appState,
                        Icons.warning_amber,
                        appState.tr('Allergies', 'الحساسية'),
                        appState.isArabic
                            ? profile.allergiesAr
                            : profile.allergiesEn,
                      ),
                    if (appState.isArabic
                        ? profile.medicalNotesAr.isNotEmpty
                        : profile.medicalNotesEn.isNotEmpty)
                      _buildInfoTile(
                        appState,
                        Icons.medical_services,
                        appState.tr('Medical Notes', 'ملاحظات طبية'),
                        appState.isArabic
                            ? profile.medicalNotesAr
                            : profile.medicalNotesEn,
                      ),
                    if (contacts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        appState.tr(
                            'Emergency Contacts', 'جهات اتصال الطوارئ'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF273469),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...contacts,
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(
      AppState appState, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B64F2), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF273469)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String name, String phone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Color(0xFF22C55E)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF273469))),
                if (phone.isNotEmpty)
                  Text(phone,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
