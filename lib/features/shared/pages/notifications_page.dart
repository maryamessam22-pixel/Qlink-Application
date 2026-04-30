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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final hPad = (w * 0.04).clamp(12.0, 20.0);
    final listBottom = mq.viewInsets.bottom + mq.padding.bottom + (short * 0.04).clamp(12.0, 24.0);
    final titleFs = (short * 0.048).clamp(16.0, 20.0);
    final backIcon = (short * 0.065).clamp(22.0, 28.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF1E3A8A), size: backIcon),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appState.tr('Notifications', 'الإشعارات'),
          style: TextStyle(
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: titleFs,
          ),
        ),
        actions: [
          if (!_loading && _notifications.isNotEmpty)
            TextButton.icon(
              onPressed: _clearAllConfirmed,
              icon: Icon(Icons.delete_sweep_outlined, color: const Color(0xFFB91C1C), size: (short * 0.052).clamp(18.0, 22.0)),
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
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final iconEmpty = (short * 0.16).clamp(48.0, 72.0);
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none, size: iconEmpty, color: Colors.grey),
                                    SizedBox(height: (short * 0.032).clamp(10.0, 14.0)),
                                    Text(
                                      appState.tr('No notifications yet', 'لا توجد إشعارات بعد'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: (short * 0.04).clamp(14.0, 17.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadNotifications();
                    await _loadWearerRequests();
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, listBottom),
                    children: [
                      if (AppState().currentUser.role.toLowerCase() == 'wearer' &&
                          _pendingWearerRequests.isNotEmpty) ...[
                        _buildWearerRequestsSection(),
                        SizedBox(height: (short * 0.032).clamp(10.0, 14.0)),
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
                            width: (short * 0.11).clamp(38.0, 46.0),
                            height: (short * 0.11).clamp(38.0, 46.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              n['type'] == 'qr_scan' ? Icons.qr_code_scanner : Icons.notifications,
                              color: const Color(0xFF1E3A8A),
                              size: (short * 0.052).clamp(18.0, 22.0),
                            ),
                          ),
                          title: Text(
                            n['title'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: (short * 0.036).clamp(13.0, 15.0),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n['body'] ?? '',
                                style: TextStyle(fontSize: (short * 0.034).clamp(12.0, 14.0)),
                              ),
                              SizedBox(height: (short * 0.01).clamp(3.0, 6.0)),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: (short * 0.028).clamp(10.0, 12.0),
                                  color: Colors.grey,
                                ),
                              ),
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
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: (short * 0.052).clamp(18.0, 22.0),
                                    color: Colors.grey.shade600,
                                  ),
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
    final mq = MediaQuery.of(context);
    final short = mq.size.shortestSide;
    final w = mq.size.width;
    final hPad = (w * 0.04).clamp(12.0, 20.0);
    final bottom = mq.viewInsets.bottom + mq.padding.bottom + (short * 0.04).clamp(12.0, 24.0);
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, bottom),
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
