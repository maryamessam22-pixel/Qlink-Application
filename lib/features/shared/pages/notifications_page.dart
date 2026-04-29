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
  List<Map<String, dynamic>> _pendingWearerRequests = [];
  final Set<String> _processingRequestIds = <String>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadWearerRequests();
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

  Future<void> _deleteOne(String notificationId) async {
    try {
      await SupabaseService().deleteNotificationById(notificationId);
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Could not delete notification', 'تعذر حذف الإشعار'))),
      );
    }
  }

  Future<void> _clearAllConfirmed() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final st = AppState();
        return AlertDialog(
          title: Text(st.tr('Clear all notifications?', 'مسح كل الإشعارات؟')),
          content: Text(
            st.tr('This removes all notifications in this list.', 'سيتم حذف كل الإشعارات في هذه القائمة.'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(st.tr('Cancel', 'إلغاء'))),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
              child: Text(st.tr('Clear all', 'مسح الكل')),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    try {
      await SupabaseService().deleteAllNotificationsForCurrentUser();
      await _loadNotifications();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Notifications cleared', 'تم مسح الإشعارات'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppState().tr('Could not clear notifications', 'تعذر مسح الإشعارات'))),
      );
    }
  }

  Future<void> _loadWearerRequests() async {
    try {
      final data = await SupabaseService().fetchPendingWearerLinkRequests();
      if (mounted) setState(() => _pendingWearerRequests = data);
    } catch (_) {}
  }

  Future<void> _handleRequestResponse({
    required String requestId,
    required bool accept,
  }) async {
    if (_processingRequestIds.contains(requestId)) return;
    final appState = AppState();
    setState(() => _processingRequestIds.add(requestId));
    try {
      await SupabaseService().respondToWearerLinkRequest(
        requestId: requestId,
        accept: accept,
      );
      await _loadWearerRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? appState.tr('Request accepted.', 'تم قبول الطلب.')
                  : appState.tr('Request declined.', 'تم رفض الطلب.'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _processingRequestIds.remove(requestId));
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
        actions: [
          if (!_loading && _notifications.isNotEmpty)
            TextButton.icon(
              onPressed: _clearAllConfirmed,
              icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFB91C1C), size: 20),
              label: Text(
                appState.tr('Clear all', 'مسح الكل'),
                style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? ((AppState().currentUser.role.toLowerCase() == 'wearer' &&
                      _pendingWearerRequests.isNotEmpty)
                  ? _buildWearerRequestsOnlyState()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            appState.tr('No notifications yet', 'لا توجد إشعارات بعد'),
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadNotifications();
                    await _loadWearerRequests();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (AppState().currentUser.role.toLowerCase() == 'wearer' &&
                          _pendingWearerRequests.isNotEmpty) ...[
                        _buildWearerRequestsSection(),
                        const SizedBox(height: 12),
                      ],
                      ..._notifications.asMap().entries.map((entry) {
                        final index = entry.key;
                      final n = _notifications[index];
                      final id = (n['id'] ?? '').toString();
                      final isRead = n['is_read'] == true;
                      final createdAt = n['created_at'] != null
                          ? DateTime.tryParse(n['created_at'].toString())?.toLocal()
                          : null;
                      final timeStr = createdAt != null
                          ? '${createdAt.day}/${createdAt.month}  ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                          : '';
                      return Column(
                        children: [
                          Container(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration:
                                      const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                ),
                              if (id.isNotEmpty)
                                IconButton(
                                  tooltip: appState.tr('Delete', 'حذف'),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade600),
                                  onPressed: () => _deleteOne(id),
                                ),
                            ],
                          ),
                        ),
                      ),
                          const Divider(height: 1),
                        ],
                      );
                    }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWearerRequestsOnlyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildWearerRequestsSection()],
    );
  }

  Widget _buildWearerRequestsSection() {
    final appState = AppState();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.tr('Link Requests', 'طلبات الربط'),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 10),
          ..._pendingWearerRequests.map((req) {
            final requestId = req['id'].toString();
            final loading = _processingRequestIds.contains(requestId);
            final guardianName = (req['guardian_name'] ?? 'Guardian').toString();
            final guardianEmail = (req['guardian_email'] ?? '').toString();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guardianName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (guardianEmail.isNotEmpty)
                    Text(
                      guardianEmail,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: loading
                              ? null
                              : () => _handleRequestResponse(
                                    requestId: requestId,
                                    accept: false,
                                  ),
                          child: Text(appState.tr('Decline', 'رفض')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () => _handleRequestResponse(
                                    requestId: requestId,
                                    accept: true,
                                  ),
                          child: loading
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(appState.tr('Accept', 'قبول')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
