import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/services/notification_service.dart';
import 'package:q_link/services/supabase_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    NotificationService().markAllRead();
  }

  Future<void> _loadNotifications() async {
    final userId = SupabaseService().client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await SupabaseService()
          .client
          .from('notifications')
          .select()
          .eq('guardian_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      if (mounted) setState(() { _notifications = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appState.tr('Notifications', 'الإشعارات'),
          style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(appState.tr('No notifications yet', 'لا توجد إشعارات بعد'),
                          style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final isRead = n['is_read'] == true;
                      final createdAt = n['created_at'] != null
                          ? DateTime.tryParse(n['created_at'].toString())?.toLocal()
                          : null;
                      final timeStr = createdAt != null
                          ? '${createdAt.day}/${createdAt.month}  ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                          : '';
                      return Container(
                        color: isRead ? Colors.white : const Color(0xFFEFF6FF),
                        child: ListTile(
                          leading: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              n['type'] == 'qr_scan' ? Icons.qr_code_scanner : Icons.notifications,
                              color: const Color(0xFF1E3A8A), size: 20,
                            ),
                          ),
                          title: Text(n['title'] ?? '',
                              style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n['body'] ?? '', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: isRead ? null : Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
