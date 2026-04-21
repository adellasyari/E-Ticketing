import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_ticketing/core/theme/app_theme.dart';
import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import 'package:e_ticketing/features/dashboard/presentation/widgets/dashboard_widgets.dart';

class DetailTicketPage extends ConsumerStatefulWidget {
  final TicketModel ticket;
  const DetailTicketPage({super.key, required this.ticket});

  @override
  ConsumerState<DetailTicketPage> createState() => _DetailTicketPageState();
}

class _DetailTicketPageState extends ConsumerState<DetailTicketPage> {
  final TextEditingController _commentController = TextEditingController();

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
            TicketStatusBadge(status: widget.ticket.status),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Tiket',
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
                      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
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

                              const Text(
                                'Percakapan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),

                              commentsAsync.when(
                                data: (comments) {
                                  if (comments.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                                      child: Center(
                                        child: Text(
                                          'Belum ada pesan. Sampaikan balasan di bawah.',
                                          style: TextStyle(color: Colors.grey.shade500),
                                        ),
                                      ),
                                    );
                                  }
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
                            error: (err, stack) => const Text('Gagal memuat riwayat.'),
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
                      hintText: 'Ketik balasan...',
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
