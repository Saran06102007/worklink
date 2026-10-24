import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/config.dart';
import '../../core/tokens.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';
import '../common/demo_controls.dart';
import '../common/notifications_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = Pal.of(context);
    final c = s.customer!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Text('Profile', style: Ty.h1(p.text)),
          const SizedBox(height: 16),
          GlassCard(
            child: Row(children: [
              Avatar(c.name, seed: 1, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: Ty.h2(p.text)),
                  Text(c.email, style: Ty.small(p.textDim)),
                  Text(c.phone, style: Ty.small(p.textDim)),
                  const SizedBox(height: 4),
                  Pill(c.phoneVerified ? 'Phone verified' : 'Unverified', color: c.phoneVerified ? Brand.success : Brand.warning),
                ]),
              ),
            ]),
          ),
          SectionHeader('Account'),
          _tile(context, Icons.notifications_outlined, 'Notifications', () => pushPage(context, const NotificationsScreen()),
              badge: s.unread(UserRole.customer)),
          _tile(context, Icons.tune_rounded, 'Demo controls', () => pushPage(context, const DemoControlsScreen())),
          _tile(context, Icons.info_outline_rounded, AppConfig.demoNote, null),
          const SizedBox(height: 20),
          AppButton('Sign out', kind: BtnKind.danger, onPressed: () {
            s.logout();
          }, icon: Icons.logout_rounded),
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
