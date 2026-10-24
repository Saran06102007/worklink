import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../../widgets/brand_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _t = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) context.read<AppState>().markSplashSeen();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DarkZone(
      child: Scaffold(
        backgroundColor: Brand.midnight,
        body: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final logoScale = seg(t, 0.0, 0.45, Curves.easeOutBack);
            final fade = seg(t, 0.25, 0.6);
            final tag = seg(t, 0.45, 0.85);
            return Stack(children: [
              Positioned(top: -120, right: -80, child: _blob(Brand.violet.op(0.3), 320)),
              Positioned(bottom: -100, left: -60, child: _blob(Brand.indigoSoft.op(0.35), 280)),
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Transform.scale(
                    scale: 0.55 + 0.45 * logoScale,
                    child: Opacity(opacity: logoScale.clamp(0.0, 1.0), child: const BrandMark(size: 88)),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: fade,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - fade)),
                      child: Text(AppConfig.brand, style: Ty.display(Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: tag,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - tag)),
                      child: Text(AppConfig.tagline, style: Ty.body(Colors.white.op(0.7))),
                    ),
                  ),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _blob(Color c, double s) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c, c.op(0)])),
      );
}
