import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/config.dart';
import '../../core/motion.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import '../../widgets/worker_widgets.dart';
import '../common/notifications_screen.dart';
import 'booking_request_screen.dart';
import 'worker_detail_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final c = s.customer!;
    final nearby = s.rank(availableOnly: true, maxKm: 8).take(5).toList();
    final active = s.customerBookings.where((b) => b.status.isActive).take(2).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Hi, ${c.name.split(' ').first}', style: Ty.h1(p.text)),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _pickArea(context, s),
                        child: Row(children: [
                          Icon(Icons.place_rounded, size: 16, color: p.accentSoft),
                          const SizedBox(width: 4),
                          Text(c.areaName, style: Ty.small(p.accentSoft)),
                          Icon(Icons.expand_more_rounded, size: 18, color: p.accentSoft),
                        ]),
                      ),
                    ]),
                  ),
                  IconButton(
                    onPressed: () => pushPage(context, const NotificationsScreen()),
                    icon: Badge(
                      isLabelVisible: s.unread(UserRole.customer) > 0,
                      label: Text('${s.unread(UserRole.customer)}'),
                      child: Icon(Icons.notifications_outlined, color: p.text),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                GlassCard(
                  gradient: Brand.primaryGradient,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Need help nearby?', style: Ty.h2(Colors.white)),
                    const SizedBox(height: 4),
                    Text(AppConfig.tagline, style: Ty.body(Colors.white.op(0.85))),
                    const SizedBox(height: 14),
                    AppButton('Find nearest worker', onPressed: () => s.openDiscover(), kind: BtnKind.secondary, expand: false, height: 42),
                  ]),
                ),
                SectionHeader('Categories', action: 'See all', onAction: () => s.openDiscover()),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                      width: 130,
                      child: Stagger(
                        index: i,
                        child: CategoryTile(cat: kCategories[i], onTap: () => s.openDiscover(categoryId: kCategories[i].id)),
                      ),
                    ),
                  ),
                ),
                if (active.isNotEmpty) ...[
                  SectionHeader('Active jobs'),
                  for (final b in active)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        onTap: () {},
                        child: Row(children: [
                          StatusChip(b.status),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(categoryById(b.categoryId).name, style: Ty.title(p.text)),
                              Text(b.details, style: Ty.small(p.textDim), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ]),
                          ),
                          Text(rupees(b.shownPrice), style: Ty.title(p.accentSoft)),
                        ]),
                      ),
                    ),
                ],
                SectionHeader('Nearby workers', action: 'Map', onAction: () => s.openDiscover()),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final r = nearby[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Stagger(
                      index: i,
                      child: WorkerCard(
                        ranked: r,
                        onTap: () => pushPage(context, WorkerDetailScreen(workerId: r.worker.id)),
                        onBook: () => pushPage(
                          context,
                          BookingRequestScreen(categoryId: r.worker.categoryId, worker: r.worker),
                        ),
                      ),
                    ),
                  );
                },
                childCount: nearby.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickArea(BuildContext context, AppState s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pal.of(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final p = Pal.of(ctx);
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Text('Choose area', style: Ty.h3(p.text)),
            const SizedBox(height: 8),
            for (final a in kAreas)
              ListTile(
                title: Text(a.name, style: Ty.body(p.text)),
                trailing: s.customer?.areaName == a.name ? Icon(Icons.check_rounded, color: p.accent) : null,
                onTap: () {
                  s.setCustomerArea(a);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }
}
