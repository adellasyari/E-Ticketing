import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

final notificationRepoProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(Supabase.instance.client),
);

final userNotificationsProvider = FutureProvider<List<NotificationModel>>((
  ref,
) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.read(notificationRepoProvider).getUserNotifications(userId);
});
