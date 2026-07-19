// ============================================================
// features/super_tree_field/presentation/widgets/tree_row.dart
// ------------------------------------------------------------
// One recursive node row. Owns the twisty, indent, connector line, the
// hover/selected/focused backgrounds, the highlighted name, the optional Arabic
// label and leaf-count badge, and delegates the leading + trailing cells to the
// host via builders.
//
// In EDITABLE mode the row also gains:
//   • a drag handle  → Draggable<String> payload = node.code
//   • a drop target  → before / inside / after, with a live indicator
//   • inline rename  → a focused field swaps in for the name
//   • a row menu (⋮) → the editable context menu (also on right-click)
// In READABLE mode right-click / long-press opens the readable context menu.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../domain/entities/tree_node.dart';
import '../../domain/usecases/tree_logic.dart';
import '../controllers/super_tree_controller.dart';
import 'highlight_text.dart';
import 'tree_context_menu.dart';

/// Per-row context handed to the leading / trailing builders.
class TreeRowInfo {
  const TreeRowInfo({
    required this.depth,
    required this.open,
    required this.hasChildren,
  });
  final int depth;
  final bool open;
  final bool hasChildren;
}

/// Builds the leading cell (type dot, file icon, avatar) for a node.
typedef TreeSlotBuilder<T> =
    Widget Function(BuildContext context, TreeNode<T> node, TreeRowInfo info);

