import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import 'booking_request_screen.dart';

class WorkerDetailScreen extends StatelessWidget {
  final String workerId;
  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final w = s.workerById(workerId);
    if (w == null) {
      return AppScaffold(title: 'Worker', body: const Center(child: Text('Worker not found')));
    }
    final p = Pal.of(context);
    final cat = categoryById(w.categoryId);
    final km = distanceKm(s.userLocation, w.location);

    return AppScaffold(
      title: w.name,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          Row(children: [
            Avatar(w.name, seed: w.seed, size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(w.name, style: Ty.h2(p.text))),
                  VerificationBadge(w.verification),
                ]),
                Text('${cat.name} · ${w.years} yrs exp', style: Ty.body(p.textDim)),
                RatingRow(w.rating, w.reviewCount),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _stat(p, Icons.work_history_rounded, '${w.jobsDone}', 'Jobs'),
                _stat(p, Icons.place_rounded, distLabel(km), 'Away'),
                _stat(p, Icons.payments_rounded, rupees(w.price), '/${w.unit}'),
              ]),
              const SizedBox(height: 12),
              Text(w.bio, style: Ty.body(p.textDim)),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: w.skills.map((sk) => Pill(sk, color: p.accent)).toList()),
            ]),
          ),
          SectionHeader('Portfolio'),
          for (final item in w.portfolio)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Icon(item.icon, color: p.accentSoft),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.title, style: Ty.title(p.text)),
                      Text(item.detail, style: Ty.small(p.textDim)),
                    ]),
                  ),
                ]),
              ),
            ),
          SectionHeader('Reviews'),
          for (final r in w.reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(r.author, style: Ty.title(p.text)),
                    const Spacer(),
                    ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 16, color: Brand.warning)),
                  ]),
                  const SizedBox(height: 4),
                  Text(r.text, style: Ty.body(p.textDim)),
                  const SizedBox(height: 4),
                  Text(timeAgo(r.date), style: Ty.small(p.textFaint)),
                ]),
              ),
            ),
        ],
      ),
      bottom: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: AppButton(
            w.available ? 'Request booking' : 'Currently unavailable',
            onPressed: w.available
                ? () => pushPage(context, BookingRequestScreen(categoryId: w.categoryId, worker: w))
                : null,
            icon: Icons.event_available_rounded,
          ),
        ),
      ),
    );
  }

  Widget _stat(Pal p, IconData icon, String v, String l) => Expanded(
        child: Column(children: [
          Icon(icon, size: 20, color: p.accentSoft),
          const SizedBox(height: 4),
          Text(v, style: Ty.title(p.text)),
          Text(l, style: Ty.small(p.textFaint)),
        ]),
      );
}
