// ============================================================
// features/super_tree_field/presentation/widgets/kpi_card.dart
// ------------------------------------------------------------
// A financial-summary KPI card: an uppercase English label + Arabic gloss, a
// large monospace value, an optional sub-line, and a 3px accent edge bar.
// Mirrors the React `<KpiCard>` atom. Used in the AccountTree summary grid.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/core.dart';

/// One KPI summary card (Total Assets, Net Income, …).
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.ar,
    required this.value,
    required this.accent,
    this.sub,
  });

  final String label;
  final String ar;
  final String value;
  final Color accent;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(
          SuperThemeData.of(context).tokens.radiusCard,
        ),
        border: Border.all(color: t.border),
        boxShadow: t.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: accent),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style: SuperText.label.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.6,
                          color: t.fg3,
                        ),
                      ),
                    ),
                    SizedBox(width: SuperThemeData.of(context).tokens.space2),
                    Text(
                      ar,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: SuperThemeData.of(
                          context,
                        ).tokens.arabicFont,
                        fontSize: 11,
                        color: t.fg4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SuperThemeData.of(context).tokens.space2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SuperText.mono.copyWith(
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: t.fg1,
                  ),
                ),
                if (sub != null) ...[
                  SizedBox(height: SuperThemeData.of(context).tokens.space2),
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SuperText.caption.copyWith(
                      fontSize: 11,
                      color: t.fg3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
