// ============================================================
// features/super_tree_field/presentation/pages/super_tree_demo.dart
// ------------------------------------------------------------
// A ready-to-route demo page for the flagship AccountTree — a centered content
// column on the themed page background, matching the GeniusLink page layout
// (eyebrow + H1 + the live tree). Drop `const AccountTreeDemo()` into a route.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../widgets/account_tree.dart';

/// A scaffolded page hosting the interactive chart-of-accounts tree.
class AccountTreeDemo extends StatelessWidget {
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
        title: Text('Account Tree', style: SuperText.heading.copyWith(color: t.fg1)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: const Hairline(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: SuperTokens.space6, vertical: SuperTokens.space8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ACCOUNTING • CHART OF ACCOUNTS',
                      style: SuperText.eyebrow.copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Account Tree قيد افتتاحي', style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space8),
                  const AccountTree(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
