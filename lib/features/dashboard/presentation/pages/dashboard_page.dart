import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing/features/auth/presentation/providers/auth_provider.dart';
import 'package:e_ticketing/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:e_ticketing/features/dashboard/presentation/pages/user_dashboard_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(currentUserProvider);

    return asyncProfile.when(
      data: (profile) {
        final role = (profile?.role ?? '').toLowerCase();
        if (role == 'admin' || role == 'helpdesk') {
          return const AdminDashboardPage();
        }
        return const UserDashboardPage();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
