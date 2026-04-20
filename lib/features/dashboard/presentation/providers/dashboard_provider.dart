import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_ticketing/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:e_ticketing/features/dashboard/data/models/dashboard_model.dart';

final dashboardRepoProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(Supabase.instance.client);
});

// Provider untuk mengambil data User
final userStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('No authenticated user');
  return ref.read(dashboardRepoProvider).getUserStats(user.id);
});

// Provider untuk mengambil data Admin
final adminStatsProvider = FutureProvider<DashboardStats>((ref) async {
  return ref.read(dashboardRepoProvider).getAdminStats();
});