/// Builds the optional trailing cell(s) for a node (balance, size, role).
typedef TreeTrailingBuilder<T> =
    Widget? Function(BuildContext context, TreeNode<T> node, TreeRowInfo info);

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
  final GlobalKey _rowKey = GlobalKey();
  bool _hover = false;
  DropPosition? _dropPos; // active drop indicator while a drag hovers
  bool _dragging = false;

  SuperTreeController<T> get _c => widget.controller;

  void _openMenu(Offset globalPos) {
    showTreeContextMenu<T>(
      context: context,
      globalPosition: globalPos,
      controller: _c,
      node: widget.node,
      accent: widget.accent,
    );
  }

  // Map a pointer's global position to a drop zone within this row.
  DropPosition? _zoneFor(Offset globalPos, bool hasKids) {
    final box = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final frac = (box.globalToLocal(globalPos).dy / box.size.height).clamp(
      0.0,
      1.0,
    );
    if (hasKids) {
      if (frac < 0.28) return DropPosition.before;
      if (frac > 0.72) return DropPosition.after;
      return DropPosition.inside;
    }
    return frac < 0.5 ? DropPosition.before : DropPosition.after;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final node = widget.node;
    final c = _c;
    final hasKids = node.hasChildren;
    final open = c.isOpen(node.code);
    final indent = 14.0 + widget.depth * 22.0;
    final isSel = c.selected == node.code;
    final isFocus = c.focusId == node.code;
    final editing = c.isEditing(node.code);
    final editable = c.isEditable && !c.searching;
    final info = TreeRowInfo(
      depth: widget.depth,
      open: open,
      hasChildren: hasKids,
    );

    final trailing = widget.trailingBuilder?.call(context, node, info);
    final dropInside = _dropPos == DropPosition.inside;

    final bg = dropInside
        ? Color.alphaBlend(widget.accent.withOpacity(0.14), t.surface)
        : isSel
        ? Color.alphaBlend(widget.accent.withOpacity(0.12), t.surface)
        : (_hover ? t.hover : const Color(0x00000000));
    final boxBorder = dropInside
        ? Border.all(color: widget.accent, width: 1.5)
        : isSel
        ? Border.all(
            color: Color.alphaBlend(widget.accent.withOpacity(0.45), t.surface),
          )
        : (isFocus
              ? Border.all(
                  color: Color.alphaBlend(
                    widget.accent.withOpacity(0.70),
                    t.surface,
                  ),
                  width: 1.5,
                )
              : null);

    // ── the single row's visual body ──
    Widget rowInner = AnimatedContainer(
      key: _rowKey,
      duration: SuperThemeData.of(context).tokens.durFast,
      curve: SuperThemeData.of(context).tokens.curveStandard,
      padding: EdgeInsetsDirectional.only(
        start: indent,
        end: 12,
        top: 9,
        bottom: 9,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: boxBorder,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          // ── drag handle (editable) ──
          if (editable) _dragHandle(t, node),
          // ── selection checkbox ──
          if (c.selectable) ...[
            TreeCheckbox(
              state: c.checkState(node.code),
              accent: widget.accent,
              onTap: () {
                widget.onFocusRequest?.call();
                c.toggleChecked(node);
              },
            ),
            const SizedBox(width: 10),
          ],
          // ── twisty ──
          SizedBox(
            width: 14,
            child: hasKids
                ? AnimatedRotation(
                    turns: open ? 0 : -0.25,
                    duration: SuperThemeData.of(context).tokens.durBase,
                    curve: SuperThemeData.of(context).tokens.curveStandard,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: t.fg3,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 9),
          // ── leading slot + name/rename + arabic + count ──
          Expanded(
            child: Row(
              children: [
                widget.leadingBuilder(context, node, info),
                const SizedBox(width: 9),
                if (editing)
                  Flexible(
                    child: _RenameField(
                      initial: node.name,
                      accent: widget.accent,
                      onCommit: (v) => c.commitRename(node.code, v),
                      onCancel: c.cancelRename,
                    ),
                  )
                else
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
                            : (widget.depth == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500),
                        color: widget.depth >= 3 ? t.fg2 : t.fg1,
                      ),
                    ),
                  ),
                if (!editing && widget.showArabic && node.ar != null) ...[
                  const SizedBox(width: 9),
                  Flexible(
                    child: HighlightText(
                      text: node.ar!,
                      query: c.query,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: SuperThemeData.of(
                          context,
                        ).tokens.arabicFont,
                        fontSize: 12,
                        color: t.fg4,
                      ),
                    ),
                  ),
                ],
                if (!editing && widget.showLeafCount && hasKids) ...[
                  const SizedBox(width: 9),
                  _CountBadge(count: TreeLogic.leafCount(node)),
                ],
              ],
            ),
          ),
          // ── trailing slot ──
          if (trailing != null && !editing) ...[
            const SizedBox(width: 12),
            trailing,
            const SizedBox(width: 12),
          ],
          // ── row menu (editable) / open affordance ──
          if (editable && !editing)
            _MenuButton(
              visible: _hover,
              color: t.fg3,
              onTap: () {
                final box =
                    _rowKey.currentContext?.findRenderObject() as RenderBox?;
                final pos = box != null
                    ? box.localToGlobal(
                        Offset(box.size.width - 30, box.size.height - 4),
                      )
                    : Offset.zero;
                _openMenu(pos);
              },
            )
          else
            SizedBox(
              width: 14,
              child: (!hasKids && _hover && !editing)
                  ? Icon(Icons.chevron_right, size: 15, color: t.fg4)
                  : null,
            ),
        ],
      ),
    );

    // ── before / after drop indicator lines ──
    if (_dropPos == DropPosition.before || _dropPos == DropPosition.after) {
      rowInner = Stack(
        clipBehavior: Clip.none,
        children: [
          rowInner,
          PositionedDirectional(
            start: indent,
            end: 12,
            top: _dropPos == DropPosition.before ? -1 : null,
            bottom: _dropPos == DropPosition.after ? -1 : null,
            child: _DropLine(color: widget.accent),
          ),
        ],
      );
    }

    // ── gestures: tap toggles/opens, right-click + long-press open the menu ──
    Widget interactive = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: editing
            ? null
            : () {
                widget.onFocusRequest?.call();
                c.activateNode(node);
              },
        onSecondaryTapDown: editing ? null : (d) => _openMenu(d.globalPosition),
        onLongPressStart: editing ? null : (d) => _openMenu(d.globalPosition),
        child: Opacity(opacity: _dragging ? 0.4 : 1, child: rowInner),
      ),
    );

    // ── drop target (editable, not searching) ──
    if (editable) {
      final child = interactive;
      interactive = DragTarget<String>(
        onWillAcceptWithDetails: (d) => c.canDrop(d.data, node.code),
        onMove: (d) {
          if (!c.canDrop(d.data, node.code)) return;
          final z = _zoneFor(d.offset, hasKids);
          if (z != _dropPos) setState(() => _dropPos = z);
        },
        onLeave: (_) {
          if (_dropPos != null) setState(() => _dropPos = null);
        },
        onAcceptWithDetails: (d) {
          final z = _zoneFor(d.offset, hasKids) ?? DropPosition.after;
          setState(() => _dropPos = null);
          c.moveNode(d.data, node.code, z);
        },
        builder: (context, _, __) => child,
      );
    }

    if (!hasKids || !open) return interactive;

    // ── children with a connector rail ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        interactive,
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

  // The draggable grip shown at the start of every row in editable mode.
  Widget _dragHandle(SuperThemeData t, TreeNode<T> node) {
    final grip = Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: Icon(
        Icons.drag_indicator,
        size: 15,
        color: _hover ? t.fg3 : t.fg4,
      ),
    );
    return Draggable<String>(
      data: node.code,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => setState(() => _dragging = true),
      onDragEnd: (_) => setState(() => _dragging = false),
      onDraggableCanceled: (_, __) => setState(() => _dragging = false),
      feedback: _DragFeedback(label: node.name, accent: widget.accent),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: grip),
    );
  }
}

