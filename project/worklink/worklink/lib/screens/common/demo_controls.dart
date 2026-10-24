import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class DemoControlsScreen extends StatelessWidget {
  const DemoControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final s = context.watch<AppState>();
    return AppScaffold(
      title: 'Demo controls',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('These controls only affect simulated behaviour. Nothing is real.', style: Ty.body(p.textDim)),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Auto-respond', style: Ty.title(p.text)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Workers auto-reply to offers', style: Ty.body(p.textDim)),
                value: s.autoRespond,
                onChanged: (v) => s.setDemo(auto: v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Fast timing (×3)', style: Ty.body(p.textDim)),
                value: s.fastTiming,
                onChanged: (v) => s.setDemo(fast: v),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Worker reply mode', style: Ty.title(p.text)),
              const SizedBox(height: 10),
              for (final m in DemoWorkerMode.values)
                RadioListTile<DemoWorkerMode>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(m.name, style: Ty.body(p.text)),
                  value: m,
                  groupValue: s.workerMode,
                  onChanged: (v) => s.setDemo(mode: v),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Forced verification outcome', style: Ty.title(p.text)),
              const SizedBox(height: 10),
              for (final o in ForcedOutcome.values)
                RadioListTile<ForcedOutcome>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(o.name, style: Ty.body(p.text)),
                  value: o,
                  groupValue: s.outcome,
                  onChanged: (v) => s.setDemo(forced: v),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Theme', style: Ty.title(p.text)),
              const SizedBox(height: 8),
              Segmented(
                items: const ['Dark', 'Light', 'System'],
                index: s.themeMode == ThemeMode.dark
                    ? 0
                    : s.themeMode == ThemeMode.light
                        ? 1
                        : 2,
                onChanged: (i) => s.setTheme([ThemeMode.dark, ThemeMode.light, ThemeMode.system][i]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
