import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';

final ticketRepoProvider = Provider<TicketRepository>((ref) {
  return TicketRepository(Supabase.instance.client);
});

// Ambil tiket khusus user yang sedang login
final userTicketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return ref.read(ticketRepoProvider).getUserTickets(user.id);
});

// Ambil semua tiket untuk Admin/Helpdesk
final allTicketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  return ref.read(ticketRepoProvider).getAllTickets();
});

// Comments for a specific ticket
final ticketCommentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((
      ref,
      ticketId,
    ) async {
      return ref.read(ticketRepoProvider).getTicketComments(ticketId);
    });

final helpdeskUsersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return ref.read(ticketRepoProvider).getHelpdeskUsers();
});

// Histories for a specific ticket (FR-010/FR-011)
final ticketHistoriesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((
      ref,
      ticketId,
    ) async {
      return ref.read(ticketRepoProvider).getTicketHistories(ticketId);
    });
