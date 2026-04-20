import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final SupabaseClient _supabase;
  DashboardRepository(this._supabase);

  // Statistik untuk User (Hanya tiket miliknya)
  Future<DashboardStats> getUserStats(String userId) async {
    final response = await _supabase
        .from('tickets')
        .select('id, status')
        .eq('user_id', userId);
    final list = response as List;
    final total = list.length;
    final active = list.where((t) {
      final s = (t['status'] ?? '').toString().toLowerCase();
      return s == 'menunggu' || s == 'diproses';
    }).length;
    return DashboardStats(totalTickets: total, activeTickets: active);
  }

  // Statistik untuk Admin/Helpdesk (Semua tiket di sistem)
  Future<DashboardStats> getAdminStats() async {
    final response = await _supabase.from('tickets').select('id, status');
    final list = response as List;
    final total = list.length;
    final active = list.where((t) {
      final s = (t['status'] ?? '').toString().toLowerCase();
      return s == 'menunggu' || s == 'diproses';
    }).length;
    return DashboardStats(totalTickets: total, activeTickets: active);
  }
}
