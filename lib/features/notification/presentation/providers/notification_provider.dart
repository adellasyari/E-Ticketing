import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

final notificationRepoProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(Supabase.instance.client),
);

final userNotificationsProvider = FutureProvider<List<NotificationModel>>(
  (ref) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return [];

    try {
      final roleResponse = await supabase
          .from('profiles')
          .select('role')
          .eq('id', currentUser.id)
          .maybeSingle();

      final role = (roleResponse as Map<String, dynamic>?)?['role'] as String?;

      if (role == 'admin' || role == 'helpdesk') {
        return ref.read(notificationRepoProvider).getAllNotifications();
      }

      return ref.read(notificationRepoProvider).getUserNotifications(currentUser.id);
    } catch (_) {
      // Fallback to user-specific notifications on error
      return ref.read(notificationRepoProvider).getUserNotifications(currentUser.id);
    }
  },
);
