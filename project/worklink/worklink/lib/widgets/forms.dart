import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/tokens.dart';
import 'ui.dart';

class AppField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AppField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Ty.label(p.textDim)),
      const SizedBox(height: 6),
      TextFormField<String>(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscure,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        enabled: enabled,
        style: Ty.body(p.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Ty.body(p.textFaint),
          filled: true,
          fillColor: p.surface.op(p.dark ? 0.8 : 1),
          prefixIcon: prefix != null ? Icon(prefix, color: p.textFaint, size: 20) : null,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.m), borderSide: BorderSide(color: p.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.m), borderSide: BorderSide(color: p.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.m), borderSide: BorderSide(color: p.accent, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rd.m), borderSide: const BorderSide(color: Brand.danger)),
        ),
      ),
    ]);
  }
}

class ChipSelect extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool multi;
  const ChipSelect({super.key, required this.options, required this.selected, required this.onChanged, this.multi = true});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final on = selected.contains(o);
        return Pressable(
          onTap: () {
            final next = Set<String>.from(selected);
            if (multi) {
              on ? next.remove(o) : next.add(o);
            } else {
              next
                ..clear()
                ..add(o);
            }
            onChanged(next);
          },
          child: AnimatedContainer(
            duration: Dur.base,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: on ? Brand.primaryGradient : null,
              color: on ? null : p.surface.op(p.dark ? 0.8 : 1),
              borderRadius: BorderRadius.circular(Rd.pill),
              border: Border.all(color: on ? Colors.transparent : p.border),
            ),
            child: Text(o, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? Colors.white : p.textDim)),
          ),
        );
      }).toList(),
    );
  }
}

class StepDots extends StatelessWidget {
  final int total, current;
  const StepDots({super.key, required this.total, required this.current});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final on = i <= current;
        return AnimatedContainer(
          duration: Dur.base,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: on ? Brand.primaryGradient : null,
            color: on ? null : p.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
