// ============================================================
// example/lib/super_tree_demo.dart
// ------------------------------------------------------------
// A ready-to-route demo page for the flagship AccountTree — a centered content
// column on the themed page background, matching the GeniusLink page layout
// (eyebrow + H1 + the live tree). Drop `const AccountTreeDemo()` into a route.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';

import 'account_tree.dart';
import '../responsive_example_layout.dart';

import '../localization/localizations.dart';
import '../widgets/demo_kit.dart';
import '../usage_sources.dart';
/// A scaffolded page hosting the interactive chart-of-accounts tree.
class AccountTreeDemo extends StatelessWidget {
  /// Creates the chart-of-accounts demonstration page.
  const AccountTreeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return DemoScaffold(
      title: context.exampleLocalization.accountTreeDemoTitle,
      subtitle: context.exampleLocalization.accountTreeDemoSubtitle,
      usageCode: ExampleUsageSources.accountTree,
      body: ResponsiveExampleLayout(
        maxWidth: 1040,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.exampleLocalization.accountingEyebrow,
                style: context.superTextTheme.eyebrow.copyWith(
                  color: SuperMaterialThemeData.of(
                    context,
                  ).colorScheme.primary,
                ),
              ),
              SizedBox(height: context.superTheme.spacing.space2),
              Text(
                context.exampleLocalization.accountTreeHeading,
                style: context.superTextTheme.h1.copyWith(color: t.fg1),
              ),
              SizedBox(height: context.superTheme.spacing.space8),
              const AccountTree(

              ),
            ],
          ),
      ),
    );
  }
}
