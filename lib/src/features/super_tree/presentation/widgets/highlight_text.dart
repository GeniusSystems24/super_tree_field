// ============================================================
// features/super_tree/presentation/widgets/highlight_text.dart
// ------------------------------------------------------------
// Renders [text] with the first case-insensitive match of [query] wrapped in an
// accent-tinted highlight — the tree's search emphasis. Mirrors the React
// `<Highlight>` atom.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/core.dart';

/// Text with the matched search substring highlighted.
class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return Text(text, style: style, overflow: overflow, maxLines: 1);
    }
    final idx = text.toLowerCase().indexOf(needle);
    if (idx < 0) {
      return Text(text, style: style, overflow: overflow, maxLines: 1);
    }
    final t = context.superTheme;
    final mark = Color.alphaBlend(SuperTokens.accent.withOpacity(0.32), t.surface);
    return RichText(
      maxLines: 1,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + needle.length),
            style: TextStyle(background: Paint()..color = mark),
          ),
          TextSpan(text: text.substring(idx + needle.length)),
        ],
      ),
    );
  }
}
