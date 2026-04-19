import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';

class WearerPublicPreviewQrPage extends StatelessWidget {
  const WearerPublicPreviewQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/Mohamed Saber.png'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mohamed Saber',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF273469),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.tr('Emergency Profile', 'ملف الطوارئ الشخصي'),
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
                _buildInfoTile(appState, Icons.bloodtype, appState.tr('Blood Type', 'فصيلة الدم'), 'O+'),
                _buildInfoTile(appState, Icons.warning_amber, appState.tr('Allergies', 'الحساسية'), 'Penicillin, Peanuts'),
                _buildInfoTile(appState, Icons.medical_services, appState.tr('Medical Notes', 'ملاحظات طبية'), 'Diabetic Type 2, Hypertension'),
                const SizedBox(height: 40),
                Text(
                  appState.tr('Emergency Contacts', 'جهات اتصال الطوارئ'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF273469),
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactTile(appState, 'Mariam Essam', '+20 111 9988299'),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(AppState appState, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF273469)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(AppState appState, String name, String phone) {
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF273469))),
                Text(phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
