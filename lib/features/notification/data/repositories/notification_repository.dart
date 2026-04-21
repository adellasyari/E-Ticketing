import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;
  NotificationRepository(this._supabase);

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final list = response as List<dynamic>;
    return list
        .map(
          (json) => NotificationModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await _supabase
        .from('notifications')
        .select()
        .order('created_at', ascending: false);
    final list = response as List<dynamic>;
    return list
        .map(
          (json) => NotificationModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<void> markAsRead(int notifId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notifId);
  }

  Future<void> sendNotification(
    String userId,
    int ticketId,
    String message,
  ) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'ticket_id': ticketId,
      'message': message,
    });
  }
}
