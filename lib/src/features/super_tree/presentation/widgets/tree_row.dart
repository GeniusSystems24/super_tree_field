// ============================================================
// features/super_tree/presentation/widgets/tree_row.dart
// ------------------------------------------------------------
// One recursive node row. Owns the twisty, indent, connector line, the
// hover/selected/focused backgrounds, the highlighted name, the optional Arabic
// label and leaf-count badge, and delegates the leading + trailing cells to the
// host via builders. A 1:1 port of the React TreeNode / MiniRow row anatomy.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/tree_node.dart';
import '../../domain/usecases/tree_logic.dart';
import '../controllers/super_tree_controller.dart';
import 'highlight_text.dart';

/// Per-row context handed to the leading / trailing builders.
class TreeRowInfo {
  const TreeRowInfo({required this.depth, required this.open, required this.hasChildren});
  final int depth;
  final bool open;
  final bool hasChildren;
}

/// Builds the leading cell (type dot, file icon, avatar) for a node.
typedef TreeSlotBuilder<T> = Widget Function(
    BuildContext context, TreeNode<T> node, TreeRowInfo info);

/// Builds the optional trailing cell(s) for a node (balance, size, role).
typedef TreeTrailingBuilder<T> = Widget? Function(
    BuildContext context, TreeNode<T> node, TreeRowInfo info);

/// A single recursive tree row + (when open) its children.
class TreeRow<T> extends StatefulWidget {
  const TreeRow({
    super.key,
    required this.node,
    required this.depth,
    required this.controller,
    required this.accent,
    required this.leadingBuilder,
    this.trailingBuilder,
    this.showArabic = true,
    this.showLeafCount = true,
    this.onFocusRequest,
  });

  final TreeNode<T> node;
  final int depth;
  final SuperTreeController<T> controller;
  final Color accent;
  final TreeSlotBuilder<T> leadingBuilder;
  final TreeTrailingBuilder<T>? trailingBuilder;
  final bool showArabic;
  final bool showLeafCount;

  /// Called on row tap (before activation) so the host can focus the tree body
  /// — keeps keyboard navigation working immediately after a pointer click.
  final VoidCallback? onFocusRequest;

  @override
  State<TreeRow<T>> createState() => _TreeRowState<T>();
}

class _TreeRowState<T> extends State<TreeRow<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final node = widget.node;
    final c = widget.controller;
    final hasKids = node.hasChildren;
    final open = c.isOpen(node.code);
    final indent = 14.0 + widget.depth * 22.0;
    final isSel = c.selected == node.code;
    final isFocus = c.focusId == node.code;
    final info = TreeRowInfo(depth: widget.depth, open: open, hasChildren: hasKids);

    final trailing = widget.trailingBuilder?.call(context, node, info);

    final bg = isSel
        ? Color.alphaBlend(widget.accent.withOpacity(0.12), t.surface)
        : (_hover ? t.hover : const Color(0x00000000));
    final boxBorder = isSel
        ? Border.all(color: Color.alphaBlend(widget.accent.withOpacity(0.45), t.surface))
        : (isFocus
            ? Border.all(
                color: Color.alphaBlend(widget.accent.withOpacity(0.70), t.surface), width: 1.5)
            : null);

    final row = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onFocusRequest?.call();
          c.activateNode(node);
        },
        child: AnimatedContainer(
          duration: SuperTokens.durFast,
          curve: SuperTokens.curveStandard,
          padding: EdgeInsetsDirectional.only(start: indent, end: 12, top: 9, bottom: 9),
          decoration: BoxDecoration(
            color: bg,
            border: boxBorder,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              // ── twisty ──
              SizedBox(
                width: 14,
                child: hasKids
                    ? AnimatedRotation(
                        turns: open ? 0 : -0.25,
                        duration: SuperTokens.durBase,
                        curve: SuperTokens.curveStandard,
                        child: Icon(Icons.keyboard_arrow_down, size: 16, color: t.fg3),
                      )
                    : null,
              ),
              const SizedBox(width: 9),
              // ── leading slot + name + arabic + count (fills the row) ──
              Expanded(
                child: Row(
                  children: [
                    widget.leadingBuilder(context, node, info),
                    const SizedBox(width: 9),
                    Flexible(
                      child: HighlightText(
                        text: node.name,
                        query: c.query,
                        overflow: TextOverflow.ellipsis,
                        style: SuperText.body.copyWith(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: widget.depth == 0
                              ? FontWeight.w700
                              : (widget.depth == 1 ? FontWeight.w600 : FontWeight.w500),
                          color: widget.depth >= 3 ? t.fg2 : t.fg1,
                        ),
                      ),
                    ),
                    if (widget.showArabic && node.ar != null) ...[
                      const SizedBox(width: 9),
                      Flexible(
                        child: HighlightText(
                          text: node.ar!,
                          query: c.query,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: SuperTokens.arabicFont, fontSize: 12, color: t.fg4),
                        ),
                      ),
                    ],
                    if (widget.showLeafCount && hasKids) ...[
                      const SizedBox(width: 9),
                      _CountBadge(count: TreeLogic.leafCount(node)),
                    ],
                  ],
                ),
              ),
              // ── trailing slot ──
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing,
                const SizedBox(width: 12),
              ],
              // ── open affordance ──
              SizedBox(
                width: 14,
                child: (!hasKids && _hover)
                    ? Icon(Icons.chevron_right, size: 15, color: t.fg4)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );

    if (!hasKids || !open) return row;

    // ── children with a connector rail ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        Stack(
          children: [
            PositionedDirectional(
              start: indent + 7,
              top: 0,
              bottom: 13,
              child: Container(width: 1, color: t.border),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in node.children!)
                  TreeRow<T>(
                    key: ValueKey(child.code),
                    node: child,
                    depth: widget.depth + 1,
                    controller: c,
                    accent: widget.accent,
                    leadingBuilder: widget.leadingBuilder,
                    trailingBuilder: widget.trailingBuilder,
                    showArabic: widget.showArabic,
                    showLeafCount: widget.showLeafCount,
                    onFocusRequest: widget.onFocusRequest,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The rounded leaf-count badge shown on group rows.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: t.inputBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.border),
      ),
      child: Text(
        '$count',
        style: SuperText.mono.copyWith(
          fontSize: 9.5,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: t.fg3,
        ),
      ),
    );
  }
}
