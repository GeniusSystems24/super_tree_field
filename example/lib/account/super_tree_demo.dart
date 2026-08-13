// ============================================================
// example/lib/super_tree_demo.dart
// ------------------------------------------------------------
// A ready-to-route demo page for the flagship AccountTree — a centered content
// column on the themed page background, matching the GeniusLink page layout
// (eyebrow + H1 + the live tree). Drop `const AccountTreeDemo()` into a route.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';

import 'account_tree.dart';
import '../responsive_example_layout.dart';

/// A scaffolded page hosting the interactive chart-of-accounts tree.
class AccountTreeDemo extends StatelessWidget {
  /// Creates the chart-of-accounts demonstration page.
  const AccountTreeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: t.fg2),
        title: Text(
          'Account Tree',
          style: context.superTextTheme.heading.copyWith(color: t.fg1),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Hairline(),
        ),
      ),
      body: ResponsiveExampleLayout(
        maxWidth: 1040,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ACCOUNTING • CHART OF ACCOUNTS',
                style: context.superTextTheme.eyebrow.copyWith(
                  color: SuperMaterialThemeData.of(
                    context,
                  ).colorScheme.primary,
                ),
              ),
              SizedBox(height: context.superTheme.spacing.space2),
              Text(
                'Account Tree قيد افتتاحي',
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
