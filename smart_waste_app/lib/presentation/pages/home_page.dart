import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import 'dashboard_page.dart';
import 'log_waste_page.dart';
import 'pickup_schedule_page.dart';
import 'rewards_page.dart';
import 'recycling_centers_page.dart';
import 'admin/admin_dashboard_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const LogWastePage(),
    const PickupSchedulePage(),
    const RewardsPage(),
    const RecyclingCentersPage(),
    const AdminDashboardPage(), // Admin index = 5
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    // Redirect to login if user logs out
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = user.isAdmin;

    if (isAdmin) {
      return const Scaffold(
        body: AdminDashboardPage(),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.sublist(0, 5), // Exclude Admin page from indexed stack for regular users
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index < 5) setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'Pickup'),
          NavigationDestination(icon: Icon(Icons.wallet_outlined), selectedIcon: Icon(Icons.wallet), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'Centers'),
        ],
      ),
    );
  }
}
