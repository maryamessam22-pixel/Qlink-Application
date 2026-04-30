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
                    child: history.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
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
