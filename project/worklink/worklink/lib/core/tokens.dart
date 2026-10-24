import 'package:flutter/material.dart';

extension ColorAlpha on Color {
  /// Opacity helper that works on every Flutter version.
  Color op(double opacity) => withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

class Brand {
  static const midnight = Color(0xFF060A1C);
  static const navy = Color(0xFF0B1230);
  static const indigo = Color(0xFF1E2470);
  static const indigoSoft = Color(0xFF3A3FA8);
  static const violet = Color(0xFF7C5CFF);
  static const violetSoft = Color(0xFFA48BFF);
  static const white = Color(0xFFFFFFFF);
  static const success = Color(0xFF2EC4A0);
  static const warning = Color(0xFFFFB454);
  static const danger = Color(0xFFFF5C7A);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9272FF), Color(0xFF5B3DF5)],
  );
  static const deepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2F8F), Color(0xFF121A52)],
  );
}

class Sp {
  static const double xs = 4, s = 8, m = 12, l = 16, xl = 20, xxl = 24, x3 = 32, x4 = 48;
}

class Rd {
  static const double s = 10, m = 16, l = 22, xl = 28, pill = 999;
}

class Dur {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);
}

/// Surface palette that adapts to light / dark.
class Pal {
  final bool dark;
  final Color bg, bgAlt, surface, surfaceHi, border, text, textDim, textFaint, accent, accentSoft, shadow;
  const Pal({
    required this.dark,
    required this.bg,
    required this.bgAlt,
    required this.surface,
    required this.surfaceHi,
    required this.border,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.accentSoft,
    required this.shadow,
  });

  static const darkPal = Pal(
    dark: true,
    bg: Brand.midnight,
    bgAlt: Brand.navy,
    surface: Color(0xFF111A3D),
    surfaceHi: Color(0xFF1A2560),
    border: Color(0x26FFFFFF),
    text: Color(0xFFF4F6FF),
    textDim: Color(0xFFB4BAD9),
    textFaint: Color(0xFF7C84AD),
    accent: Brand.violet,
    accentSoft: Brand.violetSoft,
    shadow: Color(0x66000000),
  );

  static const lightPal = Pal(
    dark: false,
    bg: Color(0xFFF3F4FC),
    bgAlt: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceHi: Color(0xFFECEEFB),
    border: Color(0x1A0B1230),
    text: Brand.navy,
    textDim: Color(0xFF454C7C),
    textFaint: Color(0xFF8187B0),
    accent: Color(0xFF5B3DF5),
    accentSoft: Brand.violet,
    shadow: Color(0x1A0B1230),
  );

  static Pal of(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? darkPal : lightPal;
}

class Ty {
  static TextStyle display(Color c) =>
      TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.08, color: c);
  static TextStyle h1(Color c) =>
      TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.15, color: c);
  static TextStyle h2(Color c) =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.2, color: c);
  static TextStyle h3(Color c) =>
      TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: c);
  static TextStyle title(Color c) => TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c);
  static TextStyle body(Color c) => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: c);
  static TextStyle small(Color c) => TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.35, color: c);
  static TextStyle label(Color c) => TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: c);
  static TextStyle caps(Color c) => TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: c);
}