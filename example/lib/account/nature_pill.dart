// ============================================================
// example/lib/nature_pill.dart
// ------------------------------------------------------------
// The DR / CR debit-credit pill — blue for debit, orange for credit — shown in
// the chart-of-accounts example's "Nature" column.
// ============================================================

import 'package:flutter/widgets.dart';

import 'package:super_core/super_core.dart';

/// A small DR / CR indicator used by the chart-of-accounts example.
class NaturePill extends StatelessWidget {
  /// Creates an indicator with [code] and debit/credit color semantics.
  const NaturePill(this.code, {super.key, required this.debit});

  /// Short label rendered inside the pill, such as `DR` or `CR`.
  final String code;

  /// Whether to use the debit color; false uses the credit color.
  final bool debit;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final c = debit
        ? SuperMaterialThemeData.of(context).colorScheme.primary
        : SuperThemeData.of(context).tokens.warning;
    return Container(
      height: 19,
      padding: EdgeInsets.symmetric(
        horizontal: context.superTheme.spacing.space2,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.withValues(alpha: 0.15), t.surface),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Color.alphaBlend(c.withValues(alpha: 0.35), t.surface),
        ),
      ),
      child: Text(
        code,
        style: context.superTextTheme.mono.copyWith(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: c,
        ),
      ),
    );
  }
}
