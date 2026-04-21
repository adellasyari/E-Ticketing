import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_ticketing/core/theme/app_theme.dart';
import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import 'package:e_ticketing/features/notification/presentation/providers/notification_provider.dart';
import 'package:e_ticketing/features/dashboard/presentation/widgets/dashboard_widgets.dart';

class AdminDetailTicketPage extends ConsumerStatefulWidget {
  final TicketModel ticket;
  const AdminDetailTicketPage({super.key, required this.ticket});

  @override
  ConsumerState<AdminDetailTicketPage> createState() =>
      _AdminDetailTicketPageState();
}

class _AdminDetailTicketPageState extends ConsumerState<AdminDetailTicketPage> {
  late String _status;
  String? _assignedTo;
  final TextEditingController _commentController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _status = widget.ticket.status;
    _assignedTo = widget.ticket.assignedTo;
  }

  void _updateTicket() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    final message =
        'Status tiket "${widget.ticket.title}" berubah menjadi $_status';

    try {
      await ref
          .read(ticketRepoProvider)
          .updateTicketDetails(widget.ticket.id!, _status, _assignedTo);

      try {
        await ref
            .read(notificationRepoProvider)
            .sendNotification(widget.ticket.userId, widget.ticket.id!, message);
      } catch (notifError) {
        try {
          final supabase = Supabase.instance.client;
          await supabase.from('notifications').insert({
            'user_id': widget.ticket.userId,
            'ticket_id': widget.ticket.id,
            'title': 'Status Tiket Diperbarui',
            'message':
                'Status tiket "${widget.ticket.title}" berubah menjadi $_status',
          });
        } catch (directError) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Notifikasi gagal dikirim: $notifError | $directError',
                ),
              ),
            );
        }
      }

      try {
        await ref
            .read(ticketRepoProvider)
            .addTicketHistory(
              widget.ticket.id!,
              Supabase.instance.client.auth.currentUser!.id,
              'Status diubah menjadi $_status',
            );
        ref.invalidate(ticketHistoriesProvider(widget.ticket.id!));
      } catch (historyError) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mencatat riwayat: $historyError')),
          );
      }

      ref.invalidate(allTicketsProvider);
      ref.invalidate(userTicketsProvider);

      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui tiket: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final userId = Supabase.instance.client.auth.currentUser!.id;
    await ref
        .read(ticketRepoProvider)
        .addComment(widget.ticket.id!, userId, _commentController.text.trim());
    _commentController.clear();
    ref.invalidate(ticketCommentsProvider(widget.ticket.id!));
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final helpdeskAsync = ref.watch(helpdeskUsersProvider);
    final commentsAsync = ref.watch(ticketCommentsProvider(widget.ticket.id!));
    final historyAsync = ref.watch(ticketHistoriesProvider(widget.ticket.id!));
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    String formatTimeFromDynamic(dynamic val) {
      try {
        if (val == null) return '';
        final s = val.toString();
        if (s.contains('T')) {
          final parts = s.split('T');
          final time = parts.length > 1 ? parts[1] : s;
          return time.length >= 5 ? time.substring(0, 5) : time;
        }
        return s.length >= 5 ? s.substring(0, 5) : s;
      } catch (e) {
        return '';
      }
    }

    Color _colorForAction(String action) {
      final a = action.toLowerCase();
      if (a.contains('menunggu')) return AppTheme.statusWaiting;
      if (a.contains('diproses')) return AppTheme.statusProcessing;
      if (a.contains('selesai')) return AppTheme.statusDone;
      return Colors.grey.shade400;
    }

    final header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ticket.title,
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.titleLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        widget.ticket.createdAt != null
                            ? '${widget.ticket.createdAt!.day.toString().padLeft(2, '0')}-${widget.ticket.createdAt!.month.toString().padLeft(2, '0')} ${widget.ticket.createdAt!.hour.toString().padLeft(2, '0')}:${widget.ticket.createdAt!.minute.toString().padLeft(2, '0')}'
                            : '',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TicketStatusBadge(status: _status),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Tiket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          header,
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TabBar(
                      indicatorColor: AppTheme.primaryColor,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.grey.shade500,
                      labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Detail & Diskusi'),
                        Tab(text: 'Tracking'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ListView(
                            padding: const EdgeInsets.only(top: 12, bottom: 20),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deskripsi Masalah',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.ticket.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (widget.ticket.attachmentUrl != null) ...[
                                      const SizedBox(height: 16),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          widget.ticket.attachmentUrl!,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.05),
                                  border: Border.all(
                                    color: theme.primaryColor.withOpacity(0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tindakan Admin',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: _status,
                                      decoration: InputDecoration(
                                        labelText: 'Ubah Status',
                                        filled: true,
                                        fillColor: theme.scaffoldBackgroundColor,
                                      ),
                                      items: [
                                        'Menunggu',
                                        'Diproses',
                                        'Selesai',
                                        'Dibatalkan'
                                      ]
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onChanged: (val) => setState(() => _status = val!),
                                    ),
                                    const SizedBox(height: 16),
                                    helpdeskAsync.when(
                                      data: (users) => DropdownButtonFormField<String?>(
                                        value: _assignedTo,
                                        decoration: InputDecoration(
                                          labelText: 'Assign ke (Helpdesk)',
                                          filled: true,
                                          fillColor: theme.scaffoldBackgroundColor,
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Belum di-assign'),
                                          ),
                                          ...users.map(
                                            (u) => DropdownMenuItem(
                                              value: u['id'] as String,
                                              child: Text(u['full_name']),
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) => setState(() => _assignedTo = val),
                                      ),
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                      error: (err, stack) => Text('Error load helpdesk: $err', style: const TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: _isUpdating ? null : _updateTicket,
                                        icon: _isUpdating
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(Icons.save_rounded),
                                        label: const Text('Simpan Perubahan'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              const Text(
                                'Percakapan internal & user',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),

                              commentsAsync.when(
                                data: (comments) {
                                  if (comments.isEmpty)
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                                      child: Center(
                                        child: Text(
                                          'Belum ada pesan.',
                                          style: TextStyle(color: Colors.grey.shade500),
                                        ),
                                      ),
                                    );
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      final c = comments[index];
                                      final bool isMe = c['user_id'] == currentUserId;
                                      final senderName = c['profiles']?['full_name'] ?? 'User';

                                      return Align(
                                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                                          padding: const EdgeInsets.all(12),
                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                          decoration: BoxDecoration(
                                            color: isMe ? theme.primaryColor : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200),
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(16),
                                              topRight: const Radius.circular(16),
                                              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (!isMe) ...[
                                                Text(
                                                  senderName,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                              ],
                                              Text(
                                                c['message'],
                                                style: TextStyle(
                                                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, stack) => const Text('Gagal memuat pesan.'),
                              ),

                              const SizedBox(height: 80),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                          child: historyAsync.when(
                            data: (histories) {
                              if (histories.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Belum ada riwayat',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: histories.length,
                                itemBuilder: (context, index) {
                                  final h = histories[index];
                                  final isLast = index == histories.length - 1;
                                  final action = (h['action'] ?? '').toString();
                                  final detail = (h['description'] ?? h['note'] ?? '').toString();
                                  final created = h['created_at'] ?? h['createdAt'] ?? h['time'] ?? h['timestamp'];
                                  final timeStr = formatTimeFromDynamic(created);
                                  final dotColor = _colorForAction(action);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 18.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 6, right: 12, top: 4),
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: dotColor,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: dotColor.withOpacity(0.25),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!isLast)
                                              Container(
                                                margin: const EdgeInsets.only(left: 12),
                                                width: 2,
                                                height: 64,
                                                color: Colors.grey.shade300,
                                              ),
                                          ],
                                        ),

                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        action,
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 15,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      if (detail.isNotEmpty)
                                                        Text(
                                                          detail,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        'Oleh: ${h['profiles']?['full_name'] ?? 'Sistem'}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                if (timeStr.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                                                    child: Text(
                                                      timeStr,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade500,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, stack) => const Center(child: Text('Gagal memuat riwayat.')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Balas sebagai admin...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendComment,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
