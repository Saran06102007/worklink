import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import 'earnings_screen.dart';
import 'worker_dashboard.dart';
import 'worker_jobs.dart';
import 'worker_profile.dart';

class WorkerShell extends StatelessWidget {
  const WorkerShell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pending = s.workerBookings.where((b) => b.status == BookingStatus.awaitingWorker).length;
    final pages = const [
      WorkerDashboardScreen(),
      WorkerJobsScreen(),
      EarningsScreen(),
      WorkerProfileScreen(),
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
            const NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
            NavItem(Icons.work_outline_rounded, Icons.work_rounded, 'Jobs', badge: pending),
            const NavItem(Icons.payments_outlined, Icons.payments_rounded, 'Earnings'),
            NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', badge: s.unread(UserRole.worker)),
          ],
        ),
      ),
    ]);
  }
}
