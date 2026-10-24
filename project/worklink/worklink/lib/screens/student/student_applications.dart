import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class StudentApplicationsScreen extends StatelessWidget {
  const StudentApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final apps = s.applications;

    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text('Applications', style: Ty.h1(p.text)),
        ),
        Expanded(
          child: apps.isEmpty
              ? EmptyState(icon: Icons.assignment_outlined, title: 'No applications yet', message: 'Browse jobs and apply to get started.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: apps.length,
                  itemBuilder: (_, i) {
                    final a = apps[i];
                    final j = s.jobById(a.jobId);
                    if (j == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(j.title, style: Ty.title(p.text))),
                            Pill(a.status.name, color: _color(a.status)),
                          ]),
                          Text(j.business, style: Ty.small(p.textDim)),
                          const SizedBox(height: 6),
                          Text('${j.payLabel} · applied ${timeAgo(a.appliedAt)}', style: Ty.small(p.textFaint)),
                          const SizedBox(height: 10),
                          if (a.status == AppStatus.applied || a.status == AppStatus.shortlisted)
                            AppButton('Withdraw', kind: BtnKind.danger, height: 40, onPressed: () => s.withdrawApplication(a.id)),
                          if (a.status == AppStatus.hired)
                            AppButton('Mark shift completed', height: 40, onPressed: () => s.completeShift(a.id)),
                          if (a.status == AppStatus.completed)
                            Pill('Earned ${rupees(j.pay)}', color: Brand.success, icon: Icons.check_circle_rounded),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Color _color(AppStatus st) {
    switch (st) {
      case AppStatus.applied:
        return Brand.warning;
      case AppStatus.shortlisted:
        return Brand.violetSoft;
      case AppStatus.hired:
        return const Color(0xFF6EA8FF);
      case AppStatus.completed:
        return Brand.success;
      case AppStatus.withdrawn:
        return Brand.danger;
    }
  }
}
