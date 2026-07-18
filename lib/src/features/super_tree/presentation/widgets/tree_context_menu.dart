// ============================================================
// features/super_tree_field/presentation/widgets/tree_context_menu.dart
// ------------------------------------------------------------
// The right-click (secondary-tap / long-press) context menu for a tree node.
// A themed overlay popup — no Material PopupMenu chrome — whose items adapt to
// the controller's mode:
//
//   readable  →  Open / Expand / Collapse  (+ Expand subtree for groups)
//   editable  →  Rename · Add child · Add sibling above / below · Delete
//
// Call `showTreeContextMenu(...)` from a row's onSecondaryTapDown /
// onLongPressStart with the global tap position.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/tree_node.dart';
import '../controllers/super_tree_controller.dart';

/// One entry in the tree context menu.
class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.dividerAbove = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool dividerAbove;
}

/// Opens the node context menu at [globalPosition]. Returns when dismissed.
Future<void> showTreeContextMenu<T>({
  required BuildContext context,
  required Offset globalPosition,
  required SuperTreeController<T> controller,
  required TreeNode<T> node,
  Color accent = SuperTokensData.defaultAccent,
}) {
  final items = _buildItems<T>(controller, node);
  if (items.isEmpty) return Future<void>.value();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss menu',
    barrierColor: const Color(0x00000000),
    transitionDuration: SuperTokensData.defaultDurFast,
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, __) {
      return _ContextMenuLayer(
        anchor: globalPosition,
        accent: accent,
        node: node,
        items: items,
        animation: anim,
      );
    },
  );
}

List<_MenuItem> _buildItems<T>(SuperTreeController<T> c, TreeNode<T> node) {
  final hasKids = node.hasChildren;
  if (!c.isEditable) {
    // ── readable mode ──
    return [
      if (hasKids)
        _MenuItem(
          icon: c.isExpanded(node.code) ? Icons.unfold_less : Icons.unfold_more,
          label: c.isExpanded(node.code) ? 'Collapse' : 'Expand',
          onTap: () => c.toggle(node.code),
        )
      else
        _MenuItem(
          icon: Icons.open_in_new,
          label: 'Open',
          onTap: () => c.openLeaf(node),
        ),
      if (hasKids)
        _MenuItem(
          icon: Icons.account_tree_outlined,
          label: 'Expand subtree',
          onTap: () => c.expandSubtree(node.code),
        ),
    ];
  }
  // ── editable mode ──
  return [
    _MenuItem(icon: Icons.edit_outlined, label: 'Rename', onTap: () => c.beginRename(node.code)),
    _MenuItem(
        icon: Icons.subdirectory_arrow_right,
        label: 'Add child',
        onTap: () => c.addChild(node.code)),
    _MenuItem(
        icon: Icons.arrow_upward,
        label: 'Add sibling above',
        dividerAbove: true,
        onTap: () => c.addSiblingBefore(node.code)),
    _MenuItem(
        icon: Icons.arrow_downward,
        label: 'Add sibling below',
        onTap: () => c.addSiblingAfter(node.code)),
    _MenuItem(
        icon: Icons.delete_outline,
        label: 'Delete',
        danger: true,
        dividerAbove: true,
        onTap: () => c.deleteNode(node.code)),
  ];
}

class _ContextMenuLayer extends StatelessWidget {
  const _ContextMenuLayer({
    required this.anchor,
    required this.accent,
    required this.node,
    required this.items,
    required this.animation,
  });

  final Offset anchor;
  final Color accent;
  final Object node;
  final List<_MenuItem> items;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final media = MediaQuery.of(context).size;
    const menuW = 230.0;
    final menuH = _estimateHeight(items);

    // Clamp so the menu stays on-screen, flipping past the pointer if needed.
    var dx = anchor.dx;
    var dy = anchor.dy;
    if (dx + menuW > media.width - 8) dx = (anchor.dx - menuW).clamp(8.0, media.width - menuW - 8);
    if (dy + menuH > media.height - 8) dy = (anchor.dy - menuH).clamp(8.0, media.height - menuH - 8);

    return Stack(
      children: [
        Positioned(
          left: dx,
          top: dy,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(
                CurvedAnimation(parent: animation, curve: SuperTokensData.defaultCurveStandard),
              ),
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuW,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl),
                    border: Border.all(color: t.borderStrong),
                    boxShadow: t.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items) ...[
                        if (item.dividerAbove)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Hairline(),
                          ),
                        _MenuRow(
                          item: item,
                          accent: accent,
                          onSelected: () {
                            Navigator.of(context).pop();
                            item.onTap();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static double _estimateHeight(List<_MenuItem> items) {
    var h = 10.0;
    for (final i in items) {
      h += 34;
      if (i.dividerAbove) h += 11;
    }
    return h;
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.item, required this.accent, required this.onSelected});
  final _MenuItem item;
  final Color accent;
  final VoidCallback onSelected;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final danger = widget.item.danger;
    final cs = SuperMaterialThemeData.of(context).colorScheme;
    final fg = danger ? cs.error : t.fg1;
    final hoverBg = danger
        ? cs.error.withOpacity(0.12)
        : Color.alphaBlend(widget.accent.withOpacity(0.10), t.surface);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelected,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: _hover ? hoverBg : const Color(0x00000000),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 15, color: danger ? cs.error : t.fg3),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: SuperText.body.copyWith(fontSize: 13, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
