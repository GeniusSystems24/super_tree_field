// ============================================================
// example/lib/permission_tree_demo.dart
// ------------------------------------------------------------
// EXAMPLE 4 — the same SuperTree engine driving a *selection* UI.
// Demonstrates v0.3.0 checkbox selection: a role's permissions are granted by
// checking boxes. A segmented control flips the tree between SINGLE selection
// (radio-like — one permission) and MULTI selection (cascading group tristate),
// proving both modes share one engine. TreeNode<Permission> { level, danger }.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree/super_tree.dart';

/// A permission's payload: an access [level] (scope pill) and a [danger] flag
/// for destructive grants. Group (module) nodes carry only an [icon].
class Permission {
  const Permission({this.level, this.danger = false, this.icon});
  final String? level; // View · Write · Admin
  final bool danger;
  final IconData? icon; // module icon (group rows)
}

Color _levelColor(BuildContext context, Permission p) {
  if (p.danger) return SuperTokens.danger;
  switch (p.level) {
    case 'View':
      return SuperTokens.accent;
    case 'Write':
      return SuperTokens.success;
    case 'Admin':
      return SuperTokens.warning;
    default:
      return context.superTheme.fg3;
  }
}

TreeNode<Permission> _mod(String code, String name, String ar, IconData icon,
        List<TreeNode<Permission>> children) =>
    TreeNode<Permission>(
        code: code, name: name, ar: ar, value: Permission(icon: icon), children: children);

TreeNode<Permission> _perm(String code, String name, String ar, String level,
        {bool danger = false}) =>
    TreeNode<Permission>(
        code: code, name: name, ar: ar, value: Permission(level: level, danger: danger));

final List<TreeNode<Permission>> _permissionTree = [
  _mod('acc', 'Accounting', 'المحاسبة', Icons.account_balance_outlined, [
    _perm('acc.view', 'View ledgers', 'عرض دفاتر الأستاذ', 'View'),
    _perm('acc.create', 'Create journal entry', 'إنشاء قيد يومية', 'Write'),
    _perm('acc.post', 'Post entries', 'ترحيل القيود', 'Write'),
    _perm('acc.reverse', 'Reverse entries', 'عكس القيود', 'Write'),
    _perm('acc.coa', 'Manage chart of accounts', 'إدارة شجرة الحسابات', 'Admin'),
  ]),
  _mod('inv', 'Inventory', 'المخزون', Icons.inventory_2_outlined, [
    _perm('inv.view', 'View stock levels', 'عرض المخزون', 'View'),
    _perm('inv.issue', 'Issue inventory', 'صرف المخزون', 'Write'),
    _perm('inv.transfer', 'Transfer between stores', 'تحويل بين المخازن', 'Write'),
    _perm('inv.adjust', 'Adjust quantities', 'تعديل الكميات', 'Admin'),
  ]),
  _mod('trz', 'Treasury', 'الخزينة', Icons.savings_outlined, [
    _perm('trz.view', 'View bank accounts', 'عرض الحسابات البنكية', 'View'),
    _perm('trz.deposit', 'Create deposit', 'إنشاء إيداع', 'Write'),
    _perm('trz.transfer', 'Local transfers', 'التحويلات المحلية', 'Write'),
    _perm('trz.reconcile', 'Reconcile statements', 'تسوية الكشوف', 'Admin'),
  ]),
  _mod('adm', 'Administration', 'إدارة النظام', Icons.admin_panel_settings_outlined, [
    _perm('adm.users', 'Manage users', 'إدارة المستخدمين', 'Admin'),
    _perm('adm.roles', 'Manage roles & permissions', 'إدارة الأدوار والصلاحيات', 'Admin'),
    _perm('adm.audit', 'View audit log', 'عرض سجل التدقيق', 'View'),
    _perm('adm.wipe', 'Delete fiscal-year data', 'حذف بيانات السنة المالية', 'Admin', danger: true),
  ]),
];

const _multiSeed = {'acc.view', 'acc.create', 'acc.post', 'inv.view', 'trz.view'};
const _singleSeed = {'acc.view'};

class PermissionTreeDemo extends StatefulWidget {
  const PermissionTreeDemo({super.key});

  @override
  State<PermissionTreeDemo> createState() => _PermissionTreeDemoState();
}

class _PermissionTreeDemoState extends State<PermissionTreeDemo> {
  static const _accent = SuperTokens.accent;

