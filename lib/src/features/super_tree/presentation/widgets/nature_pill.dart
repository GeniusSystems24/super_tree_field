// ============================================================
// features/super_tree_field/presentation/widgets/nature_pill.dart
// ------------------------------------------------------------
// The DR / CR debit-credit pill — blue for debit, orange for credit — shown in
// the account tree's "Nature" column. Mirrors the React `<NaturePill>` atom.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/core.dart';
import '../../domain/entities/account_data.dart';

/// A small DR / CR pill colored by [nature].
class NaturePill extends StatelessWidget {
  const NaturePill(this.nature, {super.key});

  final AccountNature nature;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final dr = nature == AccountNature.debit;
    final c = dr ? SuperTokens.accent : SuperTokens.warning;
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: SuperTokens.space2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.withOpacity(0.15), t.surface),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Color.alphaBlend(c.withOpacity(0.35), t.surface)),
      ),
      child: Text(
        nature.code,
        style: SuperText.mono.copyWith(
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
