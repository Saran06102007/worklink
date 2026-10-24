import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/tokens.dart';
import '../models/models.dart';

/// Ambient background. Must be used as a direct child of a Stack.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.bg, p.bgAlt],
            ),
          ),
          child: Stack(children: [
            Positioned(top: -140, right: -120, child: _Glow(Brand.violet.op(p.dark ? 0.26 : 0.14), 360)),
            Positioned(bottom: -170, left: -150, child: _Glow(Brand.indigoSoft.op(p.dark ? 0.28 : 0.09), 420)),
          ]),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow(this.color, this.size);
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.op(0)])),
      );
}

/// Standard screen frame: ambient background + transparent scaffold.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBack;
  const AppScaffold({super.key, required this.body, this.title, this.actions, this.bottom, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Stack(children: [
      const AuroraBackground(),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: title == null
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: p.text,
                automaticallyImplyLeading: showBack,
                title: Text(title!, style: Ty.h3(p.text)),
                actions: actions,
              ),
        body: body,
        bottomNavigationBar: bottom,
      ),
    ]);
  }
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97});
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down && !still ? widget.scale : 1,
        duration: still ? Duration.zero : Dur.fast,
        child: widget.child,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool blur, glow;
  final Color? tint;
  final Gradient? gradient;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.l),
    this.radius = Rd.l,
    this.onTap,
    this.blur = false,
    this.glow = false,
    this.tint,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final deco = BoxDecoration(
      color: gradient == null ? (tint ?? p.surface.op(p.dark ? 0.74 : 0.94)) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: p.border),
      boxShadow: blur
          ? null
          : [BoxShadow(color: glow ? Brand.violet.op(0.30) : p.shadow, blurRadius: glow ? 30 : 16, offset: const Offset(0, 8))],
    );
    Widget w = Container(padding: padding, decoration: deco, child: child);
    if (blur) {
      w = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: w),
      );
    }
    return onTap == null ? w : Pressable(onTap: onTap, child: w);
  }
}

enum BtnKind { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading, expand;
  final BtnKind kind;
  final double height;
  const AppButton(this.label,
      {super.key, this.onPressed, this.icon, this.loading = false, this.expand = true, this.kind = BtnKind.primary, this.height = 52});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final enabled = onPressed != null && !loading;
    Color fg;
    BoxDecoration deco;
    switch (kind) {
      case BtnKind.primary:
        fg = Colors.white;
        deco = BoxDecoration(
          gradient: Brand.primaryGradient,
          borderRadius: BorderRadius.circular(Rd.m),
          boxShadow: [BoxShadow(color: Brand.violet.op(0.40), blurRadius: 18, offset: const Offset(0, 8))],
        );
        break;
      case BtnKind.secondary:
        fg = p.text;
        deco = BoxDecoration(
            color: p.surfaceHi.op(p.dark ? 0.7 : 1), borderRadius: BorderRadius.circular(Rd.m), border: Border.all(color: p.border));
        break;
      case BtnKind.danger:
        fg = Brand.danger;
        deco = BoxDecoration(
            color: Brand.danger.op(0.12), borderRadius: BorderRadius.circular(Rd.m), border: Border.all(color: Brand.danger.op(0.4)));
        break;
      case BtnKind.ghost:
        fg = p.accentSoft;
        deco = BoxDecoration(borderRadius: BorderRadius.circular(Rd.m));
        break;
    }
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        else ...[
          if (icon != null) ...[Icon(icon, size: 19, color: fg), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w700))),
        ],
      ],
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Pressable(
          onTap: enabled ? onPressed : null,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: deco,
            child: content,
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool dot;
  const Pill(this.label, {super.key, required this.color, this.icon, this.dot = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.op(0.15),
          borderRadius: BorderRadius.circular(Rd.pill),
          border: Border.all(color: color.op(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot) Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      );
}

class VerificationBadge extends StatelessWidget {
  final Verification v;
  final bool compact;
  const VerificationBadge(this.v, {super.key, this.compact = false});
  @override
  Widget build(BuildContext context) {
    if (compact && v == Verification.verified) {
      return Tooltip(message: 'Verified (simulated)', child: Icon(Icons.verified_rounded, size: 18, color: v.color));
    }
    return Pill(v.label, color: v.color, icon: v.icon);
  }
}

class StatusChip extends StatelessWidget {
  final BookingStatus s;
  const StatusChip(this.s, {super.key});
  @override
  Widget build(BuildContext context) => Pill(s.label, color: s.color, icon: s.icon);
}

class DemoTag extends StatelessWidget {
  const DemoTag({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border)),
      child: Text('DEMO', style: Ty.caps(p.textFaint).copyWith(fontSize: 8.5, letterSpacing: 0.8)),
    );
  }
}

