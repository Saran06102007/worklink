import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class StudentScheduleScreen extends StatelessWidget {
  const StudentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final st = s.meStudent!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Text('Availability', style: Ty.h1(p.text)),
          const SizedBox(height: 8),
          Text('Toggle the slots you can work. Simulated only.', style: Ty.small(p.textDim)),
          const SizedBox(height: 16),
          for (final day in kDays) ...[
            Text(day, style: Ty.title(p.text)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kSlots.map((slot) {
                final key = '$day·$slot';
                final on = st.slots.contains(key);
                return GestureDetector(
                  onTap: () => s.toggleSlot(key),
                  child: AnimatedContainer(
                    duration: Dur.base,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: on ? Brand.primaryGradient : null,
                      color: on ? null : p.surfaceHi.op(p.dark ? 0.6 : 1),
                      borderRadius: BorderRadius.circular(Rd.pill),
                      border: Border.all(color: on ? Colors.transparent : p.border),
                    ),
                    child: Text(slot, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? Colors.white : p.textDim)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
