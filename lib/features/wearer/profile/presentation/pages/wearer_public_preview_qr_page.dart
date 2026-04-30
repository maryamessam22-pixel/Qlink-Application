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
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.06).clamp(16.0, 28.0);
        final listBottom = mq.padding.bottom + (short * 0.08).clamp(24.0, 40.0);
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, listBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all((short * 0.04).clamp(12.0, 18.0)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular((w * 0.05).clamp(14.0, 22.0)),
                        ),
                        child: Column(
                          children: [
                            _buildAvatar(profile),
                            SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                            Text(
                              profile.profileName,
                              style: TextStyle(
                                fontSize: (short * 0.058).clamp(20.0, 24.0),
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF273469),
                              ),
                            ),
                            SizedBox(height: (short * 0.01).clamp(2.0, 6.0)),
                            Text(
                              appState.tr(
                                  'Emergency Profile', 'ملف الطوارئ الشخصي'),
                              style: TextStyle(
                                fontSize: (short * 0.036).clamp(13.0, 15.0),
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
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
                      SizedBox(height: (short * 0.06).clamp(16.0, 26.0)),
                      Text(
                        appState.tr(
                            'Emergency Contacts', 'جهات اتصال الطوارئ'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF273469),
                        ),
                      ),
                      SizedBox(height: (short * 0.04).clamp(12.0, 18.0)),
                      ...contacts,
                    ],
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
      padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.shortestSide * 0.05).clamp(14.0, 22.0)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all((MediaQuery.of(context).size.shortestSide * 0.03).clamp(10.0, 14.0)),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B64F2), size: 24),
          ),
          SizedBox(width: (MediaQuery.of(context).size.shortestSide * 0.04).clamp(12.0, 18.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.shortestSide * 0.036).clamp(13.0, 15.0),
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: (MediaQuery.of(context).size.shortestSide * 0.006).clamp(1.0, 4.0)),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.shortestSide * 0.04).clamp(14.0, 17.0),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF273469)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String name, String phone) {
    final short = MediaQuery.of(context).size.shortestSide;
    final w = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all((short * 0.04).clamp(12.0, 18.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((w * 0.04).clamp(12.0, 18.0)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Color(0xFF22C55E)),
          SizedBox(width: (short * 0.04).clamp(12.0, 18.0)),
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
