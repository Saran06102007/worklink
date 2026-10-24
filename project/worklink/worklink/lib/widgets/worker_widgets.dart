import 'package:flutter/material.dart';

import '../core/tokens.dart';
import '../core/utils.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import 'ui.dart';

class WorkerCard extends StatelessWidget {
  final RankedWorker ranked;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  const WorkerCard({super.key, required this.ranked, this.onTap, this.onBook});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final w = ranked.worker;
    final cat = categoryById(w.categoryId);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Avatar(w.name, seed: w.seed, size: 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(w.name, style: Ty.title(p.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
              VerificationBadge(w.verification, compact: true),
            ]),
            const SizedBox(height: 3),
            Text('${cat.name} · ${w.years} yrs', style: Ty.small(p.textDim)),
            const SizedBox(height: 4),
            RatingRow(w.rating, w.reviewCount),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.place_rounded, size: 14, color: p.textFaint),
              const SizedBox(width: 3),
              Text('${distLabel(ranked.km)} · ${ranked.eta} min', style: Ty.small(p.textFaint)),
              const Spacer(),
              Text('${rupees(w.price)}/${w.unit}', style: Ty.title(p.accentSoft).copyWith(fontSize: 13)),
            ]),
            if (onBook != null) ...[
              const SizedBox(height: 10),
              AppButton('Book', onPressed: onBook, height: 40, expand: true, icon: Icons.event_available_rounded),
            ],
          ]),
        ),
      ]),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final ServiceCategory cat;
  final VoidCallback? onTap;
  const CategoryTile({super.key, required this.cat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Pressable(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: Brand.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(cat.name, style: Ty.title(p.text), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('from ${rupees(cat.basePrice)}', style: Ty.small(p.textDim)),
        ]),
      ),
    );
  }
}
