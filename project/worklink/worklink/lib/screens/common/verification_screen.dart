import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tokens.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/ui.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final role = s.role!;
    final v = s.verificationOf(role);
    final note = s.verifyNoteOf(role);
    final p = Pal.of(context);

    return AppScaffold(
      title: 'Verification',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(children: [
              Icon(v.icon, size: 48, color: v.color),
              const SizedBox(height: 12),
              Text(v.label, style: Ty.h2(p.text)),
              if (note != null) ...[
                const SizedBox(height: 8),
                Text(note, style: Ty.body(p.textDim), textAlign: TextAlign.center),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Simulated document upload', style: Ty.title(p.text)),
              const SizedBox(height: 8),
              Text('No real documents are stored. Tapping submit starts a timed admin review.', style: Ty.small(p.textDim)),
              const SizedBox(height: 16),
              AppButton(
                v == Verification.pending ? 'Review in progress…' : 'Submit documents',
                onPressed: v == Verification.pending ? null : () => s.submitVerification(role),
                icon: Icons.upload_file_rounded,
              ),
              if (v == Verification.rejected) ...[
                const SizedBox(height: 8),
                AppButton('Re-submit', onPressed: () => s.submitVerification(role), kind: BtnKind.secondary),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Demo admin override', style: Ty.title(p.text)),
              const SizedBox(height: 8),
              for (final status in Verification.values)
                if (status != Verification.notStarted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppButton(
                      'Force ${status.label}',
                      kind: BtnKind.secondary,
                      onPressed: () => s.forceVerification(role, status),
                    ),
                  ),
            ]),
          ),
        ],
      ),
    );
  }
}
