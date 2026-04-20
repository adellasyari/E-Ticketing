import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing/features/notification/presentation/providers/notification_provider.dart';
import 'package:e_ticketing/features/ticket/presentation/pages/detail_ticket_page.dart';
import 'package:e_ticketing/features/ticket/presentation/pages/admin_detail_ticket_page.dart';
import 'package:e_ticketing/features/ticket/data/models/ticket_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(userNotificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF1B1B1F),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () async {
                // Feature: mark all as read
                // Needs provider implementation, currently we rely on user tapping each.
                // You may add a "markAllAsRead" function in your repository later.
              },
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF5C5CE5),
                size: 20,
              ),
              label: const Text(
                'Tandai dibaca',
                style: TextStyle(
                  color: Color(0xFF5C5CE5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: notifAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi baru',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      if (!notif.isRead) {
                        await ref
                            .read(notificationRepoProvider)
                            .markAsRead(notif.id);
                        ref.invalidate(userNotificationsProvider);
                      }
                      if (context.mounted) {
                        try {
                          final response = await Supabase.instance.client
                              .from('tickets')
                              .select()
                              .eq('id', notif.ticketId)
                              .single();
                          final ticket = TicketModel.fromJson(
                            Map<String, dynamic>.from(response as Map),
                          );

                          // Cek role untuk navigasi
                          final userSession =
                              Supabase.instance.client.auth.currentSession;
                          if (userSession != null) {
                            final roleResponse = await Supabase.instance.client
                                .from('profiles')
                                .select('role')
                                .eq('id', userSession.user!.id)
                                .single();

                            final role = roleResponse['role'];
                            if (context.mounted) {
                              if (role == 'admin' || role == 'helpdesk') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminDetailTicketPage(ticket: ticket),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailTicketPage(ticket: ticket),
                                  ),
                                );
                              }
                            }
                          }
                        } catch (e) {
                          // Tangani error
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: notif.isRead
                                ? Colors.grey.shade100
                                : const Color(0xFFEEEDFC), // very light indigo
                            child: Icon(
                              notif.isRead
                                  ? Icons.notifications_none_rounded
                                  : Icons.notifications_none_rounded,
                              color: notif.isRead
                                  ? Colors.grey.shade400
                                  : const Color(0xFF5C5CE5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _extractTitle(notif.message),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: notif.isRead
                                              ? const Color(0xFF494A50)
                                              : const Color(0xFF1B1B1F),
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatRelativeDate(notif.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif.message,
                                  style: TextStyle(
                                    color: notif.isRead
                                        ? Colors.grey.shade500
                                        : const Color(0xFF70707A),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: Colors.red.shade400),
          ),
        ),
      ),
    );
  }

  // A helper to create a bold title from raw notification message
  // since the DB might only store a string message.
  String _extractTitle(String message) {
    if (message.toLowerCase().contains('berubah menjadi diproses') ||
        message.toLowerCase().contains('diperbarui')) {
      return 'Tiket Diperbarui';
    } else if (message.toLowerCase().contains('selesai') ||
        message.toLowerCase().contains('diselesaikan')) {
      return 'Tiket Selesai';
    } else if (message.toLowerCase().contains('dibuat') ||
        message.toLowerCase().contains('tiket baru')) {
      return 'Tiket Baru';
    } else if (message.toLowerCase().contains('membalas') ||
        message.toLowerCase().contains('komentar')) {
      return 'Komentar Baru';
    }
    return 'Notifikasi Tiket';
  }

  String _formatRelativeDate(DateTime? date) {
    if (date == null) return '-';
    // To match image EXACTLY we format time or say Kemarin/Hari lalu
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      // 10:40 format
      final hour = date.hour.toString().padLeft(2, '0');
      final min = date.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${diff.inDays} Hari lalu';
    }
  }
}
