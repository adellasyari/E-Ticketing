import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/dashboard_widgets.dart';
import 'package:e_ticketing/features/ticket/presentation/pages/admin_detail_ticket_page.dart';
import 'package:e_ticketing/features/ticket/presentation/providers/ticket_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userFullName =
        Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ??
        Supabase.instance.client.auth.currentUser?.email?.split('@').first ??
        'Admin';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 24,
                right: 24,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan tiket Anda,',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Halo, ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userFullName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    backgroundImage: const NetworkImage(
                      'https://ui-avatars.com/api/?name=Admin&background=random',
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          ref
              .watch(allTicketsProvider)
              .when(
                data: (tickets) {
                  final waitingCount = tickets
                      .where(
                        (t) =>
                            t.status.toLowerCase() == 'menunggu' ||
                            t.status.toLowerCase() == 'waiting' ||
                            t.status.toLowerCase() == 'open',
                      )
                      .length;
                  final processingCount = tickets
                      .where(
                        (t) =>
                            t.status.toLowerCase() == 'diproses' ||
                            t.status.toLowerCase() == 'processing' ||
                            t.status.toLowerCase() == 'in progress',
                      )
                      .length;
                  // Include closed in stats for admin too
                  final closedCount = tickets
                      .where(
                        (t) =>
                            t.status.toLowerCase() == 'selesai' ||
                            t.status.toLowerCase() == 'closed' ||
                            t.status.toLowerCase() == 'done',
                      )
                      .length;

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: Row(
                        children: [
                          StatCard(
                            title: 'Menunggu',
                            count: waitingCount.toString(),
                            gradientStart: const Color(0xFFFFCA28),
                            gradientEnd: const Color(0xFFFF9800),
                            icon: Icons.style,
                          ),
                          StatCard(
                            title: 'Diproses',
                            count: processingCount.toString(),
                            gradientStart: const Color(0xFF64B5F6),
                            gradientEnd: const Color(0xFF1E88E5),
                            icon: Icons.sync,
                          ),
                          StatCard(
                            title: 'Selesai',
                            count: closedCount.toString(),
                            gradientStart: const Color(0xFF81C784),
                            gradientEnd: const Color(0xFF00C853),
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (err, stack) => const SliverToBoxAdapter(),
              ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semua Tiket Terbaru',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Filter',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ref
              .watch(allTicketsProvider)
              .when(
                data: (tickets) {
                  if (tickets.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada tiket.',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ticket = tickets[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                offset: const Offset(0, 4),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminDetailTicketPage(ticket: ticket),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ticket.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TicketStatusBadge(
                                          status: ticket.status,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Dibuat oleh: ${ticket.userId.substring(0, 8)}...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.indigo.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text(
                                          'TKT-${ticket.id}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: CircleAvatar(
                                            radius: 2,
                                            backgroundColor: Colors.grey,
                                          ),
                                        ),
                                        Icon(
                                          Icons.category,
                                          size: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'IT Support',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatRelativeDate(ticket.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade400,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: tickets.length),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error memuat tiket: $err')),
                ),
              ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ), // Bottom nav padding
        ],
      ),
    );
  }

  String _formatRelativeDate(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours > 0) return '${diff.inHours} jam yang lalu';
      if (diff.inMinutes > 0) return '${diff.inMinutes} menit yang lalu';
      return 'Baru saja';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${diff.inDays} Hari lalu';
    }
  }
}