/// The inline rename editor that swaps in for a node's name.
class _RenameField extends StatefulWidget {
  const _RenameField({
    required this.initial,
    required this.accent,
    required this.onCommit,
    required this.onCancel,
  });

  final String initial;
  final Color accent;
  final void Function(String value) onCommit;
  final VoidCallback onCancel;

  @override
  State<_RenameField> createState() => _RenameFieldState();
}

class _RenameFieldState extends State<_RenameField> {
  late final TextEditingController _ctl =
      TextEditingController(text: widget.initial)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initial.length,
        );
  final FocusNode _focus = FocusNode();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  void _commit() {
    if (_done) return;
    _done = true;
    widget.onCommit(_ctl.text);
  }

  void _cancel() {
    if (_done) return;
    _done = true;
    widget.onCancel();
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _cancel();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: t.inputBg,
          borderRadius: BorderRadius.circular(
            SuperThemeData.of(context).tokens.radiusControl,
          ),
          border: Border.all(color: widget.accent, width: 1.5),
        ),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: _ctl,
          focusNode: _focus,
          cursorColor: widget.accent,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _commit(),
          style: SuperText.body.copyWith(
            fontSize: 13,
            height: 1.1,
            color: t.fg1,
          ),
          decoration: const InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

/// The pill that follows the pointer while a row is being dragged.
class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Material(
      color: Colors.transparent,
      child: Transform.translate(
        offset: const Offset(10, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(
              SuperThemeData.of(context).tokens.radiusControl,
            ),
            border: Border.all(color: accent, width: 1.5),
            boxShadow: t.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_indicator, size: 14, color: accent),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SuperText.body.copyWith(fontSize: 12.5, color: t.fg1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 2 px accent bar with a leading dot — the before/after drop indicator.
class _DropLine extends StatelessWidget {
  const _DropLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 2, color: color)),
        ],
      ),
    );
  }
}

/// The hover-revealed ⋮ button that opens the editable context menu.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.visible,
    required this.color,
    required this.onTap,
  });
  final bool visible;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(width: 18);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 18,
          child: Icon(Icons.more_vert, size: 16, color: color),
        ),
      ),
    );
  }
}

/// A design-system tristate checkbox used for row selection. 18×18, 4 px
/// radius, hairline border when off, accent fill with a check (or a dash when
/// partial) when on. Owns its own tap so the row beneath does not activate.
/// Also reused by [SuperTree]'s header "select all" control.
class TreeCheckbox extends StatelessWidget {
  const TreeCheckbox({
    super.key,
    required this.state,
    required this.accent,
    required this.onTap,
  });

  final TreeCheckState state;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final on = state != TreeCheckState.unchecked;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: SuperThemeData.of(context).tokens.durFast,
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? accent : const Color(0x00000000),
            borderRadius: BorderRadius.circular(
              SuperThemeData.of(context).tokens.radiusControl,
            ),
            border: Border.all(
              color: on ? accent : t.borderStrong,
              width: on ? 0 : 1.4,
            ),
          ),
          child: on
              ? Icon(
                  state == TreeCheckState.partial ? Icons.remove : Icons.check,
                  size: 13,
                  color: Colors.white,
                )
              : null,
        ),
      ),
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
