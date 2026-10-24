import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/motion.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import 'customer_booking_detail.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});
  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  int _seg = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final all = s.customerBookings;
    final list = _seg == 0
        ? all.where((b) => b.status.isActive).toList()
        : all.where((b) => !b.status.isActive).toList();

    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bookings', style: Ty.h1(p.text)),
            const SizedBox(height: 12),
            Segmented(items: const ['Active', 'Past'], index: _seg, onChanged: (i) => setState(() => _seg = i)),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: _seg == 0 ? 'No active bookings' : 'No past bookings',
                  message: 'Book a worker from Discover to get started.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final b = list[i];
                    final w = s.workerById(b.workerId);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Stagger(
                        index: i,
                        child: GlassCard(
                          onTap: () => pushPage(context, CustomerBookingDetailScreen(bookingId: b.id)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              StatusChip(b.status),
                              const Spacer(),
                              Text(timeAgo(b.createdAt), style: Ty.small(p.textFaint)),
                            ]),
                            const SizedBox(height: 10),
                            Text(categoryById(b.categoryId).name, style: Ty.h3(p.text)),
                            Text(b.details, style: Ty.body(p.textDim), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Row(children: [
                              if (w != null) ...[
                                Avatar(w.name, seed: w.seed, size: 28),
                                const SizedBox(width: 8),
                                Text(w.name, style: Ty.small(p.text)),
                              ],
                              const Spacer(),
                              Text(rupees(b.shownPrice), style: Ty.title(p.accentSoft)),
                            ]),
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
