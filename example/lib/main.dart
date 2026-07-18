// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_tree_field. Registers the SuperThemeData extension (so
// the tree themes light/dark in parity), exposes a global Light/Dark + LTR/RTL
// toggle, and lists the three demos that share ONE engine:
//   • Account Tree   — the flagship: SuperTree<AccountData> (KPIs · balance · DR/CR)
//   • File Explorer  — SuperTree<FileMeta>
//   • Org Chart      — SuperTree<Person>
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';

import 'file_tree_demo.dart';
import 'org_tree_demo.dart';
import 'permission_tree_demo.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  TextDirection _dir = TextDirection.ltr;

  void _toggleTheme() => setState(
      () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void _toggleDir() => setState(() =>
      _dir = _dir == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Tree',
      themeMode: _mode,
      theme: SuperMaterialThemeData.light(),
      darkTheme: SuperMaterialThemeData.dark(),
      builder: (context, child) =>
          Directionality(textDirection: _dir, child: child!),
      home: _Launcher(
        mode: _mode,
        dir: _dir,
        onToggleTheme: _toggleTheme,
        onToggleDir: _toggleDir,
      ),
    );
  }
}

class _Demo {
  const _Demo(this.title, this.subtitle, this.icon, this.builder);
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class _Launcher extends StatelessWidget {
  const _Launcher({
    required this.mode,
    required this.dir,
    required this.onToggleTheme,
    required this.onToggleDir,
  });

  final ThemeMode mode;
  final TextDirection dir;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleDir;

  static final List<_Demo> _demos = [
    _Demo(
        'Account Tree',
        'Chart of accounts · KPIs · A = L + E · DR/CR · roll-up balances',
        Icons.account_tree_outlined,
        (_) => const AccountTreeDemo()),
    _Demo(
        'File Explorer',
        'SuperTree<FileMeta> · folders + files · size / modified',
        Icons.folder_open_outlined,
        (_) => const FileTreeDemo()),
    _Demo('Org Chart', 'SuperTree<Person> · headcount roll-up · role + dept',
        Icons.people_outline, (_) => const OrgTreeDemo()),
    _Demo(
        'Permission Settings',
        'SuperTree<Permission> · single + multi checkbox selection',
        Icons.shield_outlined,
        (_) => const PermissionTreeDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SuperTokensData.defaultSpace10),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: SuperTokensData.defaultContentColumn),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('SUPER TREE \u2022 GALLERY',
                      style: SuperText.eyebrow.copyWith(
                          color: SuperMaterialThemeData.of(context)
                              .colorScheme
                              .primary)),
                  const SizedBox(height: SuperTokensData.defaultSpace2),
                  Text('Component Demos مكتبة المكونات',
                      style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokensData.defaultSpace8),
                  for (final d in _demos) ...[
                    _DemoCard(demo: d),
                    const SizedBox(height: SuperTokensData.defaultSpace3),
                  ],
                  const SizedBox(height: SuperTokensData.defaultSpace6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SuperButton(
                        label: mode == ThemeMode.dark
                            ? 'Light Theme'
                            : 'Dark Theme',
                        variant: SuperButtonVariant.secondary,
                        onPressed: onToggleTheme,
                      ),
                      const SizedBox(width: SuperTokensData.defaultSpace3),
                      SuperButton(
                        label: dir == TextDirection.ltr
                            ? 'العربية (RTL)'
                            : 'English (LTR)',
                        variant: SuperButtonVariant.secondary,
                        onPressed: onToggleDir,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
    final t = context.superTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusCard),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: demo.builder)),
        child: Container(
          padding: const EdgeInsets.all(SuperTokensData.defaultSpace4),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusCard),
            border: Border.all(color: t.border),
            boxShadow: t.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                      SuperMaterialThemeData.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.14),
                      t.surface),
                  borderRadius:
                      BorderRadius.circular(SuperTokensData.defaultRadiusControl),
                ),
                child: Icon(demo.icon,
                    size: 22,
                    color:
                        SuperMaterialThemeData.of(context).colorScheme.primary),
              ),
              const SizedBox(width: SuperTokensData.defaultSpace4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(demo.title,
                        style: SuperText.heading.copyWith(color: t.fg1)),
                    const SizedBox(height: 2),
                    Text(demo.subtitle,
                        style: SuperText.caption.copyWith(color: t.fg3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: t.fg4),
            ],
          ),
        ),
      ),
    );
  }
}
