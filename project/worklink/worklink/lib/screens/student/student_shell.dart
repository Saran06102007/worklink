import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import 'student_applications.dart';
import 'student_jobs.dart';
import 'student_profile.dart';
import 'student_schedule.dart';

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pages = const [
      StudentJobsScreen(),
      StudentApplicationsScreen(),
      StudentScheduleScreen(),
      StudentProfileScreen(),
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
            const NavItem(Icons.work_outline_rounded, Icons.work_rounded, 'Jobs'),
            NavItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Apps',
                badge: s.applications.where((a) => a.status == AppStatus.applied || a.status == AppStatus.shortlisted).length),
            const NavItem(Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Schedule'),
            NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', badge: s.unread(UserRole.student)),
          ],
        ),
      ),
    ]);
  }
}
