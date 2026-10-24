import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/ui.dart';
import '../auth/login_screen.dart';
import '../common/demo_controls.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return DarkZone(
      child: AppScaffold(
        showBack: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                const BrandMark(size: 40, showWordmark: true),
                const Spacer(),
                IconButton(
                  onPressed: () => pushPage(context, const DemoControlsScreen()),
                  icon: Icon(Icons.tune_rounded, color: p.textDim),
                  tooltip: 'Demo controls',
                ),
              ]),
              const SizedBox(height: 32),
              Text('How will you use\nWorkLink?', style: Ty.h1(p.text)),
              const SizedBox(height: 8),
              Text(AppConfig.demoNote, style: Ty.small(p.textFaint)),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    for (final r in UserRole.values) ...[
                      _RoleCard(role: r),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              Text('Demo accounts use password demo123', style: Ty.small(p.textFaint), textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  const _RoleCard({required this.role});

  String get _blurb {
    switch (role) {
      case UserRole.customer:
        return 'Find verified local workers, negotiate prices, track jobs.';
      case UserRole.worker:
        return 'Receive job requests, counter offers, earn near you.';
      case UserRole.student:
        return 'Pick up short gigs — tutoring, events, data entry.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final state = context.read<AppState>();
    return GlassCard(
      padding: const EdgeInsets.all(18),
      onTap: () => pushPage(context, LoginScreen(role: role)),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: Brand.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(role.icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role.label, style: Ty.h3(p.text)),
            const SizedBox(height: 3),
            Text(_blurb, style: Ty.small(p.textDim)),
          ]),
        ),
        Column(children: [
          AppButton('Demo', onPressed: () => state.loginDemo(role), expand: false, height: 36),
          const SizedBox(height: 6),
          Text('or sign in', style: Ty.caps(p.textFaint)),
        ]),
      ]),
    );
  }
}
