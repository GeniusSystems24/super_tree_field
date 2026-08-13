// ============================================================
// example/lib/kpi_card.dart
// ------------------------------------------------------------
// A financial-summary KPI card: an uppercase English label + Arabic gloss, a
// large monospace value, an optional sub-line, and a 3px accent edge bar.
// Example-only presentation helper used by the chart-of-accounts demo.
// ============================================================

import 'package:flutter/widgets.dart';

import 'package:super_core/super_core.dart';

/// A KPI summary card used by the chart-of-accounts example.
class KpiCard extends StatelessWidget {
  /// Creates a KPI card with bilingual labels and an [accent] edge.
  const KpiCard({
    super.key,
    required this.label,
    required this.ar,
    required this.value,
    required this.accent,
    this.sub,
  });

  /// Primary KPI label.
  final String label;

  /// Arabic KPI label displayed beside [label].
  final String ar;

  /// Formatted KPI value.
  final String value;

  /// Accent color used by the leading edge.
  final Color accent;

  /// Optional supporting text shown below [value].
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(
          context.superTheme.spacing.radiusCard,
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
                        style: context.superTextTheme.label.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.6,
                          color: t.fg3,
                        ),
                      ),
                    ),
                    SizedBox(width: context.superTheme.spacing.space2),
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
                SizedBox(height: context.superTheme.spacing.space2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.superTextTheme.mono.copyWith(
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: t.fg1,
                  ),
                ),
                if (sub != null) ...[
                  SizedBox(height: context.superTheme.spacing.space2),
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.superTextTheme.caption.copyWith(
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
