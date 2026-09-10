// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';

import 'dart_code_viewer.dart';

/// Responsive example shell with a live demo and its Dart usage code.
///
/// The desktop arrangement follows the `super_naviagtion_page` example:
/// the live component and source viewer appear side by side. Narrow layouts
/// stack two bounded panels so examples that own their own scrolling keep a
/// finite viewport.
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.usageCode,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String usageCode;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  String _liveExampleLabel(BuildContext context) =>
      _isArabic(context) ? 'المثال المباشر' : 'Live example';

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final spacing = SuperThemeData.of(context).spacing;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: t.fg2),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.superTextTheme.heading.copyWith(color: t.fg1),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.superTextTheme.caption.copyWith(color: t.fg3),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 1050;
            final horizontal = constraints.maxWidth >= 720
                ? spacing.space6
                : spacing.space4;

            if (desktop) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  spacing.space4,
                  horizontal,
                  spacing.space6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 13,
                      child: _LiveExamplePanel(
                        title: _liveExampleLabel(context),
                        child: body,
                      ),
                    ),
                    SizedBox(width: spacing.space4),
                    Expanded(
                      flex: 10,
                      child: DartCodeViewer(code: usageCode),
                    ),
                  ],
                ),
              );
            }

            final availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 800.0;
            final liveHeight = math.max(
              420.0,
              math.min(680.0, availableHeight * 0.62),
            );
            final codeHeight = constraints.maxWidth < 600 ? 500.0 : 620.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                spacing.space4,
                horizontal,
                spacing.space6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: liveHeight,
                    child: _LiveExamplePanel(
                      title: _liveExampleLabel(context),
                      child: body,
                    ),
                  ),
                  SizedBox(height: spacing.space4),
                  SizedBox(
                    height: codeHeight,
                    child: DartCodeViewer(code: usageCode),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LiveExamplePanel extends StatelessWidget {
  const _LiveExamplePanel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.superTheme;
    final spacing = SuperThemeData.of(context).spacing;

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(spacing.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.space3,
              vertical: spacing.space2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.preview_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: spacing.space2),
                Text(
                  title,
                  style: context.superTextTheme.label.copyWith(color: t.fg1),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
