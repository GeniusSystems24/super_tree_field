// ============================================================
// features/super_tree_field/presentation/widgets/super_tree.dart
// ------------------------------------------------------------
// The generic SuperTree View: a search toolbar (live filter · match count ·
// sample chips · expand-all / collapse · keyboard help) over a bordered tree
// card (heading + column header + recursive rows + empty state + selection
// footer), with the full keyboard model wired through a focusable body. Drive
// it from a `SuperTreeController<T>` and supply leading / trailing cell
// builders. The flagship `AccountTree` composes this; so do the file / org
// examples. A faithful port of the React `MiniTree` shell.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../controllers/super_tree_controller.dart';
import 'shortcuts_help.dart';
import 'tree_row.dart';

/// A themed, keyboard-first hierarchy view over a [SuperTreeController].
class SuperTree<T> extends StatefulWidget {
  const SuperTree({
    super.key,
    required this.controller,
    required this.leadingBuilder,
    this.trailingBuilder,
    this.accent = SuperTokensData.defaultAccent,
    this.title = 'Hierarchy',
    this.subtitle,
    this.titleIcon,
    this.nameColumnLabel = 'Name',
    this.trailingColumnLabel = '',
    this.placeholder = 'Search…   ( / )',
    this.samples = const [],
    this.unit = 'items',
    this.showArabic = true,
    this.showLeafCount = true,
    this.selectionLabel = 'Selected',
    this.enableEditing = false,
    this.above,
    this.toolbarExtra,
  });

  final SuperTreeController<T> controller;
  final TreeSlotBuilder<T> leadingBuilder;
  final TreeTrailingBuilder<T>? trailingBuilder;
  final Color accent;
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final String nameColumnLabel;
  final String trailingColumnLabel;
  final String placeholder;
  final List<String> samples;

  /// Plural noun in the count badge ("12 accounts", "8 items").
  final String unit;
  final bool showArabic;
  final bool showLeafCount;

  /// Verb in the selection footer ("Selected", "Opened ledger for").
  final String selectionLabel;

  /// When true, the toolbar shows a Read / Edit mode toggle and an "Add node"
  /// action; in edit mode rows gain drag handles, inline rename, a row menu and
  /// drop targets. The controller's [SuperTreeController.mode] is the source of
  /// truth — this only surfaces the toggle UI.
  final bool enableEditing;

  /// Optional content rendered above the toolbar (e.g. a KPI grid).
  final Widget? above;

  /// Optional extra toolbar row beneath search (e.g. filter chips + a badge).
  final Widget? toolbarExtra;

  @override
  State<SuperTree<T>> createState() => _SuperTreeState<T>();
}

class _SuperTreeState<T> extends State<SuperTree<T>> {
  final TextEditingController _searchCtl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _treeFocus = FocusNode();
  bool _searchActive = false;

