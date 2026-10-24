import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class StudentJobsScreen extends StatefulWidget {
  const StudentJobsScreen({super.key});
  @override
  State<StudentJobsScreen> createState() => _StudentJobsScreenState();
}

class _StudentJobsScreenState extends State<StudentJobsScreen> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final jobs = s.studentJobs.where((j) => _type == null || j.type == _type).toList();

    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Student jobs', style: Ty.h1(p.text)),
            const SizedBox(height: 4),
            Text('Short gigs near campus (simulated).', style: Ty.small(p.textDim)),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip(null, 'All'),
                  for (final t in kStudentTypes) _chip(t, t),
                ],
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: jobs.length,
            itemBuilder: (_, i) {
              final j = jobs[i];
              final app = s.applicationFor(j.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Stagger(
                  index: i,
                  child: GlassCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(gradient: Brand.primaryGradient, borderRadius: BorderRadius.circular(12)),
                          child: Icon(j.icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(j.title, style: Ty.title(p.text)),
                            Text(j.business, style: Ty.small(p.textDim)),
                          ]),
                        ),
                        Text(j.payLabel, style: Ty.small(p.accentSoft)),
                      ]),
                      const SizedBox(height: 10),
                      Text(j.description, style: Ty.body(p.textDim)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, children: [
                        Pill(j.type, color: Brand.violet),
                        Pill(j.mode, color: Brand.indigoSoft),
                        Pill(j.schedule, color: p.textFaint),
                      ]),
                      const SizedBox(height: 12),
                      if (app == null)
                        AppButton('Apply', onPressed: () => s.applyToJob(j), height: 42)
                      else
                        Pill(app.status.name, color: Brand.success, icon: Icons.check_rounded),
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

  Widget _chip(String? id, String label) {
    final on = _type == id;
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _type = id),
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