  // One controller per mode so each remembers its own selection while the user
  // flips the segmented control. selectionMode is fixed per controller.
  late final Map<SuperTreeSelectionMode, SuperTreeController<Permission>> _controllers = {
    SuperTreeSelectionMode.multi: _build(SuperTreeSelectionMode.multi, _multiSeed),
    SuperTreeSelectionMode.single: _build(SuperTreeSelectionMode.single, _singleSeed),
  };

  SuperTreeSelectionMode _mode = SuperTreeSelectionMode.multi;

  SuperTreeController<Permission> _build(SuperTreeSelectionMode mode, Set<String> seed) =>
      SuperTreeController<Permission>(
        roots: _permissionTree,
        defaultExpandDepth: 1,
        selectionMode: mode,
        initialChecked: seed,
        searchText: (n) => '${n.name} ${n.ar ?? ''} ${n.value?.level ?? ''}',
        onSelectionChanged: (_) => setState(() {}),
      );

  SuperTreeController<Permission> get _controller => _controllers[_mode]!;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final multi = _mode == SuperTreeSelectionMode.multi;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: t.fg2),
        title: Text('Permission Settings', style: SuperText.heading.copyWith(color: t.fg1)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ADMINISTRATION • ROLES & PERMISSIONS',
                      style: SuperText.eyebrow.copyWith(color: _accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Permission Settings صلاحيات', style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space6),
                  _ModeToggle(
                    mode: _mode,
                    onChanged: (m) => setState(() => _mode = m),
                  ),
                  const SizedBox(height: SuperTokens.space6),
                  SuperTree<Permission>(
                    key: ValueKey(_mode),
                    controller: _controller,
                    accent: _accent,
                    title: 'Role: Senior Accountant',
                    subtitle: multi
                        ? 'Check the permissions granted to this role · a module checks all its actions'
                        : 'Single selection · one default action only (radio-like)',
                    titleIcon: Icons.shield_outlined,
                    nameColumnLabel: 'Permission · الصلاحية',
                    trailingColumnLabel: 'Scope',
                    placeholder: 'Search permissions…   ( / )',
                    samples: const ['View', 'Write', 'Admin', 'inventory'],
                    unit: 'permissions',
                    leadingBuilder: _leading,
                    trailingBuilder: _trailing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading(BuildContext context, TreeNode<Permission> node, TreeRowInfo info) {
    final t = context.superTheme;
    final p = node.value;
    if (info.hasChildren) {
      return Icon(p?.icon ?? Icons.folder_outlined, size: 16, color: _accent);
    }
    final c = _levelColor(context, p ?? const Permission());
    return Icon(p?.danger == true ? Icons.warning_amber_rounded : Icons.vpn_key_outlined,
        size: 14, color: c);
  }

  Widget? _trailing(BuildContext context, TreeNode<Permission> node, TreeRowInfo info) {
    final p = node.value;
    if (p == null || p.level == null) return null;
    final c = _levelColor(context, p);
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Text(p.level!.toUpperCase(),
          style: SuperText.pill.copyWith(fontSize: 10, color: c)),
    );
  }
}

/// The Single / Multi segmented control, matching the design system's pill
/// toggle used elsewhere in the tree toolbar.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final SuperTreeSelectionMode mode;
  final ValueChanged<SuperTreeSelectionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    Widget seg(String label, IconData icon, SuperTreeSelectionMode m) {
      final active = mode == m;
      return GestureDetector(
        onTap: () => onChanged(m),
        child: AnimatedContainer(
          duration: SuperTokens.durFast,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: SuperTokens.controlHeight - 6,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? Color.alphaBlend(SuperTokens.accent.withOpacity(0.20), t.surface)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(SuperTokens.radiusControl - 2),
            border: Border.all(color: active ? SuperTokens.accent : const Color(0x00000000)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: active ? SuperTokens.accent : t.fg3),
              const SizedBox(width: 7),
              Text(label,
                  style: SuperText.body.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: active ? SuperTokens.accent : t.fg3)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Text('SELECTION MODE',
            style: SuperText.label.copyWith(fontSize: 10, letterSpacing: 0.6, color: t.fg3)),
        const SizedBox(width: SuperTokens.space3),
        Container(
          height: SuperTokens.controlHeight,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: t.inputBg,
            borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
            border: Border.all(color: t.borderStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              seg('Multi', Icons.check_box_outlined, SuperTreeSelectionMode.multi),
              const SizedBox(width: 3),
              seg('Single', Icons.radio_button_checked, SuperTreeSelectionMode.single),
            ],
          ),
        ),
      ],
    );
  }
}
