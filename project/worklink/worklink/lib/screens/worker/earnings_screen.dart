import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final daily = s.workerDailyTotals();
    final maxV = daily.fold<int>(1, (m, v) => v > m ? v : m);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Text('Earnings', style: Ty.h1(p.text)),
          const SizedBox(height: 16),
          GlassCard(
            gradient: Brand.primaryGradient,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total earned (simulated)', style: Ty.small(Colors.white.op(0.8))),
              const SizedBox(height: 6),
              Text(rupees(s.workerTotalEarned), style: Ty.display(Colors.white).copyWith(fontSize: 36)),
              const SizedBox(height: 8),
              Text('Last 7 days: ${rupees(s.workerEarnedSince(const Duration(days: 7)))}', style: Ty.body(Colors.white.op(0.85))),
            ]),
          ),
          SectionHeader('Last 7 days'),
          GlassCard(
            child: SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < daily.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text(daily[i] > 0 ? '${(daily[i] / 100).round()}' : '', style: Ty.caps(p.textFaint).copyWith(fontSize: 8)),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: Dur.base,
                            height: 20 + (daily[i] / maxV) * 100,
                            decoration: BoxDecoration(
                              gradient: Brand.primaryGradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], style: Ty.small(p.textFaint)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SectionHeader('Completed jobs'),
          if (s.workerDone.isEmpty)
            GlassCard(child: Text('No completed jobs yet.', style: Ty.body(p.textDim)))
          else
            for (final b in s.workerDone.take(15))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.customerName, style: Ty.title(p.text)),
                        Text(timeAgo(b.doneAt ?? b.createdAt), style: Ty.small(p.textFaint)),
                      ]),
                    ),
                    Text(rupees(b.shownPrice), style: Ty.title(p.accentSoft)),
                    if (b.paid) ...[const SizedBox(width: 8), Icon(Icons.check_circle_rounded, size: 18, color: Brand.success)],
                  ]),
                ),
              ),
        ],
      ),
    );
  }
}
