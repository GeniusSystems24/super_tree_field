// ============================================================
// example/lib/org_tree_demo.dart
// ------------------------------------------------------------
// EXAMPLE 3 — the same SuperTree engine reskinned for an org chart.
// TreeNode<Person> { role, dept, initials }. Managers roll up a headcount;
// everyone shows a role + dept pill, with a colored initials avatar as the
// leading cell. A port of the React `OrgTreeLive` example.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree/super_tree.dart';

/// A person's payload.
class Person {
  const Person(this.role, this.dept, this.initials);
  final String role;
  final String dept;
  final String initials;
}

const Map<String, Color> _deptColor = {
  'Exec': SuperTokens.accent,
  'Eng': SuperTokens.success,
  'Design': SuperTokens.warning,
  'Finance': Color(0xFFA855F7),
};

TreeNode<Person> _p(String code, String name, String role, String dept, String initials,
        [List<TreeNode<Person>>? children]) =>
    TreeNode<Person>(code: code, name: name, value: Person(role, dept, initials), children: children);

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

class OrgTreeDemo extends StatefulWidget {
  const OrgTreeDemo({super.key});

  @override
  State<OrgTreeDemo> createState() => _OrgTreeDemoState();
}

class _OrgTreeDemoState extends State<OrgTreeDemo> {
  static const _accent = Color(0xFFA855F7);

  late final SuperTreeController<Person> _controller = SuperTreeController<Person>(
    roots: _orgTree,
    defaultExpandDepth: 1,
    searchText: (n) => '${n.name} ${n.value?.role ?? ''} ${n.value?.dept ?? ''}',
  );

  @override
  void dispose() {
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
        title: Text('Org Chart', style: SuperText.heading.copyWith(color: t.fg1)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SuperTree<Person>(
                controller: _controller,
                accent: _accent,
                title: 'Org chart',
                subtitle:
                    'TreeNode<Person> · managers roll up a headcount, everyone shows role + dept',
                titleIcon: Icons.people_outline,
                nameColumnLabel: 'Name',
                trailingColumnLabel: 'Role · Dept',
                placeholder: 'Search people…   ( / )',
                samples: const ['Lead', 'Eng', 'Sara', 'Finance'],
                unit: 'people',
                showArabic: false,
                leadingBuilder: (context, node, info) {
                  final p = node.value!;
                  final c = _deptColor[p.dept] ?? context.superTheme.fg3;
                  return Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.withOpacity(0.35)),
                    ),
                    child: Text(p.initials,
                        style: SuperText.mono.copyWith(
                            fontSize: 10, height: 1, fontWeight: FontWeight.w700, color: c)),
                  );
                },
                trailingBuilder: (context, node, info) {
                  final p = node.value!;
                  final t = context.superTheme;
                  final c = _deptColor[p.dept] ?? t.fg3;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.role, style: SuperText.body.copyWith(fontSize: 12, color: t.fg2)),
                      const SizedBox(width: 10),
                      Container(
                        height: 19,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: c.withOpacity(0.35)),
                        ),
                        child: Text(p.dept,
                            style: SuperText.pill.copyWith(fontSize: 10, color: c)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
