import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/forms.dart';
import '../../widgets/ui.dart';
import '../common/chat_screen.dart';

class WorkerJobDetailScreen extends StatefulWidget {
  final String bookingId;
  const WorkerJobDetailScreen({super.key, required this.bookingId});
  @override
  State<WorkerJobDetailScreen> createState() => _WorkerJobDetailScreenState();
}

class _WorkerJobDetailScreenState extends State<WorkerJobDetailScreen> {
  final _counter = TextEditingController();

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final b = s.bookingById(widget.bookingId);
    if (b == null) return AppScaffold(title: 'Job', body: const Center(child: Text('Not found')));
    final p = Pal.of(context);

    return AppScaffold(
      title: b.customerName,
      actions: [
        if (b.status.isActive && b.status != BookingStatus.awaitingWorker)
          IconButton(onPressed: () => pushPage(context, ChatScreen(bookingId: b.id)), icon: const Icon(Icons.chat_bubble_outline_rounded)),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          StatusChip(b.status),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.details, style: Ty.body(p.text)),
              const SizedBox(height: 8),
              _row(p, Icons.place_rounded, '${b.address} · ${b.customerArea}'),
              _row(p, Icons.schedule_rounded, b.schedule),
              _row(p, Icons.payments_rounded, 'Offer ${rupees(b.shownPrice)}'),
              if (b.distanceKm > 0) _row(p, Icons.directions_rounded, '${distLabel(b.distanceKm)} · ~${b.etaMin} min'),
            ]),
          ),
          if (b.status == BookingStatus.awaitingWorker) ...[
            SectionHeader('Respond'),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AppButton('Accept ${rupees(b.lastOffer?.amount ?? 0)}', onPressed: () => s.workerAccept(b.id), icon: Icons.check_rounded),
                const SizedBox(height: 10),
                AppField(controller: _counter, label: 'Counter amount (₹)', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                AppButton('Send counter', kind: BtnKind.secondary, onPressed: () {
                  final n = int.tryParse(_counter.text.trim());
                  if (n == null) return;
                  s.workerCounter(b.id, n);
                }),
                const SizedBox(height: 8),
                AppButton('Decline', kind: BtnKind.danger, onPressed: () => s.workerDecline(b.id)),
              ]),
            ),
          ],
          if (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.onTheWay ||
              b.status == BookingStatus.workStarted) ...[
            SectionHeader('Progress'),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(_nextLabel(b.status), style: Ty.body(p.textDim)),
                const SizedBox(height: 12),
                AppButton(_nextAction(b.status), onPressed: () => s.workerAdvance(b.id), icon: Icons.arrow_forward_rounded),
                if (b.status != BookingStatus.workStarted) ...[
                  const SizedBox(height: 8),
                  AppButton('Cancel job', kind: BtnKind.danger, onPressed: () => s.cancelBooking(b.id, Party.worker)),
                ],
              ]),
            ),
          ],
          SectionHeader('Offer history'),
          for (final o in b.offers)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Pill(o.by == Party.worker ? 'You' : 'Customer', color: o.by == Party.worker ? Brand.success : Brand.violet),
                const SizedBox(width: 8),
                Text(rupees(o.amount), style: Ty.title(p.text)),
              ]),
            ),
        ],
      ),
    );
  }

  String _nextLabel(BookingStatus st) {
    switch (st) {
      case BookingStatus.confirmed:
        return 'Mark as on the way when you leave for the job.';
      case BookingStatus.onTheWay:
        return 'Mark work started when you begin.';
      case BookingStatus.workStarted:
        return 'Mark completed when the job is done.';
      default:
        return '';
    }
  }

  String _nextAction(BookingStatus st) {
    switch (st) {
      case BookingStatus.confirmed:
        return 'I am on the way';
      case BookingStatus.onTheWay:
        return 'Start work';
      case BookingStatus.workStarted:
        return 'Mark completed';
      default:
        return 'Continue';
    }
  }

  Widget _row(Pal p, IconData i, String t) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(children: [
          Icon(i, size: 16, color: p.textFaint),
          const SizedBox(width: 8),
          Expanded(child: Text(t, style: Ty.small(p.textDim))),
        ]),
      );
}
