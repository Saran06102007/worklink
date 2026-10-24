import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/config.dart';
import '../../core/tokens.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import '../common/demo_controls.dart';
import '../common/notifications_screen.dart';
import '../common/verification_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

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
          Text('Profile', style: Ty.h1(p.text)),
          const SizedBox(height: 16),
          GlassCard(
            child: Row(children: [
              Avatar(st.name, seed: 3, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(st.name, style: Ty.h2(p.text)),
                  Text('${st.course} · ${st.year}', style: Ty.small(p.textDim)),
                  Text(st.college, style: Ty.small(p.textFaint)),
                  const SizedBox(height: 4),
                  VerificationBadge(st.verification),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Row(children: [
              Icon(Icons.savings_outlined, color: p.accentSoft),
              const SizedBox(width: 12),
              Expanded(child: Text('Simulated earnings', style: Ty.body(p.text))),
              Text(rupees(s.studentEarned), style: Ty.title(p.accentSoft)),
            ]),
          ),
          SectionHeader('Account'),
          _tile(context, Icons.verified_user_outlined, 'Verification', () => pushPage(context, const VerificationScreen())),
          _tile(context, Icons.notifications_outlined, 'Notifications', () => pushPage(context, const NotificationsScreen()),
              badge: s.unread(UserRole.student)),
          _tile(context, Icons.tune_rounded, 'Demo controls', () => pushPage(context, const DemoControlsScreen())),
          _tile(context, Icons.info_outline_rounded, AppConfig.demoNote, null),
          const SizedBox(height: 20),
          AppButton('Sign out', kind: BtnKind.danger, onPressed: s.logout, icon: Icons.logout_rounded),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback? onTap, {int badge = 0}) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(children: [
          Icon(icon, color: p.accentSoft),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Ty.body(p.text))),
          if (badge > 0) Pill('$badge', color: Brand.danger),
          if (onTap != null) Icon(Icons.chevron_right_rounded, color: p.textFaint),
        ]),
      ),
    );
  }
}
