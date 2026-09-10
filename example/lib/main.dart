// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_tree_field. Uses SuperMaterialThemeData with the
// explicit SuperTextTheme required by super_core 3.3.0, and exposes a global
// Light/Dark + LTR/RTL
// toggle, and lists demos that share ONE engine:
//   • Account Tree          — flagship SuperTree<AccountData> composition
//   • File Explorer         — SuperTree<FileMeta>
//   • Org Chart             — SuperTree<Person>
//   • Permission Settings   — SuperTree<Permission> selection
//   • Product Tree          — SuperTree<ProductData> catalog hierarchy
//   • Scroll Configuration  — ScrollController + ScrollView pass-through API
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/localization/generated/l10n.dart';
import 'package:super_tree_field/localization/localizations.dart';

import 'file_tree_demo.dart';
import 'org_tree_demo.dart';
import 'permission_tree_demo.dart';
import 'product_tree_demo.dart';
import 'scroll_tree_demo.dart';
import 'tree_context_menu_demo.dart';
import 'account/super_tree_demo.dart';
import 'package:super_tree_field/super_tree.dart';
import 'localization/localizations.dart';

/// Runs the Super Tree example gallery.
void main() => runApp(const ExampleApp());

/// Root widget for the Super Tree example gallery.
class ExampleApp extends StatefulWidget {
  /// Creates the example gallery application.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  void _toggleTheme() => setState(
    () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );
  void _toggleLocale() => setState(
    () => _locale = _locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en'),
  );

@override
  Widget build(BuildContext context) {
    final isArabic = _locale.languageCode == 'ar';
    final textTheme = SuperTextTheme(isArabic: isArabic);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'super-tree-example',
      title: ExampleLocalization(_locale).appTitle,
      themeMode: _mode,
      theme: SuperMaterialThemeData.light(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      locale: _locale,
      supportedLocales: SuperTreeLocalization.supportedLocales,
      localizationsDelegates: const [
        ExampleLocalization.delegate,
        SuperTreeLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SuperFormTranslation.delegate,
      ],
      home: _Launcher(
        mode: _mode,
        locale: _locale,
        onToggleTheme: _toggleTheme,
        onToggleLanguage: _toggleLocale,
      ),
    );
  }
}

class _Demo {
  const _Demo(
    this.title,
    this.subtitle,
    this.icon,
    this.builder, {
    this.featured = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
  final bool featured;
}

class _Launcher extends StatelessWidget {
  const _Launcher({
    required this.mode,
    required this.locale,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  final ThemeMode mode;
  final Locale locale;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  static final List<_Demo> _demos = <_Demo>[
    _Demo(
      'Account Tree',
      'Chart of accounts · KPIs · A = L + E · DR/CR · roll-up balances',
      Icons.account_tree_outlined,
      (_) => const AccountTreeDemo(),
      featured: true,
    ),
    _Demo(
      'File Explorer',
      'SuperTree<FileMeta> · folders + files · size / modified',
      Icons.folder_open_outlined,
      (_) => const FileTreeDemo(),
    ),
    _Demo(
      'Org Chart',
      'SuperTree<Person> · headcount roll-up · role + dept',
      Icons.people_outline,
      (_) => const OrgTreeDemo(),
    ),
    _Demo(
      'Permission Settings',
      'SuperTree<Permission> · single + multi checkbox selection',
      Icons.shield_outlined,
      (_) => const PermissionTreeDemo(),
    ),
    _Demo(
      'Product Tree',
      'SuperTree<ProductData> · categories · SKU · price · stock',
      Icons.inventory_2_outlined,
      (_) => const ProductTreeDemo(),
    ),
    _Demo(
      'Scroll Configuration',
      'ScrollController · physics · restoration · bounded viewport',
      Icons.swap_vert_circle_outlined,
      (_) => const ScrollTreeDemo(),
    ),
    _Demo(
      'Tree Context Menus',
      'Reusable · nested · per-node context-menu customization',
      Icons.menu_open_rounded,
      (_) => const TreeContextMenuDemo(),
      featured: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.superTheme;
    final spacing = SuperThemeData.of(context).spacing;
    final l10n = context.exampleLocalization;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.space6,
                  spacing.space8,
                  spacing.space6,
                  spacing.space5,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 760;
                    final identity = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.galleryEyebrow,
                          style: context.superTextTheme.eyebrow.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: spacing.space2),
                        Text(
                          l10n.galleryTitle,
                          style: context.superTextTheme.h1.copyWith(
                            color: t.fg1,
                          ),
                        ),
                        SizedBox(height: spacing.space2),
                        Text(
                          locale.languageCode == 'ar'
                              ? 'أمثلة متجاوبة لكل قدرات SuperTree مع كود الاستخدام.'
                              : 'Responsive examples for the SuperTree API with live Dart usage code.',
                          style: context.superTextTheme.body.copyWith(
                            color: t.fg3,
                          ),
                        ),
                      ],
                    );
                    final actions = Wrap(
                      spacing: spacing.space2,
                      runSpacing: spacing.space2,
                      children: <Widget>[
                        SuperButton(
                          label: mode == ThemeMode.dark
                              ? l10n.lightTheme
                              : l10n.darkTheme,
                          variant: SuperButtonVariant.secondary,
                          onPressed: onToggleTheme,
                        ),
                        SuperButton(
                          label: locale.languageCode == 'en'
                              ? l10n.switchToArabic
                              : l10n.switchToEnglish,
                          variant: SuperButtonVariant.secondary,
                          onPressed: onToggleLanguage,
                        ),
                      ],
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          identity,
                          SizedBox(height: spacing.space4),
                          actions,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(child: identity),
                        SizedBox(width: spacing.space6),
                        actions,
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                spacing.space6,
                0,
                spacing.space6,
                spacing.space8,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 440,
                  mainAxisExtent: 176,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _DemoCard(demo: _demos[index]),
                  childCount: _demos.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.superTheme;
    final spacing = SuperThemeData.of(context).spacing;
    final l10n = context.exampleLocalization;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(spacing.radiusCard),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: demo.builder),
        ),
        child: Container(
          padding: EdgeInsets.all(spacing.space4),
          decoration: BoxDecoration(
            color: demo.featured
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
                : t.surface,
            borderRadius: BorderRadius.circular(spacing.radiusCard),
            border: Border.all(
              color: demo.featured
                  ? theme.colorScheme.primary.withValues(alpha: 0.34)
                  : t.border,
            ),
            boxShadow: t.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        spacing.radiusControl,
                      ),
                    ),
                    child: Icon(
                      demo.icon,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    rtl
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    color: t.fg4,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                l10n.translateSource(demo.title),
                style: context.superTextTheme.heading.copyWith(color: t.fg1),
              ),
              SizedBox(height: spacing.space1),
              Text(
                l10n.translateSource(demo.subtitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.superTextTheme.caption.copyWith(color: t.fg3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