class RatingRow extends StatelessWidget {
  final double rating;
  final int count;
  final bool showDemo;
  const RatingRow(this.rating, this.count, {super.key, this.showDemo = true});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    if (count == 0) return Text('New on WorkLink', style: Ty.small(p.textDim));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, size: 16, color: Brand.warning),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1), style: Ty.title(p.text).copyWith(fontSize: 13)),
      const SizedBox(width: 3),
      Text('($count)', style: Ty.small(p.textDim)),
      if (showDemo) ...[const SizedBox(width: 6), const DemoTag()],
    ]);
  }
}

class Avatar extends StatelessWidget {
  final String name;
  final int seed;
  final double size;
  const Avatar(this.name, {super.key, this.seed = 0, this.size = 48});
  static const _g = [
    [Color(0xFF7C5CFF), Color(0xFF3A3FA8)],
    [Color(0xFF5B8CFF), Color(0xFF2A2F8F)],
    [Color(0xFF9B6BFF), Color(0xFF5B3DF5)],
    [Color(0xFF4F6BFF), Color(0xFF1E2470)],
  ];
  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length == 1 ? parts.first.substring(0, 1) : '${parts.first[0]}${parts.last[0]}';
    final g = _g[seed.abs() % _g.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g),
        border: Border.all(color: Colors.white.op(0.25)),
      ),
      child: Text(initials.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.36)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Sp.xl, 0, Sp.m),
      child: Row(children: [
        Expanded(child: Text(title, style: Ty.h3(p.text))),
        if (action != null)
          GestureDetector(onTap: onAction, child: Text(action!, style: Ty.label(p.accentSoft).copyWith(fontSize: 13))),
      ]),
    );
  }
}

class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 8});
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  bool _init = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    if (!reduceMotion(context)) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(p.surface, p.surfaceHi, _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.x3),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Brand.violet.op(0.12),
              border: Border.all(color: Brand.violet.op(0.3)),
              boxShadow: [BoxShadow(color: Brand.violet.op(0.2), blurRadius: 30)],
            ),
            child: Icon(icon, size: 36, color: p.accentSoft),
          ),
          const SizedBox(height: Sp.xl),
          Text(title, style: Ty.h2(p.text), textAlign: TextAlign.center),
          const SizedBox(height: Sp.s),
          Text(message, style: Ty.body(p.textDim), textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: Sp.xl),
            AppButton(actionLabel!, onPressed: onAction, expand: false),
          ],
        ]),
      ),
    );
  }
}

class Segmented extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  const Segmented({super.key, required this.items, required this.index, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.surface.op(p.dark ? 0.8 : 1), borderRadius: BorderRadius.circular(Rd.m), border: Border.all(color: p.border)),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: Dur.base,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: i == index ? Brand.primaryGradient : null,
                  borderRadius: BorderRadius.circular(Rd.m - 4),
                ),
                child: Text(items[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: i == index ? Colors.white : p.textDim)),
              ),
            ),
          ),
      ]),
    );
  }
}

class NavItem {
  final IconData icon, activeIcon;
  final String label;
  final int badge;
  const NavItem(this.icon, this.activeIcon, this.label, {this.badge = 0});
}

class GlassNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onTap;
  const GlassNavBar({super.key, required this.items, required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: p.surface.op(p.dark ? 0.82 : 0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: p.border),
              ),
              child: Row(children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == index,
                      label: items[i].label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          AnimatedContainer(
                            duration: Dur.base,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              color: i == index ? Brand.violet.op(0.22) : Colors.transparent,
                              borderRadius: BorderRadius.circular(Rd.pill),
                            ),
                            child: Stack(clipBehavior: Clip.none, children: [
                              Icon(i == index ? items[i].activeIcon : items[i].icon,
                                  size: 23, color: i == index ? p.accentSoft : p.textFaint),
                              if (items[i].badge > 0)
                                Positioned(
                                  right: -8,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: Brand.danger, borderRadius: BorderRadius.circular(10)),
                                    child: Text('${items[i].badge}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                            ]),
                          ),
                          const SizedBox(height: 2),
                          Text(items[i].label,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: i == index ? p.accentSoft : p.textFaint)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
