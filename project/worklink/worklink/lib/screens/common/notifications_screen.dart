import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final role = s.role!;
    final list = s.notificationsFor(role);
    final p = Pal.of(context);

    return AppScaffold(
      title: 'Notifications',
      actions: [
        TextButton(
          onPressed: list.isEmpty ? null : () => s.markAllRead(role),
          child: Text('Mark all read', style: Ty.label(p.accentSoft)),
        ),
      ],
      body: list.isEmpty
          ? EmptyState(icon: Icons.notifications_none_rounded, title: 'All caught up', message: 'No notifications yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final n = list[i];
                final fresh = !n.read;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stagger(
                    index: i,
                    child: GlassCard(
                      onTap: () {
                        n.read = true;
                        s.notifyListeners();
                      },
                      padding: const EdgeInsets.all(14),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Brand.violet.op(fresh ? 0.22 : 0.10), shape: BoxShape.circle),
                          child: Icon(Icons.notifications_rounded, color: p.accentSoft, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: Ty.title(p.text)),
                            const SizedBox(height: 2),
                            Text(n.body, style: Ty.small(p.textDim)),
                            const SizedBox(height: 4),
                            Text(timeAgo(n.time), style: Ty.small(p.textFaint)),
                          ]),
                        ),
                        if (fresh) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Brand.violet, shape: BoxShape.circle)),
                      ]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
