import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/guardian/profile/public_preview_qr_page.dart';

class EmergencyQrPage extends StatefulWidget {
  final ProfileData profile;

  const EmergencyQrPage({super.key, required this.profile});

  @override
  State<EmergencyQrPage> createState() => _EmergencyQrPageState();
}

class _EmergencyQrPageState extends State<EmergencyQrPage> {
  int _activeTab = 0; // 0 for My Code, 1 for Scanner
  final MobileScannerController _scannerController = MobileScannerController();

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
          backgroundColor: _activeTab == 1 ? Colors.black : const Color(0xFFF7F9FC),
          body: Stack(
            children: [
              // Background (for My Code mode)
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
                    // Top Bar Toggle
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      height: 60,
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? Colors.white.withValues(alpha:0.1) : const Color(0xFF1B64F2),
                        borderRadius: BorderRadius.circular(12),
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

              // Back Button
              Positioned(
                top: 60,
                left: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _activeTab == 1 ? Colors.white.withValues(alpha:0.2) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: _activeTab == 1 ? Colors.white : const Color(0xFF1E3A8A)),
                  ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          appState.tr('Emergency Profile QR', 'رمز QR للملف الشخصي للطوارئ'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 8),
        Text(
          appState.tr('Anyone can scan this to see your emergency info.', 'يمكن لأي شخص مسح هذا لمعرفة معلومات الطوارئ الخاصة بك.'),
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        
        // QR Container
        GestureDetector(
          onTap: () => _showAccessSimulationDialog(appState),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: QrImageView(
              data: 'qlink-profile-${widget.profile.name}',
              version: QrVersions.auto,
              size: 200.0,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1B64F2)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1B64F2)),
            ),
          ),
        ),
        
        const SizedBox(height: 60),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.share2, size: 18),
              label: Text(appState.tr('Share QR Code', 'مشاركة رمز QR'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B64F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerView(AppState appState) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
               // Simulate successful scan
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublicPreviewQrPage(profile: widget.profile),
                ),
              );
            }
          },
        ),
        
        // Overlays
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1B64F2), width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Scanning Line Animation simulated with a simple container
                Positioned(
                  top: 130,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B64F2).withValues(alpha:0.8),
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
          bottom: 120,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                appState.tr('Scan QR Code', 'مسح رمز QR'),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  appState.tr('Center the QR code inside the frame to get the data of patient', 'ضع رمز QR داخل الإطار للحصول على بيانات المريض'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleAction(LucideIcons.image, () {}),
                  const SizedBox(width: 24),
                  _buildCircleAction(LucideIcons.scan, () {}, isPrimary: true),
                  const SizedBox(width: 24),
                  _buildCircleAction(LucideIcons.refreshCcw, () => _scannerController.switchCamera()),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.keyboard, size: 18),
                  label: Text(appState.tr('Enter Code Manually', 'أدخل الرمز يدوياً')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Positioned(
          top: 60,
          right: 20,
          child: _buildCircleAction(LucideIcons.flashlight, () => _scannerController.toggleTorch()),
        ),
      ],
    );
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
                
                // Add to history state
                appState.addScanHistory(ScanHistoryItem(
                  title: "Emergency Scan (${widget.profile.name}'s Bracelete)",
                  scanner: phoneNumber.isNotEmpty ? phoneNumber : '+20 123 456 7890',
                  location: 'Cairo, Egypt',
                  time: 'Just now',
                ));

                Navigator.pop(context); // Close bottom sheet
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 70 : 50,
        height: isPrimary ? 70 : 50,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withValues(alpha:0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: isPrimary ? 30 : 20),
      ),
    );
  }
}
