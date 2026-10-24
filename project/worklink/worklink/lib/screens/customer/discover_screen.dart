import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/motion.dart';
import '../../core/tokens.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import '../../widgets/worker_widgets.dart';
import 'booking_request_screen.dart';
import 'worker_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String? _cat;
  String _query = '';
  bool _verifiedOnly = false;
  bool _availableOnly = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final preset = context.read<AppState>().takeDiscoverCategory();
    if (preset != null) _cat = preset;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final ranked = s.rank(
      categoryId: _cat,
      availableOnly: _availableOnly,
      verifiedOnly: _verifiedOnly,
      query: _query,
    );

    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Discover', style: Ty.h1(p.text)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              style: Ty.body(p.text),
              decoration: InputDecoration(
                hintText: 'Search name, skill…',
                hintStyle: Ty.body(p.textFaint),
                prefixIcon: Icon(Icons.search_rounded, color: p.textFaint),
                filled: true,
                fillColor: p.surface.op(p.dark ? 0.8 : 1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.m), borderSide: BorderSide(color: p.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.m), borderSide: BorderSide(color: p.border)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(null, 'All'),
                  for (final c in kCategories) _filterChip(c.id, c.name),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              FilterChip(
                label: const Text('Available'),
                selected: _availableOnly,
                onSelected: (v) => setState(() => _availableOnly = v),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Verified'),
                selected: _verifiedOnly,
                onSelected: (v) => setState(() => _verifiedOnly = v),
              ),
              const Spacer(),
              Text('${ranked.length} found', style: Ty.small(p.textFaint)),
            ]),
          ]),
        ),
        Expanded(
          child: ranked.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No workers match',
                  message: 'Try clearing filters or choosing another category.',
                  actionLabel: 'Clear filters',
                  onAction: () => setState(() {
                    _cat = null;
                    _query = '';
                    _verifiedOnly = false;
                    _availableOnly = true;
                  }),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: ranked.length,
                  itemBuilder: (_, i) {
                    final r = ranked[i];
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
                ),
        ),
      ]),
    );
  }

  Widget _filterChip(String? id, String label) {
    final on = _cat == id;
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _cat = id),
        child: AnimatedContainer(
          duration: Dur.base,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: on ? Brand.primaryGradient : null,
            color: on ? null : p.surface.op(p.dark ? 0.8 : 1),
            borderRadius: BorderRadius.circular(Rd.pill),
            border: Border.all(color: on ? Colors.transparent : p.border),
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? Colors.white : p.textDim)),
        ),
      ),
    );
  }
}
