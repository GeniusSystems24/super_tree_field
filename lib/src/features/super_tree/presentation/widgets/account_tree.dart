// ============================================================
// features/super_tree/presentation/widgets/account_tree.dart
// ------------------------------------------------------------
// The flagship instance of SuperTree: a five-level bilingual chart of accounts
// with roll-up balances, a financial-summary KPI grid, a live A = L + E balance
// badge, type filter chips, a DR/CR nature column and a per-account share bar.
// Composes `SuperTree<AccountData>` with account-specific leading / trailing
// cell builders. A faithful port of the React `AccountTreeLive` widget.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/datasources/account_tree_data.dart';
import '../../domain/entities/account_data.dart';
import '../../domain/entities/tree_node.dart';
import '../../domain/usecases/tree_logic.dart';
import '../controllers/super_tree_controller.dart';
import 'kpi_card.dart';
import 'nature_pill.dart';
import 'super_tree.dart';
import 'tree_row.dart';

/// The interactive chart-of-accounts tree. Pass your own [roots] or use the
/// built-in [AccountTreeData.tree] sample.
class AccountTree extends StatefulWidget {
  const AccountTree({super.key, this.roots, this.onOpenAccount});

  /// The account hierarchy. Defaults to the bundled sample chart of accounts.
  final List<TreeNode<AccountData>>? roots;

  /// Called when a leaf account is opened (Enter / click).
  final void Function(TreeNode<AccountData> account)? onOpenAccount;

  @override
  State<AccountTree> createState() => _AccountTreeState();
}

class _AccountTreeState extends State<AccountTree> {
  static const _samples = ['1111', 'Bank', 'البنك', 'Cash', 'Loan', '5512'];

  late final List<TreeNode<AccountData>> _all;
  late final SuperTreeController<AccountData> _controller;
  late final Map<String, double> _nodeTotal; // code → own roll-up total
  late final Map<String, double> _rootTotal; // code → its root's total

  AccountType? _typeFilter; // null = All

  static double _leafBal(TreeNode<AccountData> n) => n.value?.balance ?? 0.0;

