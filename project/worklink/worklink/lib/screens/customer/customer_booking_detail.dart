import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/forms.dart';
import '../../widgets/ui.dart';
import '../common/chat_screen.dart';

class CustomerBookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const CustomerBookingDetailScreen({super.key, required this.bookingId});
  @override
  State<CustomerBookingDetailScreen> createState() => _CustomerBookingDetailScreenState();
}

class _CustomerBookingDetailScreenState extends State<CustomerBookingDetailScreen> {
  final _counter = TextEditingController();
  int _stars = 5;
  final _review = TextEditingController();

  @override
  void dispose() {
    _counter.dispose();
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final b = s.bookingById(widget.bookingId);
    if (b == null) return AppScaffold(title: 'Booking', body: const Center(child: Text('Not found')));
    final p = Pal.of(context);
    final w = s.workerById(b.workerId);
    final cat = categoryById(b.categoryId);

    return AppScaffold(
      title: cat.name,
      actions: [
        if (b.status.isActive && b.status != BookingStatus.awaitingWorker)
          IconButton(
            onPressed: () => pushPage(context, ChatScreen(bookingId: b.id)),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
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
              _row(p, Icons.place_rounded, b.address),
              _row(p, Icons.schedule_rounded, b.schedule),
              _row(p, Icons.payments_rounded, rupees(b.shownPrice)),
              if (w != null) _row(p, Icons.person_rounded, w.name),
            ]),
          ),
          if (b.status == BookingStatus.counterReceived && b.lastWorkerOffer != null) ...[
            SectionHeader('Counteroffer'),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('${w?.name ?? 'Worker'} proposed ${rupees(b.lastWorkerOffer!.amount)}', style: Ty.h3(p.text)),
                if (b.lastWorkerOffer!.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(b.lastWorkerOffer!.note, style: Ty.body(p.textDim)),
                ],
                const SizedBox(height: 14),
                AppButton('Accept ${rupees(b.lastWorkerOffer!.amount)}', onPressed: () => s.customerAcceptCounter(b.id)),
                const SizedBox(height: 8),
                AppField(controller: _counter, label: 'Your counter (₹)', keyboardType: TextInputType.number, validator: vAmount),
                const SizedBox(height: 8),
                AppButton('Send counter', kind: BtnKind.secondary, onPressed: () {
                  final n = int.tryParse(_counter.text.trim());
                  if (n == null) return;
                  s.customerCounter(b.id, n);
                }),
                const SizedBox(height: 8),
                AppButton('Decline', kind: BtnKind.danger, onPressed: () => s.customerDecline(b.id)),
              ]),
            ),
          ],
          if (b.status == BookingStatus.rejected) ...[
            SectionHeader('Declined'),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(b.rejectReason ?? 'Declined', style: Ty.body(p.textDim)),
                if (s.nextCandidate(b) != null) ...[
                  const SizedBox(height: 12),
                  AppButton('Try next nearest worker', onPressed: () => s.sendToNextCandidate(b.id)),
                ],
              ]),
            ),
          ],
          if (b.status == BookingStatus.completed) ...[
            SectionHeader('Payment & review'),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (!b.paid)
                  AppButton('Pay ${rupees(b.shownPrice)} (simulated)', onPressed: () => s.payBooking(b.id), icon: Icons.payments_rounded)
                else
                  Pill('Paid (simulated)', color: Brand.success, icon: Icons.check_circle_rounded),
                if (b.rating == null) ...[
                  const SizedBox(height: 16),
                  Text('Rate this job', style: Ty.title(p.text)),
                  Row(children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () => setState(() => _stars = i + 1),
                      icon: Icon(i < _stars ? Icons.star_rounded : Icons.star_outline_rounded, color: Brand.warning),
                    );
                  })),
                  AppField(controller: _review, label: 'Review (optional)', maxLines: 2),
                  const SizedBox(height: 8),
                  AppButton('Submit review', onPressed: () => s.submitReview(b.id, _stars, _review.text)),
                ] else ...[
                  const SizedBox(height: 12),
                  Text('You rated ${b.rating}★', style: Ty.body(p.textDim)),
                  if ((b.review ?? '').isNotEmpty) Text(b.review!, style: Ty.small(p.textFaint)),
                ],
              ]),
            ),
          ],
          if (b.status.isActive && b.status != BookingStatus.awaitingWorker && b.status != BookingStatus.workStarted) ...[
            const SizedBox(height: 16),
            AppButton('Cancel booking', kind: BtnKind.danger, onPressed: () => s.cancelBooking(b.id, Party.customer)),
          ],
          SectionHeader('Offer history'),
          for (final o in b.offers)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Pill(o.by == Party.customer ? 'You' : 'Worker', color: o.by == Party.customer ? Brand.violet : Brand.success),
                const SizedBox(width: 8),
                Text(rupees(o.amount), style: Ty.title(p.text)),
                if (o.note.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(child: Text(o.note, style: Ty.small(p.textFaint), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ]),
            ),
        ],
      ),
    );
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
