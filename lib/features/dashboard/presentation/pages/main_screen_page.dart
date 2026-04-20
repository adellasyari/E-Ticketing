import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing/core/providers/bottom_nav_provider.dart';
import 'package:e_ticketing/features/dashboard/presentation/pages/user_dashboard_page.dart';
import 'package:e_ticketing/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:e_ticketing/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:e_ticketing/features/notification/presentation/pages/notification_page.dart';
import 'package:e_ticketing/features/auth/presentation/pages/profile_page.dart';

class MainScreenPage extends ConsumerWidget {
  final String role;

  const MainScreenPage({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Determines the appropriate dashboard based on role
    final dashboardPage = (role == 'admin' || role == 'helpdesk')
        ? const AdminDashboardPage()
        : const UserDashboardPage();

    final List<Widget> pages = [
      dashboardPage,
      const CreateTicketPage(),
      const NotificationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(
                0xFF5C5CE5,
              ), // Indigo blue matching image
              unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              onTap: (index) {
                ref.read(bottomNavIndexProvider.notifier).state = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.home_outlined, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.home, size: 28),
                  ),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.add_circle_outline, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.add_circle, size: 28),
                  ),
                  label: 'Buat',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.notifications_none_rounded, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.notifications_rounded, size: 28),
                  ),
                  label: 'Notifikasi',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person_outline_rounded, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person_rounded, size: 28),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
