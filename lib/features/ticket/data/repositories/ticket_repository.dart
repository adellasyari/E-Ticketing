import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final SupabaseClient _supabase;
  TicketRepository(this._supabase);

  // User: Membuat tiket baru (FR-005)
  Future<void> createTicket(TicketModel ticket) async {
    await _supabase.from('tickets').insert(ticket.toJson());
  }

  // User: Melihat daftar tiket miliknya (FR-005)
  Future<List<TicketModel>> getUserTickets(String userId) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final list = response as List<dynamic>;
    return list
        .map(
          (json) =>
              TicketModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  // Admin/Helpdesk: Melihat semua tiket (FR-006)
  Future<List<TicketModel>> getAllTickets() async {
    final response = await _supabase
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    final list = response as List<dynamic>;
    return list
        .map(
          (json) =>
              TicketModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  // Admin/Helpdesk: Update status tiket (FR-006)
  Future<void> updateTicketStatus(int ticketId, String newStatus) async {
    await _supabase
        .from('tickets')
        .update({'status': newStatus})
        .eq('id', ticketId);
  }

  // Upload image to Supabase Storage 'tickets' bucket and return public URL
  Future<String?> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'attachments/$fileName';
    await _supabase.storage.from('tickets').upload(path, imageFile);
    return _supabase.storage.from('tickets').getPublicUrl(path);
  }

  // Get comments for a ticket including commenter profile
  Future<List<Map<String, dynamic>>> getTicketComments(int ticketId) async {
    final response = await _supabase
        .from('ticket_comments')
        .select('*, profiles(full_name, role)')
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    final list = response as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // Add a comment to a ticket
  Future<void> addComment(int ticketId, String userId, String message) async {
    await _supabase.from('ticket_comments').insert({
      'ticket_id': ticketId,
      'user_id': userId,
      'message': message,
    });
  }

  // Mengambil daftar Admin/Helpdesk untuk Assign (FR-006)
  Future<List<Map<String, dynamic>>> getHelpdeskUsers() async {
    final response = await _supabase
        .from('profiles')
        .select('id, full_name, role')
        .inFilter('role', ['admin', 'helpdesk']);
    final list = response as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // Update Status dan Assignee (FR-006)
  Future<void> updateTicketDetails(
    int ticketId,
    String status,
    String? assignedTo,
  ) async {
    await _supabase
        .from('tickets')
        .update({'status': status, 'assigned_to': assignedTo})
        .eq('id', ticketId);
  }

  // Add a history entry for ticket actions (FR-010)
  Future<void> addTicketHistory(
    int ticketId,
    String userId,
    String action,
  ) async {
    await _supabase.from('ticket_histories').insert({
      'ticket_id': ticketId,
      'changed_by': userId,
      'action': action,
    });
  }

  // Retrieve ticket histories with profile info (FR-011)
  Future<List<Map<String, dynamic>>> getTicketHistories(int ticketId) async {
    final response = await _supabase
        .from('ticket_histories')
        .select('*, profiles(full_name)')
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: false);
    final list = response as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
