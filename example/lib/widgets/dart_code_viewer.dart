// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:super_core/super_core.dart';

/// Displays Dart usage code with syntax highlighting.
///
/// This mirrors the code-viewer experience used by the
/// `super_naviagtion_page` example while remaining example-only.
class DartCodeViewer extends StatelessWidget {
  const DartCodeViewer({
    super.key,
    required this.code,
    this.title,
  });

  final String code;
  final String? title;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  String _title(BuildContext context) =>
      title ?? (_isArabic(context) ? 'كود الاستخدام Dart' : 'Dart usage code');

  String _copyLabel(BuildContext context) =>
      _isArabic(context) ? 'نسخ الكود' : 'Copy code';

  String _copiedLabel(BuildContext context) => _isArabic(context)
      ? 'تم نسخ كود الاستخدام إلى الحافظة.'
      : 'Dart usage code copied to the clipboard.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = SuperThemeData.of(context).spacing;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(spacing.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CodeViewerHeader(
            title: _title(context),
            copyLabel: _copyLabel(context),
            onCopy: () => _copyCode(context),
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SyntaxView(
                code: code,
                syntax: Syntax.DART,
                syntaxTheme:
                    isDark ? SyntaxTheme.vscodeDark() : SyntaxTheme.ayuLight(),
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 11.5 : 12.5,
                withZoom: false,
                withLinesCount: true,
                expanded: true,
                selectable: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_copiedLabel(context)),
      ),
    );
  }
}

class _CodeViewerHeader extends StatelessWidget {
  const _CodeViewerHeader({
    required this.title,
    required this.copyLabel,
    required this.onCopy,
  });

  final String title;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.code_rounded,
            size: 17,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.superTextTheme.caption.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Tooltip(
            message: copyLabel,
            child: IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
