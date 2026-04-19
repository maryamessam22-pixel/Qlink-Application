import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';

class QrScanHistoryPage extends StatefulWidget {
  const QrScanHistoryPage({super.key});

  @override
  State<QrScanHistoryPage> createState() => _QrScanHistoryPageState();
}

class _QrScanHistoryPageState extends State<QrScanHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final history = appState.scanHistory;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                   // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Text(
                          appState.tr('QR Scan History', 'سجل مسح QR'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF273469),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: history.isEmpty 
                    ? Center(child: Text(appState.tr('No scan history found', 'لم يتم العثور على سجل مسح')))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(LucideIcons.qrCode, color: Color(0xFF1B64F2), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF273469),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                          children: [
                                            TextSpan(text: appState.tr('Scanned by ', 'تم المسح بواسطة ')),
                                            TextSpan(
                                              text: item.scanner,
                                              style: const TextStyle(color: Color(0xFF0E9F6E), fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.location} • ${item.time}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ),

                  // Clear History Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          appState.clearScanHistory();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(appState.tr('History cleared', 'تم مسح السجل'))),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF273469),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Text(
                          appState.tr('Clear History', 'مسح السجل'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
