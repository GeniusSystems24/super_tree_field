// ============================================================
// example/lib/org_tree_demo.dart
// ------------------------------------------------------------
// EXAMPLE 3 — the same SuperTree engine reskinned for an org chart.
// TreeNode<Person> { role, dept, initials }. Managers roll up a headcount;
// everyone shows a role + dept pill, with a colored initials avatar as the
// leading cell. A port of the React `OrgTreeLive` example.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';
import 'responsive_example_layout.dart';

/// A person's payload.
class Person {
  /// Creates an organization-tree person payload.
  const Person(this.role, this.dept, this.initials);

  /// Person's job role.
  final String role;

  /// Department used for grouping and visual treatment.
  final String dept;

  /// Initials displayed by the leading avatar.
  final String initials;
}

Map<String, Color> _deptColor(BuildContext context) => {
      'Exec': SuperThemeData.of(context).tokens.accent,
      'Eng': SuperThemeData.of(context).tokens.success,
      'Design': SuperThemeData.of(context).tokens.warning,
      'Finance': const Color(0xFFA855F7),
    };

TreeNode<Person> _p(
        String code, String name, String role, String dept, String initials,
        [List<TreeNode<Person>>? children]) =>
    TreeNode<Person>(
        code: code,
        name: name,
        value: Person(role, dept, initials),
        children: children);

final List<TreeNode<Person>> _orgTree = [
  _p('ceo', 'Layla Al-Saud', 'Chief Executive', 'Exec', 'LS', [
    _p('cto', 'Omar Khalid', 'CTO', 'Eng', 'OK', [
      _p('eng-lead', 'Sara Nasser', 'Eng Lead', 'Eng', 'SN', [
        _p('eng-1', 'Yousef Amin', 'Senior Engineer', 'Eng', 'YA'),
        _p('eng-2', 'Huda Faris', 'Engineer', 'Eng', 'HF'),
        _p('eng-3', 'Tariq Saleh', 'Engineer', 'Eng', 'TS'),
      ]),
      _p('design-lead', 'Nora Habib', 'Design Lead', 'Design', 'NH', [
        _p('des-1', 'Mariam Adel', 'Product Designer', 'Design', 'MA'),
        _p('des-2', 'Faisal Rashid', 'Brand Designer', 'Design', 'FR'),
      ]),
    ]),
    _p('cfo', 'Aisha Mansour', 'CFO', 'Finance', 'AM', [
      _p('fin-lead', 'Khalid Omar', 'Finance Manager', 'Finance', 'KO', [
        _p('fin-1', 'Lina Saad', 'Accountant', 'Finance', 'LS'),
        _p('fin-2', 'Bilal Hadi', 'Analyst', 'Finance', 'BH'),
      ]),
    ]),
  ]),
];

/// Demonstrates [SuperTree] as an organization chart.
class OrgTreeDemo extends StatefulWidget {
  /// Creates the organization-tree demonstration page.
  const OrgTreeDemo({super.key});

  @override
  State<OrgTreeDemo> createState() => _OrgTreeDemoState();
}

class _OrgTreeDemoState extends State<OrgTreeDemo> {
  final SuperTreeControlsController _controls = SuperTreeControlsController();
  static const _accent = Color(0xFFA855F7);

  late final SuperTreeController<Person> _controller =
      SuperTreeController<Person>(
    roots: _orgTree,
    defaultExpandDepth: 1,
    searchText: (n) =>
        '${n.name} ${n.value?.role ?? ''} ${n.value?.dept ?? ''}',
    newNodeBuilder: (code) => TreeNode<Person>(
        code: code,
        name: 'New report',
        value: const Person('Role', 'Eng', 'NR')),
  );

  @override
  void dispose() {
    _controls.dispose();
    _controller.dispose();
    super.dispose();
  }

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
        title:
            Text('Org Chart', style: context.superTextTheme.heading.copyWith(color: t.fg1)),
      ),
      body: ResponsiveExampleLayout(
        maxWidth: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
          SuperTreeControls<Person>(
                    controller: _controller,
                    controlsController: _controls,
                    placeholder: 'Search people…   ( / )',
                    samples: const ['Lead', 'Eng', 'Sara', 'Finance'],
                    accent: _accent,
                    enableEditing: true,
                  ),
          SizedBox(height: context.superTheme.spacing.space4),
          SuperTree<Person>(
                                controller: _controller,
                      onSearchRequested: _controls.requestSearchFocus,
                      onShortcutsRequested: () => showShortcutsHelp(context),
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                accent: _accent,
                                title: 'Org chart',
                                subtitle:
                                    'TreeNode<Person> · managers roll up a headcount, everyone shows role + dept',
                                titleIcon: Icons.people_outline,
                                nameColumnLabel: 'Name',
                                trailingColumnLabel: 'Role · Dept',
                                unit: 'people',
                                showArabic: false,
                                leadingBuilder: (context, node, info) {
                                  final p = node.value!;
                                  final c = _deptColor(context)[p.dept] ?? context.superTheme.fg3;
                                  return Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: c.withValues(alpha: 0.16),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: c.withValues(alpha: 0.35)),
                                    ),
                                    child: Text(p.initials,
                                        style: context.superTextTheme.mono.copyWith(
                                            fontSize: 10,
                                            height: 1,
                                            fontWeight: FontWeight.w700,
                                            color: c)),
                                  );
                                },
                                trailingBuilder: (context, node, info) {
                                  final p = node.value!;
                                  final t = context.superTheme;
                                  final c = _deptColor(context)[p.dept] ?? t.fg3;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(p.role,
                                          style: context.superTextTheme.body
                                              .copyWith(fontSize: 12, color: t.fg2)),
                                      const SizedBox(width: 10),
                                      Container(
                                        height: 19,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: c.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: c.withValues(alpha: 0.35)),
                                        ),
                                        child: Text(p.dept,
                                            style: context.superTextTheme.pill
                                                .copyWith(fontSize: 10, color: c)),
                                      ),
                                    ],
                                  );
                                },
                              ),
          ],
        ),
      ),
    );
  }
}
