import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/supabase_service.dart';

class QrScanHistoryPage extends StatefulWidget {
  const QrScanHistoryPage({super.key});

  @override
  State<QrScanHistoryPage> createState() => _QrScanHistoryPageState();
}

class _QrScanHistoryPageState extends State<QrScanHistoryPage> {
  Future<void> _clearStoredQrHistory() async {
    final userId = SupabaseService().client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    await SupabaseService().client.from('notifications').delete().eq('guardian_id', userId).eq('type', 'qr_scan');
  }
  Future<List<ScanHistoryItem>> _fetchStoredQrHistory() async {
    try {
      final userId = SupabaseService().client.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) return AppState().scanHistory;

      final rows = await SupabaseService()
          .client
          .from('notifications')
          .select('title, body, created_at')
          .eq('guardian_id', userId)
          .eq('type', 'qr_scan')
          .order('created_at', ascending: false);

      final list = <ScanHistoryItem>[];
      for (final row in List<Map<String, dynamic>>.from(rows as List)) {
        final body = (row['body'] ?? '').toString();
        final scanner = body.startsWith('Scanned by ')
            ? body.replaceFirst('Scanned by ', '').trim()
            : AppState().tr('Unknown', 'غير معروف');
        list.add(
          ScanHistoryItem(
            title: (row['title'] ?? 'Emergency Scan').toString(),
            scanner: scanner,
            location: 'Cairo, Egypt',
            time: 'Just now',
          ),
        );
      }
      return list;
    } catch (_) {
      return AppState().scanHistory;
    }
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
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final btnPadBottom = mq.viewInsets.bottom + mq.padding.bottom + (short * 0.04).clamp(12.0, 24.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF7F9FC),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.035).clamp(8.0, 16.0),
                      vertical: (short * 0.012).clamp(6.0, 10.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Expanded(
                          child: Text(
                            appState.tr('QR Scan History', 'سجل مسح QR'),
                            style: TextStyle(
                              fontSize: (w * 0.05).clamp(17.0, 22.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF273469),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: FutureBuilder<List<ScanHistoryItem>>(
                      future: _fetchStoredQrHistory(),
                      builder: (context, snapshot) {
                        final history = snapshot.data ?? appState.scanHistory;
                        if (history.isEmpty) {
                          return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Text(
                            appState.tr('No scan history found', 'لم يتم العثور على سجل مسح'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (w * 0.038).clamp(13.0, 16.0),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                        }
                        return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(hPad, (short * 0.02).clamp(8.0, 14.0), hPad, (short * 0.02).clamp(8.0, 14.0)),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: (short * 0.04).clamp(12.0, 18.0)),
                            padding: EdgeInsets.all((short * 0.05).clamp(14.0, 22.0)),
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
                                  padding: EdgeInsets.all((short * 0.03).clamp(8.0, 14.0)),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    LucideIcons.qrCode,
                                    color: const Color(0xFF1B64F2),
                                    size: (short * 0.06).clamp(20.0, 28.0),
                                  ),
                                ),
                                SizedBox(width: (w * 0.04).clamp(10.0, 18.0)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: (w * 0.038).clamp(13.0, 16.0),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF273469),
                                        ),
                                      ),
                                      SizedBox(height: (short * 0.018).clamp(4.0, 8.0)),
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
                      );
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      (w * 0.1).clamp(24.0, 52.0),
                      (short * 0.025).clamp(10.0, 20.0),
                      (w * 0.1).clamp(24.0, 52.0),
                      btnPadBottom,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _clearStoredQrHistory();
                          appState.clearScanHistory();
                          if (!mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(appState.tr('History cleared', '?? ??? ?????'))),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF273469),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: (short * 0.04).clamp(12.0, 18.0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Text(
                          appState.tr('Clear History', 'مسح السجل'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (w * 0.035).clamp(12.0, 15.0),
                          ),
                        ),
                      ),
                    ),
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
}

