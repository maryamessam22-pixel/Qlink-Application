import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/profile/public_preview_qr_page.dart';
import 'package:q_link/features/shared/helpers/emergency_qr_scan.dart';
import 'package:q_link/services/supabase_service.dart';

class EmergencyQrPage extends StatefulWidget {
  final ProfileData profile;

  const EmergencyQrPage({super.key, required this.profile});

  @override
  State<EmergencyQrPage> createState() => _EmergencyQrPageState();
}

class _EmergencyQrPageState extends State<EmergencyQrPage> {
  int _activeTab = 0;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isHandlingScan = false;

  bool _loadingQrPayload = false;
  String _displayQrPayload = '';

  @override
  void initState() {
    super.initState();
    final id = widget.profile.id?.trim();
    if (id != null && id.isNotEmpty) {
      _loadingQrPayload = true;
      SupabaseService().ensurePublicQrToken(id).then((token) {
        if (!mounted) return;
        setState(() {
          _loadingQrPayload = false;
          if (token != null && token.isNotEmpty) {
            _displayQrPayload = SupabaseService().buildPublicEmergencyQrPayload(token);
          } else {
            _displayQrPayload = 'qlink://profile/$id';
          }
          if (kDebugMode && _displayQrPayload.isNotEmpty) {
            debugPrint('[Emergency QR] ${_displayQrPayload.length} chars: $_displayQrPayload');
          }
        });
      });
    } else {
      _displayQrPayload = 'qlink-profile-${widget.profile.name}';
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _activeTab == 1 ? Colors.black : const Color(0xFFF7F9FC),
          body: Stack(
            children: [
              if (_activeTab == 0)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg.png'),
                      fit: BoxFit.cover,
                      opacity: 0.05,
                    ),
                  ),
                ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: _activeTab == 1 ? Colors.white : const Color(0xFF1E3A8A),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  appState.tr('Back', 'رجوع'),
                                  style: TextStyle(
                                    color: _activeTab == 1 ? Colors.white : const Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (ctx) {
                        final sh = MediaQuery.sizeOf(ctx).shortestSide;
                        final tabH = (sh * 0.17).clamp(56.0, 72.0);
                        return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      height: tabH,
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
                    );
                      },
                    ),
                    Expanded(
                      child: _activeTab == 0 ? _buildMyCodeView(appState) : _buildScannerView(appState),
                    ),
                  ],
                ),
              ),
            ],
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCodeView(AppState appState) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final short = mq.size.shortestSide;
    final hPad = (w * 0.055).clamp(16.0, 40.0);
    final qrSize = (w * 0.58).clamp(180.0, 280.0);
    final padQr = (short * 0.06).clamp(16.0, 32.0);
    final bottomPad =
        mq.viewInsets.bottom + mq.padding.bottom + (short * 0.04).clamp(12.0, 28.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomPad),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: (short * 0.06).clamp(16.0, 48.0)),
                Text(
                  appState.tr('Emergency Profile QR', 'رمز QR للملف الشخصي للطوارئ'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (w * 0.06).clamp(20.0, 26.0),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: (short * 0.028).clamp(8.0, 14.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Text(
                    appState.tr('Anyone can scan this to see your emergency info.', 'يمكن لأي شخص مسح هذا لمعرفة معلومات الطوارئ الخاصة بك.'),
                    style: TextStyle(
                      fontSize: (w * 0.038).clamp(13.0, 16.0),
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: (short * 0.02).clamp(6.0, 12.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (w * 0.06).clamp(20.0, 36.0)),
                  child: Text(
                    appState.tr(
                      'This QR uses HTTPS — your phone camera can open it in the browser. The Scanner tab in this app loads the preview inside QLink.',
                      'هذا الرمز يعتمد HTTPS — يمكن كاميرا الهاتف فتحه في المتصفح. تبويب «الماسح» يعرض المعاينة داخل التطبيق.',
                    ),
                    style: TextStyle(
                      fontSize: (w * 0.03).clamp(11.0, 13.0),
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: (short * 0.06).clamp(20.0, 40.0)),
                GestureDetector(
                  onTap: () => _showAccessSimulationDialog(appState),
                  child: Container(
                    padding: EdgeInsets.all(padQr),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _loadingQrPayload
                        ? SizedBox(
                            width: qrSize,
                            height: qrSize,
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF1B64F2)),
                            ),
                          )
                        : QrImageView(
                            data: _displayQrPayload.isNotEmpty ? _displayQrPayload : 'qlink-profile-${widget.profile.name}',
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            size: qrSize,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1B64F2)),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1B64F2)),
                          ),
                  ),
                ),
                SizedBox(height: (short * 0.08).clamp(24.0, 48.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(LucideIcons.share2, size: (short * 0.045).clamp(16.0, 20.0)),
                      label: Text(
                        appState.tr('Share QR Code', 'مشاركة رمز QR'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: (w * 0.04).clamp(14.0, 17.0),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B64F2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: (short * 0.055).clamp(14.0, 22.0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: (short * 0.03).clamp(8.0, 16.0)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerView(AppState appState) {
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final bottomOverlay = mq.padding.bottom + mq.viewInsets.bottom + (short * 0.12).clamp(32.0, 72.0);
    final topFlash = mq.padding.top + (short * 0.04).clamp(12.0, 28.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.maxWidth * 0.68).clamp(180.0, 300.0);
        final scanLineTop = side * 0.5;

        return Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                _handleScanCapture(capture);
              },
            ),
            Center(
              child: Container(
                width: side,
                height: side,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1B64F2), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: scanLineTop,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B64F2).withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          color: const Color(0xFF1B64F2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: bottomOverlay,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appState.tr('Scan QR Code', 'مسح رمز QR'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (w * 0.05).clamp(17.0, 22.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: (short * 0.028).clamp(8.0, 14.0)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (w * 0.08).clamp(20.0, 44.0)),
                    child: Text(
                      appState.tr('Center the QR code inside the frame to get the data of patient', 'ضع رمز QR داخل الإطار للحصول على بيانات المريض'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: (w * 0.035).clamp(12.0, 15.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: (short * 0.05).clamp(20.0, 36.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircleAction(LucideIcons.image, () {}),
                      SizedBox(width: (w * 0.055).clamp(16.0, 28.0)),
                      _buildCircleAction(LucideIcons.scan, () {}, isPrimary: true),
                      SizedBox(width: (w * 0.055).clamp(16.0, 28.0)),
                      _buildCircleAction(LucideIcons.refreshCcw, () => _scannerController.switchCamera()),
                    ],
                  ),
                  SizedBox(height: (short * 0.05).clamp(20.0, 36.0)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (w * 0.12).clamp(40.0, 72.0)),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(LucideIcons.keyboard, size: (short * 0.045).clamp(16.0, 20.0)),
                      label: Text(appState.tr('Enter Code Manually', 'أدخل الرمز يدوياً')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: EdgeInsets.symmetric(
                          vertical: (short * 0.04).clamp(12.0, 18.0),
                          horizontal: (w * 0.05).clamp(16.0, 28.0),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: topFlash,
              right: (w * 0.045).clamp(12.0, 22.0),
              child: _buildCircleAction(LucideIcons.flashlight, () => _scannerController.toggleTorch()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleScanCapture(BarcodeCapture capture) async {
    if (_isHandlingScan) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _isHandlingScan = true;
    try {
      await navigateEmergencyPreviewFromQrRaw(context, raw);
    } finally {
      if (mounted) _isHandlingScan = false;
    }
  }

  void _showAccessSimulationDialog(AppState appState) {
    final TextEditingController phoneController = TextEditingController(text: '+20 ');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(LucideIcons.shieldAlert, color: Color(0xFF1B64F2), size: 48),
            const SizedBox(height: 20),
            Text(
              appState.tr(
                'QR Code Captured!',
                'تم التقاط رمز QR..'
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            Text(
              appState.tr(
                'Please enter your phone number for secure access to patient data.',
                'يرجى إدخل رقم هاتفك للوصول الآمن لبيانات المريض.'
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textAlign: appState.isArabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: appState.tr('+20 000 000 0000', '+20 000 000 0000'),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                prefixIcon: const Icon(LucideIcons.phone, size: 20, color: Color(0xFF1B64F2)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final phoneNumber = phoneController.text.trim();
                
                appState.addScanHistory(ScanHistoryItem(
                  title: "Emergency Scan (${widget.profile.name}'s Bracelete)",
                  scanner: phoneNumber.isNotEmpty ? phoneNumber : '+20 123 456 7890',
                  location: 'Cairo, Egypt',
                  time: 'Just now',
                ));

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublicPreviewQrPage(profile: widget.profile),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B64F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: Text(
                appState.tr('Confirm and View Data', 'تأكيد وعرض البيانات'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    final short = MediaQuery.sizeOf(context).shortestSide;
    final d = isPrimary ? (short * 0.18).clamp(56.0, 76.0) : (short * 0.13).clamp(44.0, 56.0);
    final iconS = isPrimary ? (short * 0.075).clamp(26.0, 34.0) : (short * 0.055).clamp(18.0, 24.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: iconS),
      ),
    );
  }
}