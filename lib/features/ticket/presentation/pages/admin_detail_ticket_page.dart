import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              children: [
                // Info Section
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.ticket.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TicketStatusBadge(
                            status: _status,
                          ), // Show live local status visually occasionally
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Deskripsi Masalah',
                        style: TextStyle(
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
                // Admin Actions Panel
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
                        items: ['Menunggu', 'Diproses', 'Selesai', 'Dibatalkan']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
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
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text(
                          'Error load helpdesk: $err',
                          style: const TextStyle(color: Colors.red),
                        ),
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
                  'Pelacakan Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                historyAsync.when(
                  data: (histories) {
                    if (histories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Belum ada riwayat',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: histories.length,
                      itemBuilder: (context, index) {
                        final h = histories[index];
                        final isLast = index == histories.length - 1;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(
                                    top: 4,
                                    left: 14,
                                    right: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLast
                                        ? theme.primaryColor
                                        : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 48,
                                    color: Colors.grey.shade300,
                                  ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h['action'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isLast
                                            ? theme.primaryColor
                                            : (isDark
                                                  ? Colors.grey.shade300
                                                  : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
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
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Text('Gagal memuat riwayat.'),
                ),

                const SizedBox(height: 16),
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
                        final senderName =
                            c['profiles']?['full_name'] ?? 'User';

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? theme.primaryColor
                                  : (isDark
                                        ? const Color(0xFF2C2C2C)
                                        : Colors.grey.shade200),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe
                                    ? const Radius.circular(16)
                                    : const Radius.circular(0),
                                bottomRight: isMe
                                    ? const Radius.circular(0)
                                    : const Radius.circular(16),
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
                                      color: isDark
                                          ? Colors.blue.shade200
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  c['message'],
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Text('Gagal memuat pesan.'),
                ),
              ],
            ),
          ),

          // Comment Input
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
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey.shade100,
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
