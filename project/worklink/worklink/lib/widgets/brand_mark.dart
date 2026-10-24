import 'package:flutter/material.dart';

import '../core/tokens.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final bool showWordmark;
  const BrandMark({super.key, this.size = 56, this.showWordmark = false});

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: Brand.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [BoxShadow(color: Brand.violet.op(0.45), blurRadius: size * 0.4, offset: Offset(0, size * 0.12))],
      ),
      child: Icon(Icons.handyman_rounded, color: Colors.white, size: size * 0.5),
    );
    if (!showWordmark) return mark;
    final p = Pal.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      mark,
      SizedBox(width: size * 0.22),
      Text('WorkLink', style: Ty.h1(p.text).copyWith(fontSize: size * 0.42)),
    ]);
  }
}