  @override
  void initState() {
    super.initState();
    _all = widget.roots ?? AccountTreeData.tree;
    _nodeTotal = {};
    _rootTotal = {};
    for (final root in _all) {
      final rt = TreeLogic.rollup(root, _leafBal);
      void assign(TreeNode<AccountData> n) {
        _nodeTotal[n.code] = TreeLogic.rollup(n, _leafBal);
        _rootTotal[n.code] = rt;
        n.children?.forEach(assign);
      }

      assign(root);
    }
    _controller = SuperTreeController<AccountData>(
      roots: _all,
      defaultExpandDepth: 1,
      searchText: (n) => '${n.code} ${n.name} ${n.ar ?? ''}',
      onOpenLeaf: (n) => widget.onOpenAccount?.call(n),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyFilter(AccountType? type) {
    setState(() => _typeFilter = type);
    _controller.setRoots(
      type == null ? _all : _all.where((n) => n.value?.type == type).toList(),
    );
  }

  double _typeTotal(AccountType type) => _all
      .where((n) => n.value?.type == type)
      .fold(0.0, (s, n) => s + TreeLogic.rollup(n, _leafBal));

  @override
  Widget build(BuildContext context) {
    final assets = _typeTotal(AccountType.asset);
    final liabilities = _typeTotal(AccountType.liability);
    final equity = _typeTotal(AccountType.equity);
    final income = _typeTotal(AccountType.income);
    final expense = _typeTotal(AccountType.expense);

    return SuperTree<AccountData>(
      controller: _controller,
      accent: SuperTokens.accent,
      title: 'Chart of Accounts Hierarchy',
      subtitle: '5 levels · click or use ↑↓ ← → · Enter opens a leaf · press ? for shortcuts',
      nameColumnLabel: 'Account · الحساب',
      trailingColumnLabel: 'Nature · Balance (SAR)',
      placeholder: 'Search by code, English or Arabic name…   ( / )',
      samples: _samples,
      unit: 'accounts',
      selectionLabel: 'Opened ledger for account',
      above: _kpiGrid(assets, liabilities, equity, income, expense),
      toolbarExtra: _filterRow(assets, liabilities, equity),
      leadingBuilder: _leading,
      trailingBuilder: _trailing,
    );
  }

  // ── KPI summary grid ──
  Widget _kpiGrid(double a, double l, double e, double i, double x) {
    final cards = [
      KpiCard(
          label: 'Total Assets',
          ar: 'الأصول',
          value: SuperFormat.formatNumber(a),
          accent: AccountType.asset.color,
          sub: 'SAR · debit balance'),
      KpiCard(
          label: 'Total Liabilities',
          ar: 'الخصوم',
          value: SuperFormat.formatNumber(l),
          accent: AccountType.liability.color,
          sub: 'SAR · credit balance'),
      KpiCard(
          label: 'Total Equity',
          ar: 'حقوق الملكية',
          value: SuperFormat.formatNumber(e),
          accent: AccountType.equity.color,
          sub: 'SAR · credit balance'),
      KpiCard(
          label: 'Net Income',
          ar: 'صافي الدخل',
          value: SuperFormat.formatNumber(i - x),
          accent: AccountType.income.color,
          sub: 'Income ${_short(i)} − Expense ${_short(x)} SAR'),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 820
            ? 4
            : c.maxWidth >= 540
                ? 2
                : 1;
        const gap = SuperTokens.space3;
        final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardW, child: card),
          ],
        );
      },
    );
  }

  static String _short(double n) {
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
    if (n >= 1e3) return '${(n / 1e3).round()}K';
    return n.toStringAsFixed(0);
  }

  // ── type filter chips + balance badge ──
  Widget _filterRow(double assets, double liabilities, double equity) {
    final balanced = (assets - (liabilities + equity)).abs() < 0.01;
    final chips = <Widget>[
      _TypeChip(
        label: 'All',
        color: null,
        active: _typeFilter == null,
        onTap: () => _applyFilter(null),
      ),
      for (final type in AccountType.ordered)
        _TypeChip(
          label: type.label,
          color: type.color,
          active: _typeFilter == type,
          onTap: () => _applyFilter(type),
        ),
    ];
    return Row(
      children: [
        Expanded(
          child: Wrap(spacing: SuperTokens.space2, runSpacing: SuperTokens.space2, children: chips),
        ),
        const SizedBox(width: SuperTokens.space3),
        _BalanceBadge(balanced: balanced),
      ],
    );
  }

  // ── account leading cell: colored type dot + monospace code ──
  Widget _leading(BuildContext context, TreeNode<AccountData> node, TreeRowInfo info) {
    final t = context.superTheme;
    final color = node.value?.type.color ?? t.fg3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: info.depth == 0
                ? [BoxShadow(color: color.withOpacity(0.13), spreadRadius: 3)]
                : null,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          node.code,
          style: SuperText.mono.copyWith(fontSize: 11.5, height: 1.2, color: t.fg3),
        ),
      ],
    );
  }

  // ── account trailing cells: nature pill + balance + share bar ──
  Widget? _trailing(BuildContext context, TreeNode<AccountData> node, TreeRowInfo info) {
    final t = context.superTheme;
    final type = node.value?.type;
    if (type == null) return null;
    final total = _nodeTotal[node.code] ?? 0;
    final rootTotal = _rootTotal[node.code] ?? 0;
    final share = rootTotal > 0 ? (total / rootTotal) : 0.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NaturePill(type.nature),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                SuperFormat.formatNumber(total),
                style: SuperText.mono.copyWith(
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: info.depth == 0 ? FontWeight.w700 : FontWeight.w500,
                  color: t.fg1,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 3,
                  color: t.inputBg,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: (share).clamp(0.015, 1.0),
                      child: Container(
                        color: type.color.withOpacity(info.depth == 0 ? 0.9 : 0.55),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A type-filter chip with an optional colored dot.
class _TypeChip extends StatefulWidget {
  const _TypeChip({required this.label, required this.color, required this.active, required this.onTap});
  final String label;
  final Color? color;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_TypeChip> createState() => _TypeChipState();
}

class _TypeChipState extends State<_TypeChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final color = widget.color;
    final bg = widget.active
        ? (color != null ? color.withOpacity(0.12) : t.hover)
        : (_hover ? t.hover : const Color(0x00000000));
    final borderColor = widget.active ? (color ?? t.borderStrong) : t.border;
    final fg = widget.active ? (color ?? t.fg1) : t.fg2;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null) ...[
                Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 7),
              ],
              Text(widget.label,
                  style: SuperText.label.copyWith(fontSize: 11, letterSpacing: 0.33, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The live A = L + E balance badge.
class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({required this.balanced});
  final bool balanced;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final c = balanced ? SuperTokens.success : SuperTokens.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: t.tintFill(c, 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(balanced ? Icons.check : Icons.info_outline, size: 13, color: c),
          const SizedBox(width: 8),
          Text(
            balanced ? 'Balanced · A = L + E' : 'Out of balance',
            style: SuperText.label.copyWith(fontSize: 11, letterSpacing: 0.44, color: c),
          ),
        ],
      ),
    );
  }
}
