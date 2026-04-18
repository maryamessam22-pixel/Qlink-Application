import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class PublicPreviewQrPage extends StatelessWidget {
  final ProfileData profile;

  const PublicPreviewQrPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
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
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(AppState().tr('Close Preview', 'إغلاق المعاينة'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
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
                    profile.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppState().tr('This is what rescues see when they scan\nthe QR code', 'هذا ما يراه المنقذون عند مسح\nرمز QR الخاص بك'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (profile.visibility.showAllergies && profile.allergies.isNotEmpty)
                    _buildInfoCard(AppState().tr('Allergies', 'الحساسية'), profile.allergies),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (profile.visibility.showBloodType && profile.bloodType.isNotEmpty)
                        Expanded(child: _buildInfoCard(AppState().tr('Blood Type', 'فصيلة الدم'), profile.bloodType)),
                      if (profile.visibility.showBloodType && profile.bloodType.isNotEmpty && profile.visibility.showBirthYear && profile.birthYear.isNotEmpty)
                        const SizedBox(width: 16),
                      if (profile.visibility.showBirthYear && profile.birthYear.isNotEmpty)
                        Expanded(child: _buildInfoCard(AppState().tr('Age', 'العمر'), _calculateAge(profile.birthYear))),
                    ],
                  ),

                  if (profile.visibility.showMedicalNotes && profile.condition.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(AppState().tr('Medical Notes', 'ملاحظات طبية'), profile.condition),
                  ],

                  if (profile.visibility.showEmergencyContacts && profile.emergencyContacts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildEmergencyContacts(profile.emergencyContacts),
                  ],
                ],
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
  }

  String _calculateAge(String birthYear) {
    int? year = int.tryParse(birthYear);
    if (year != null) {
      int currentYear = DateTime.now().year;
      return '${currentYear - year} ${AppState().tr('years', 'سنة')}';
    }
    return birthYear;
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

  Widget _buildEmergencyContacts(List<String> contacts) {
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
                    Text(contact, style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1.1)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.call, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
