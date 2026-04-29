import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/models/patient_profile.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/shared/helpers/emergency_qr_scan.dart';
import 'package:q_link/features/wearer/presentation/widgets/wearer_header.dart';
import 'package:q_link/services/supabase_service.dart';

class WearerQrPage extends StatefulWidget {
  const WearerQrPage({super.key});

  @override
  State<WearerQrPage> createState() => _WearerQrPageState();
}

class _WearerQrPageState extends State<WearerQrPage> {
  int _activeTab = 0;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _scanBusy = false;
  late Future<(PatientProfile?, String?)> _myQrPack;

  @override
  void initState() {
    super.initState();
    _myQrPack = _loadWearQrPayload();
  }

  Future<(PatientProfile?, String?)> _loadWearQrPayload() async {
    final p = await SupabaseService().fetchWearerPatientProfile();
    if (p == null || p.id.isEmpty) return (null, null);
    final token = await SupabaseService().ensurePublicQrToken(p.id);
    final payload = token != null && token.isNotEmpty
        ? SupabaseService().buildPublicEmergencyQrPayload(token)
        : 'qlink://profile/${p.id}';
    return (p, payload);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _activeTab == 1 ? Colors.black : const Color(0xFFF7F9FC),
          body: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: WearerHeader(),
                ),
                
                // Unified Tab Switcher
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 64,
                  decoration: BoxDecoration(
                    color: _activeTab == 1 ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF1B64F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, LucideIcons.qrCode, appState.tr('My Code', 'كودي')),
                      _buildTabItem(1, LucideIcons.camera, appState.tr('Scanner', 'الماسح')),
                    ],
                  ),
                ),
                
                Expanded(
                  child: _activeTab == 0 ? _buildMyCodeView(appState) : _buildScannerView(appState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? (_activeTab == 1 ? const Color(0xFF1B64F2) : Colors.transparent) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCodeView(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FutureBuilder<(PatientProfile?, String?)>(
        future: _myQrPack,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF1B64F2))),
            );
          }
          final tuple = snap.data ?? (null, null);
          final wearerProfile = tuple.$1;
          final qrPayload = tuple.$2;

          final noProfile =
              wearerProfile == null || qrPayload == null || qrPayload.isEmpty;

          return Column(
        children: [
          const SizedBox(height: 40),
          Text(
            appState.tr('Wearer Profile QR', 'رمز QR لملف المرتدي'),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF273469),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            appState.tr(
              'Anyone can scan this to see your emergency medical info and contact your guardians.',
              'يمكن لأي شخص مسح هذا لمعرفة معلوماتك الطبية الطارئة والاتصال بأوصيائك.'
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF273469).withValues(alpha: 0.6),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            appState.tr(
              'This QR uses HTTPS — your phone camera can open it in the browser. The Scanner tab loads the preview in QLink.',
              'رمز HTTPS — كاميرا الهاتف تفتحه في المتصفح. تبويب «الماسح» يعرض المعاينة داخل التطبيق.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF273469).withValues(alpha: 0.55),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 50),
          
          if (noProfile)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                appState.tr(
                  'No linked profile yet. Complete setup with your guardian to use your QR.',
                  'لا يوجد ملف مرتبط بعد. أكمل الإعداد مع الوصي لاستخدام الرمز.'
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.45),
              ),
            )
          else
          GestureDetector(
            onTap: () => _showEmergencyDialog(appState),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrPayload,
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1B64F2)),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1B64F2)),
              ),
            ),
          ),
          
          const SizedBox(height: 80),
          
          // Share Button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
              label: Text(
                appState.tr('Share QR Code', 'مشاركة رمز QR'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          
          const           SizedBox(height: 100),
        ],
          );
        },
      ),
    );
  }

  Widget _buildScannerView(AppState appState) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) async {
            if (_scanBusy) return;
            final barcodes = capture.barcodes;
            if (barcodes.isEmpty) return;
            final raw = barcodes.first.rawValue;
            if (raw == null || raw.trim().isEmpty) return;
            _scanBusy = true;
            try {
              await navigateEmergencyPreviewFromQrRaw(context, raw);
            } finally {
              if (mounted) _scanBusy = false;
            }
          },
        ),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1B64F2), width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                appState.tr('Scan Guardian QR', 'مسح QR الوصي'),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  appState.tr('Scan another user\'s code to link accounts or view public info.', 'امسح رمز مستخدم آخر لربط الحسابات أو عرض المعلومات العامة.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScannerAction(LucideIcons.image, () {}),
                  const SizedBox(width: 24),
                  _buildScannerAction(LucideIcons.scan, () {}, isPrimary: true),
                  const SizedBox(width: 24),
                  _buildScannerAction(LucideIcons.flashlight, () => _scannerController.toggleTorch()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannerAction(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 70 : 52,
        height: isPrimary ? 70 : 52,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: isPrimary ? null : Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: isPrimary ? const Color(0xFF1B64F2) : Colors.white, size: isPrimary ? 32 : 24),
      ),
    );
  }

  void _showEmergencyDialog(AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shieldAlert, color: Color(0xFF1B64F2), size: 48),
            const SizedBox(height: 20),
            Text(
              appState.tr('Emergency Access', 'الوصول في حالات الطوارئ'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF273469)),
            ),
            const SizedBox(height: 12),
            Text(
              appState.tr(
                'This QR code allows first responders to see your medical ID and contact your primary guardians immediately.',
                'يسمح رمز QR هذا للمستجيبين الأوائل برؤية هويتك الطبية والاتصال بأوصيائك الأساسيين على الفور.'
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B64F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text(
                  appState.tr('Got it', 'فهمت'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
