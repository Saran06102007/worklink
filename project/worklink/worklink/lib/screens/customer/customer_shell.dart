import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import 'customer_bookings.dart';
import 'customer_home.dart';
import 'customer_profile.dart';
import 'discover_screen.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pages = const [
      CustomerHomeScreen(),
      DiscoverScreen(),
      CustomerBookingsScreen(),
      CustomerProfileScreen(),
    ];
    return Stack(children: [
      const AuroraBackground(),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(index: s.tab, children: pages),
        bottomNavigationBar: GlassNavBar(
          index: s.tab,
          onTap: s.setTab,
          items: [
            const NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
            const NavItem(Icons.search_rounded, Icons.manage_search_rounded, 'Discover'),
            NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Bookings',
                badge: s.customerBookings.where((b) => b.status.isActive).length),
            NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile',
                badge: s.unread(UserRole.customer)),
          ],
        ),
      ),
    ]);
  }
}
