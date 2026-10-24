import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import '../common/notifications_screen.dart';
import 'worker_job_detail.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final w = s.meWorker!;
    final pending = s.workerBookings.where((b) => b.status == BookingStatus.awaitingWorker).toList();
    final active = s.workerBookings.where((b) => b.status.isActive && b.status != BookingStatus.awaitingWorker).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hi, ${w.name.split(' ').first}', style: Ty.h1(p.text)),
                Text(w.available ? 'You are online' : 'You are offline', style: Ty.small(w.available ? Brand.success : p.textFaint)),
              ]),
            ),
            Switch(
              value: w.available,
              onChanged: (v) => s.setAvailability(v),
            ),
            IconButton(
              onPressed: () => pushPage(context, const NotificationsScreen()),
              icon: Badge(
                isLabelVisible: s.unread(UserRole.worker) > 0,
                label: Text('${s.unread(UserRole.worker)}'),
                child: Icon(Icons.notifications_outlined, color: p.text),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statCard(p, 'Today', rupees(s.workerEarnedSince(const Duration(days: 1))), Icons.today_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(p, 'This week', rupees(s.workerEarnedSince(const Duration(days: 7))), Icons.date_range_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(p, 'Jobs done', '${w.jobsDone}', Icons.check_circle_outline_rounded)),
          ]),
          const SizedBox(height: 12),
          GlassCard(
            child: Row(children: [
              VerificationBadge(w.verification),
              const SizedBox(width: 10),
              Expanded(child: Text(w.verifyNote ?? w.verification.label, style: Ty.small(p.textDim))),
            ]),
          ),
          SectionHeader('Incoming requests'),
          if (pending.isEmpty)
            GlassCard(child: Text('No pending requests. Tap below to simulate one.', style: Ty.body(p.textDim)))
          else
            for (final b in pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                    const SizedBox(height: 6),
                    Text('${b.customerArea} · ${b.schedule}', style: Ty.small(p.textFaint)),
                  ]),
                ),
              ),
          const SizedBox(height: 8),
          AppButton('Simulate incoming request', onPressed: s.simulateIncomingRequest, kind: BtnKind.secondary, icon: Icons.add_alert_rounded),
          if (active.isNotEmpty) ...[
            SectionHeader('Active jobs'),
            for (final b in active)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => pushPage(context, WorkerJobDetailScreen(bookingId: b.id)),
                  child: Row(children: [
                    StatusChip(b.status),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b.customerName, style: Ty.title(p.text))),
                    Text(rupees(b.shownPrice), style: Ty.title(p.accentSoft)),
                  ]),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(Pal p, String label, String value, IconData icon) => GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: p.accentSoft),
          const SizedBox(height: 8),
          Text(value, style: Ty.title(p.text)),
          Text(label, style: Ty.small(p.textFaint)),
        ]),
      );
}