  SuperTreeController<T> get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _searchCtl.text = _c.query;
    _c.addListener(_syncSearch);
    _searchFocus.addListener(() => setState(() => _searchActive = _searchFocus.hasFocus));
  }

  void _syncSearch() {
    if (_searchCtl.text != _c.query) _searchCtl.text = _c.query;
  }

  @override
  void dispose() {
    _c.removeListener(_syncSearch);
    _searchCtl.dispose();
    _searchFocus.dispose();
    _treeFocus.dispose();
    super.dispose();
  }

  void _runQuery(String q) {
    _c.setQuery(q);
    _searchFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final ch = event.character;
    if (ch == '/') {
      _searchFocus.requestFocus();
      return KeyEventResult.handled;
    }
    if (ch == '?') {
      showShortcutsHelp(context);
      return KeyEventResult.handled;
    }
    if (ch == '*') {
      _c.expandAll();
      return KeyEventResult.handled;
    }
    if (ch == r'\') {
      _c.collapseAll();
      return KeyEventResult.handled;
    }
    final key = event.logicalKey;
    final dir = Directionality.of(context);
    if (key == LogicalKeyboardKey.arrowDown) {
      _c.moveDown();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _c.moveUp();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _c.jumpFirst();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _c.jumpLast();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
      arrowGoesInto(key, dir) ? _c.stepInto() : _c.stepOut();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.space && _c.selectable) {
      _c.toggleCheckedFocused();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _c.activate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.above != null) ...[
              widget.above!,
              const SizedBox(height: SuperTokensData.defaultSpace4),
            ],
            _toolbar(context),
            const SizedBox(height: SuperTokensData.defaultSpace4),
            _treeCard(context),
          ],
        );
      },
    );
  }

  // ── toolbar: search + sample chips + expand controls + extra row ──
  Widget _toolbar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: SuperTokensData.defaultSpace3,
          runSpacing: SuperTokensData.defaultSpace3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _searchField(context),
            for (final q in widget.samples) _sampleChip(context, q),
            if (widget.enableEditing) ...[
              if (_c.isEditable)
                _toolAction(context,
                    icon: Icons.add, label: 'Add node', onTap: _c.addRoot),
              _modeToggle(context),
            ],
            SuperIconButton(
              icon: Icons.keyboard_outlined,
              tooltip: 'Keyboard shortcuts  ·  ?',
              onPressed: () => showShortcutsHelp(context),
            ),
            _toolBtn(context, label: 'Expand all', up: false, onTap: _c.expandAll),
            _toolBtn(context, label: 'Collapse', up: true, onTap: _c.collapseAll),
          ],
        ),
        if (widget.toolbarExtra != null) ...[
          const SizedBox(height: SuperTokensData.defaultSpace3),
          widget.toolbarExtra!,
        ],
      ],
    );
  }

  // The Read / Edit segmented control.
  Widget _modeToggle(BuildContext context) {
    final t = context.superTheme;
    Widget seg(String label, IconData icon, bool active, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SuperTokensData.defaultDurFast,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          height: SuperTokensData.defaultControlHeight - 6,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? Color.alphaBlend(widget.accent.withOpacity(0.20), t.surface)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl - 2),
            border: Border.all(
                color: active ? widget.accent : const Color(0x00000000)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: active ? widget.accent : t.fg3),
              const SizedBox(width: 6),
              Text(label,
                  style: SuperText.body.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: active ? widget.accent : t.fg3)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: SuperTokensData.defaultControlHeight,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.inputBg,
        borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl),
        border: Border.all(color: t.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg('Read', Icons.visibility_outlined, !_c.isEditable,
              () => _c.setMode(SuperTreeMode.readable)),
          const SizedBox(width: 3),
          seg('Edit', Icons.edit_outlined, _c.isEditable,
              () => _c.setMode(SuperTreeMode.editable)),
        ],
      ),
    );
  }

  Widget _toolAction(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    final t = context.superTheme;
    return _HoverButton(
      onTap: onTap,
      builder: (hover) => Container(
        height: SuperTokensData.defaultControlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: hover
              ? Color.alphaBlend(widget.accent.withOpacity(0.16), t.surface)
              : Color.alphaBlend(widget.accent.withOpacity(0.10), t.surface),
          borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl),
          border: Border.all(color: widget.accent.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: widget.accent),
            const SizedBox(width: 7),
            Text(label,
                style: SuperText.body
                    .copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: widget.accent)),
          ],
        ),
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    final t = context.superTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 380),
      child: Container(
        height: SuperTokensData.defaultControlHeight,
        padding: EdgeInsets.symmetric(horizontal: _searchActive ? 13 : 14),
        decoration: BoxDecoration(
          color: t.inputBg,
          borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl),
          border: Border.all(
            color: _searchActive ? widget.accent : t.borderStrong,
            width: _searchActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 15, color: t.fg3),
            const SizedBox(width: 9),
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    _runQuery('');
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _searchCtl,
                  focusNode: _searchFocus,
                  onChanged: _c.setQuery,
                  cursorColor: widget.accent,
                  style: SuperText.body.copyWith(fontSize: 13.5, color: t.fg1),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: SuperText.body.copyWith(fontSize: 13.5, color: t.fg4),
                  ),
                ),
              ),
            ),
            if (_c.searching)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Text('${_c.matchCount}',
                    style: SuperText.mono.copyWith(fontSize: 11, color: t.fg3)),
              ),
            if (_c.query.isNotEmpty)
              GestureDetector(
                onTap: () => _runQuery(''),
                child: Icon(Icons.close, size: 14, color: t.fg3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sampleChip(BuildContext context, String q) {
    final t = context.superTheme;
    final on = _c.query == q;
    return GestureDetector(
      onTap: () => _runQuery(q),
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? Color.alphaBlend(widget.accent.withOpacity(0.18), t.surface) : t.inputBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? widget.accent : t.border),
        ),
        child: Text(q,
            style: SuperText.mono.copyWith(fontSize: 11.5, color: on ? widget.accent : t.fg2)),
      ),
    );
  }

  Widget _toolBtn(BuildContext context,
      {required String label, required bool up, required VoidCallback onTap}) {
    final t = context.superTheme;
    return _HoverButton(
      onTap: onTap,
      builder: (hover) => Container(
        height: SuperTokensData.defaultControlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: hover ? t.hover : const Color(0x00000000),
          borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl),
          border: Border.all(color: t.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: up ? 3.14159 : 0,
              child: Icon(Icons.keyboard_arrow_down, size: 16, color: t.fg2),
            ),
            const SizedBox(width: 7),
            Text(label, style: SuperText.body.copyWith(fontSize: 13, color: t.fg1)),
          ],
        ),
      ),
    );
  }

  // ── the tree card ──
  Widget _treeCard(BuildContext context) {
    final t = context.superTheme;
    final visible = _c.visible;
    return Focus(
      focusNode: _treeFocus,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onTap: () => _treeFocus.requestFocus(),
        child: Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusCard),
            border: Border.all(color: t.border),
            boxShadow: t.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _cardHeader(context),
              _columnHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: visible.isEmpty
                    ? _emptyState(context)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final n in visible)
                            TreeRow<T>(
                              key: ValueKey(n.code),
                              node: n,
                              depth: 0,
                              controller: _c,
                              accent: widget.accent,
                              leadingBuilder: widget.leadingBuilder,
                              trailingBuilder: widget.trailingBuilder,
                              showArabic: widget.showArabic,
                              showLeafCount: widget.showLeafCount,
                              onFocusRequest: _treeFocus.requestFocus,
                            ),
                        ],
                      ),
              ),
              if (_c.selected != null) _selectionFooter(context),
              if (_c.selectable && _c.checkedCount > 0) _checkedFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeader(BuildContext context) {
    final t = context.superTheme;
    final searching = _c.searching;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: widget.accent,
              borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusPill),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.titleIcon != null) ...[
                      Icon(widget.titleIcon, size: 15, color: widget.accent),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(widget.title,
                          style: SuperText.heading.copyWith(fontSize: 15, color: t.fg1)),
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(widget.subtitle!,
                      style: SuperText.caption.copyWith(fontSize: 12, color: t.fg3)),
                ],
              ],
            ),
          ),
          const SizedBox(width: SuperTokensData.defaultSpace3),
          Text(
            searching
                ? '${_c.visibleLeaves} of ${_c.totalLeaves}'
                : '${_c.totalLeaves} ${widget.unit}',
            style: SuperText.label.copyWith(fontSize: 10, letterSpacing: 0.5, color: t.fg3),
          ),
        ],
      ),
    );
  }

  Widget _columnHeader(BuildContext context) {
    final t = context.superTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          if (_c.selectionMode == SuperTreeSelectionMode.multi) ...[
            TreeCheckbox(
              state: _c.rootCheckState,
              accent: widget.accent,
              onTap: _c.toggleCheckAll,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(widget.nameColumnLabel.toUpperCase(),
                style: SuperText.label.copyWith(fontSize: 9.5, letterSpacing: 0.76, color: t.fg3)),
          ),
          if (widget.trailingColumnLabel.isNotEmpty)
            Text(widget.trailingColumnLabel.toUpperCase(),
                style: SuperText.label.copyWith(fontSize: 9.5, letterSpacing: 0.76, color: t.fg3)),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final t = context.superTheme;
    // Editable + empty (not searching): invite the first node.
    if (widget.enableEditing && _c.isEditable && !_c.searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.account_tree_outlined, size: 26, color: t.fg4),
            const SizedBox(height: 12),
            Text('This tree is empty',
                style: SuperText.body.copyWith(fontWeight: FontWeight.w600, color: t.fg2)),
            const SizedBox(height: 4),
            Text('Add a node to get started.',
                style: SuperText.caption.copyWith(color: t.fg3)),
            const SizedBox(height: 16),
            _toolAction(context, icon: Icons.add, label: 'Add node', onTap: _c.addRoot),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 26, color: t.fg4),
          const SizedBox(height: 12),
          Text('No matches for “${_c.query}”',
              style: SuperText.body.copyWith(fontWeight: FontWeight.w600, color: t.fg2)),
          const SizedBox(height: 4),
          Text('Try a different code or name, or clear the filters.',
              style: SuperText.caption.copyWith(color: t.fg3)),
        ],
      ),
    );
  }

  Widget _selectionFooter(BuildContext context) {
    final t = context.superTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(widget.accent.withOpacity(0.07), t.surface),
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 15, color: widget.accent),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: SuperText.body.copyWith(fontSize: 12.5, color: t.fg2),
                children: [
                  TextSpan(text: '${widget.selectionLabel} '),
                  TextSpan(
                    text: _c.selected,
                    style: SuperText.mono.copyWith(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: t.fg1),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _c.clearChecked,
            child: Text('Clear',
                style: SuperText.label.copyWith(
                    fontSize: 10.5, letterSpacing: 0.5, color: t.fg3)),
          ),
        ],
      ),
    );
  }

  // The selection summary footer shown while one or more checkboxes are on.
  Widget _checkedFooter(BuildContext context) {
    final t = context.superTheme;
    final n = _c.checkedCount;
    final single = _c.selectionMode == SuperTreeSelectionMode.single;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(widget.accent.withOpacity(0.07), t.surface),
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Icon(single ? Icons.radio_button_checked : Icons.check_box_outlined,
              size: 15, color: widget.accent),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: SuperText.body.copyWith(fontSize: 12.5, color: t.fg2),
                children: [
                  TextSpan(
                    text: '$n',
                    style: SuperText.mono.copyWith(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: t.fg1),
                  ),
                  TextSpan(text: single ? ' selected' : ' ${n == 1 ? 'item' : 'items'} selected'),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _c.clearChecked,
            child: Text('Clear',
                style: SuperText.label.copyWith(fontSize: 10.5, letterSpacing: 0.5, color: t.fg3)),
          ),
        ],
      ),
    );
  }
}

/// A tiny hover-state wrapper used by toolbar buttons.
class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.builder, required this.onTap});
  final Widget Function(bool hover) builder;
  final VoidCallback onTap;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(onTap: widget.onTap, child: widget.builder(_hover)),
    );
  }
}
