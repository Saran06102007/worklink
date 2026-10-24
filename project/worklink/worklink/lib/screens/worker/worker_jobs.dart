import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/motion.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import 'worker_job_detail.dart';

class WorkerJobsScreen extends StatefulWidget {
  const WorkerJobsScreen({super.key});
  @override
  State<WorkerJobsScreen> createState() => _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends State<WorkerJobsScreen> {
  int _seg = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final all = s.workerBookings;
    final list = _seg == 0 ? all.where((b) => b.status.isActive).toList() : all.where((b) => !b.status.isActive).toList();

    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Jobs', style: Ty.h1(p.text)),
            const SizedBox(height: 12),
            Segmented(items: const ['Active', 'History'], index: _seg, onChanged: (i) => setState(() => _seg = i)),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(icon: Icons.work_outline_rounded, title: 'No jobs here', message: 'Incoming requests will show up on your dashboard.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final b = list[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Stagger(
                        index: i,
                        child: GlassCard(
                          onTap: () => pushPage(context, WorkerJobDetailScreen(bookingId: b.id)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              StatusChip(b.status),
                              const Spacer(),
                              Text(rupees(b.shownPrice), style: Ty.title(p.accentSoft)),
                            ]),
                            const SizedBox(height: 8),
                            Text(b.customerName, style: Ty.h3(p.text)),
                            Text(b.details, style: Ty.small(p.textDim), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('${b.customerArea} · ${timeAgo(b.createdAt)}', style: Ty.small(p.textFaint)),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
