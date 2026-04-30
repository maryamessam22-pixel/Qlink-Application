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
        final short = MediaQuery.of(context).size.shortestSide;
        final w = MediaQuery.of(context).size.width;
        final hPad = (w * 0.06).clamp(16.0, 28.0);
        return Scaffold(
          backgroundColor: _activeTab == 1 ? Colors.black : const Color(0xFFF7F9FC),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(hPad),
                  child: const WearerHeader(),
                ),
                
                // Unified Tab Switcher
                Container(
                  margin: EdgeInsets.symmetric(horizontal: hPad),
                  height: (short * 0.17).clamp(56.0, 68.0),
                  decoration: BoxDecoration(
                    color: _activeTab == 1 ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF1B64F2),
                    borderRadius: BorderRadius.circular((w * 0.04).clamp(12.0, 18.0)),
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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final hPad = (w * 0.06).clamp(16.0, 28.0);
    final bottomPad = mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, bottomPad),
      child: FutureBuilder<(PatientProfile?, String?)>(
        future: _myQrPack,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.only(top: (short * 0.3).clamp(90.0, 130.0)),
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
          SizedBox(height: (short * 0.1).clamp(28.0, 44.0)),
          Text(
            appState.tr('Wearer Profile QR', 'رمز QR لملف المرتدي'),
            style: TextStyle(
              fontSize: (short * 0.07).clamp(22.0, 28.0),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF273469),
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
              fontSize: (short * 0.038).clamp(14.0, 16.0),
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
              fontSize: (short * 0.03).clamp(11.0, 13.0),
              color: const Color(0xFF273469).withValues(alpha: 0.55),
              height: 1.35,
            ),
          ),

          SizedBox(height: (short * 0.12).clamp(34.0, 54.0)),
          
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
              padding: EdgeInsets.all((short * 0.08).clamp(24.0, 36.0)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular((w * 0.08).clamp(24.0, 36.0)),
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
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                size: (short * 0.55).clamp(180.0, 220.0),
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1B64F2)),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1B64F2)),
              ),
            ),
          ),
          
          SizedBox(height: (short * 0.2).clamp(56.0, 88.0)),
          
          // Share Button
          Container(
            width: double.infinity,
            height: (short * 0.16).clamp(54.0, 64.0),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular((short * 0.08).clamp(24.0, 32.0)),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (short * 0.04).clamp(14.0, 17.0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
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
            width: (MediaQuery.of(context).size.shortestSide * 0.68).clamp(220.0, 280.0),
            height: (MediaQuery.of(context).size.shortestSide * 0.68).clamp(220.0, 280.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1B64F2), width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          bottom: (MediaQuery.of(context).size.shortestSide * 0.3).clamp(92.0, 132.0),
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                appState.tr('Scan Guardian QR', 'مسح QR الوصي'),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: (MediaQuery.of(context).size.shortestSide * 0.03).clamp(8.0, 14.0)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width * 0.1).clamp(28.0, 46.0)),
                child: Text(
                  appState.tr('Scan another user\'s code to link accounts or view public info.', 'امسح رمز مستخدم آخر لربط الحسابات أو عرض المعلومات العامة.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              SizedBox(height: (MediaQuery.of(context).size.shortestSide * 0.12).clamp(34.0, 52.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScannerAction(LucideIcons.image, () {}),
                  SizedBox(width: (MediaQuery.of(context).size.shortestSide * 0.06).clamp(18.0, 28.0)),
                  _buildScannerAction(LucideIcons.scan, () {}, isPrimary: true),
                  SizedBox(width: (MediaQuery.of(context).size.shortestSide * 0.06).clamp(18.0, 28.0)),
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
