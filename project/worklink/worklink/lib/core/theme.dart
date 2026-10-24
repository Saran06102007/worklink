import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

ThemeData? _darkCache;
ThemeData? _lightCache;
ThemeData get darkTheme => _darkCache ??= buildTheme(Brightness.dark);
ThemeData get lightTheme => _lightCache ??= buildTheme(Brightness.light);

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Pal.darkPal : Pal.lightPal;
  final scheme = ColorScheme.fromSeed(seedColor: Brand.violet, brightness: b).copyWith(
    primary: p.accent,
    surface: p.surface,
  );
  final base = ThemeData(useMaterial3: true, brightness: b, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    textTheme: base.textTheme.apply(bodyColor: p.text, displayColor: p.text),
    dividerColor: p.border,
    splashColor: Brand.violet.op(0.10),
    highlightColor: Colors.transparent,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {for (final t in TargetPlatform.values) t: const FadeSlideTransitionsBuilder()},
    ),
  );
}

/// Forces the dark palette for a subtree (splash, welcome, auth).
class DarkZone extends StatelessWidget {
  final Widget child;
  const DarkZone({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Theme(data: darkTheme, child: child);
}