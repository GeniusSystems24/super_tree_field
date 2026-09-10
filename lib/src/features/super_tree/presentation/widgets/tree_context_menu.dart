// ============================================================
// features/super_tree_field/presentation/widgets/tree_context_menu.dart
// ------------------------------------------------------------
// Reusable recursive context-menu primitives plus default SuperTree actions.
// Branch items open cascading OverlayEntry submenus to arbitrary depth.
// The popup can be used in two ways:
//
//   1. Tree integration: supply controller + node and optionally an
//      itemsBuilder to replace/extend/filter the default node actions.
//   2. Standalone integration: supply an explicit `items` list and use the
//      same menu surface anywhere in the host application.
// ============================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_tree_field/localization/localizations.dart';

import '../../domain/entities/tree_node.dart';
import '../controllers/super_tree_controller.dart';

/// Identifies the built-in actions created by
/// [buildDefaultTreeContextMenuItems].
///
/// Use these values when filtering or reordering the default menu without
/// depending on localized labels.
enum TreeContextMenuAction {
  /// Opens a leaf node.
  open,

  /// Expands a collapsed branch.
  expand,

  /// Collapses an expanded branch.
  collapse,

  /// Expands every descendant branch below a node.
  expandSubtree,

  /// Starts inline rename for a node.
  rename,

  /// Groups creation actions in the default editable menu.
  add,

  /// Adds a child below a node.
  addChild,

  /// Adds a sibling before a node.
  addSiblingAbove,

  /// Adds a sibling after a node.
  addSiblingBelow,

  /// Deletes a node and its subtree.
  delete,
}

/// One reusable leaf or branch entry displayed by [showTreeContextMenu].
///
/// Add [children] to create a cascading submenu. Nested branches are recursive,
/// matching the interaction model used by `SuperPopupMenuButton`.
@immutable
class TreeContextMenuItem {
  /// Creates a context-menu item.
  const TreeContextMenuItem({
    required this.label,
    this.id,
    this.leading,
    this.trailing,
    this.onTap,
    this.children = const <TreeContextMenuItem>[],
    this.enabled = true,
    this.danger = false,
    this.dividerAbove = false,
    this.closeOnTap = true,
  });

  /// Optional stable identifier used by callers to filter/reorder items.
  ///
  /// Built-in tree actions use [TreeContextMenuAction]. Custom menus may use
  /// any identifier type that is meaningful to the host application.
  final Object? id;

  /// User-visible label rendered for the item.
  final String label;

  /// Optional widget rendered before [label].
  ///
  /// Icons inherit the menu's resolved [IconTheme].
  final Widget? leading;

  /// Optional widget rendered after [label].
  final Widget? trailing;

  /// Callback invoked when this enabled item is selected as a leaf.
  ///
  /// Branch items ignore [onTap] and open [children] instead.
  final VoidCallback? onTap;

  /// Nested child items displayed in a cascading submenu.
  ///
  /// Children can themselves contain children, so menus may be nested to any
  /// practical depth.
  final List<TreeContextMenuItem> children;

  /// Whether the item can be selected or opened.
  ///
  /// An enabled branch only requires non-empty [children]. An enabled leaf
  /// additionally requires a non-null [onTap].
  final bool enabled;

  /// Whether the item uses the destructive/error visual treatment.
  final bool danger;

  /// Whether a divider is inserted immediately before this item.
  final bool dividerAbove;

  /// Whether selecting a leaf dismisses the root popup before [onTap] runs.
  ///
  /// This value is ignored by branch items.
  final bool closeOnTap;

  /// Whether this item opens a cascading submenu.
  bool get hasChildren => children.isNotEmpty;

  /// Whether this item currently accepts pointer/tap activation.
  bool get isEnabled => enabled && (hasChildren || onTap != null);
}

/// Builds context-menu items for one tree [node].
///
/// Call [buildDefaultTreeContextMenuItems] inside the builder when the custom
/// menu should extend, filter, or reorder the package defaults rather than
/// replacing them completely.
typedef TreeContextMenuItemsBuilder<T> = List<TreeContextMenuItem> Function(
  BuildContext context,
  SuperTreeController<T> controller,
  TreeNode<T> node,
);

/// Visual configuration for [showTreeContextMenu].
///
/// Null color/radius/shadow values inherit from the active `super_core` theme.
@immutable
class TreeContextMenuStyle {
  /// Creates context-menu styling overrides.
  const TreeContextMenuStyle({
    this.width = 230,
    this.edgePadding = 8,
    this.submenuGap = 4,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 5),
    this.itemMargin = const EdgeInsets.symmetric(horizontal: 5),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    this.itemRadius = 5,
    this.dividerPadding = const EdgeInsets.symmetric(vertical: 5),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.boxShadow,
    this.foregroundColor,
    this.iconColor,
    this.hoverColor,
    this.dangerColor,
    this.dangerHoverColor,
    this.itemTextStyle,
    this.disabledOpacity = 0.45,
  }) : assert(width > 0),
       assert(edgePadding >= 0),
       assert(submenuGap >= 0),
       assert(borderWidth >= 0),
       assert(itemRadius >= 0),
       assert(disabledOpacity >= 0 && disabledOpacity <= 1);

  /// Preferred popup width before viewport clamping.
  final double width;

  /// Minimum distance maintained between the popup and viewport edges.
  final double edgePadding;

  /// Gap between a branch row and its cascading submenu.
  final double submenuGap;

  /// Padding around the complete item list.
  final EdgeInsetsGeometry menuPadding;

  /// Margin around each menu row.
  final EdgeInsetsGeometry itemMargin;

  /// Padding inside each menu row.
  final EdgeInsetsGeometry itemPadding;

  /// Border radius applied to hover backgrounds for individual rows.
  final double itemRadius;

  /// Padding around dividers inserted by [TreeContextMenuItem.dividerAbove].
  final EdgeInsetsGeometry dividerPadding;

  /// Optional menu surface color.
  final Color? backgroundColor;

  /// Optional menu outline color.
  final Color? borderColor;

  /// Menu outline width. Set to zero to remove the outline.
  final double borderWidth;

  /// Optional menu border radius.
  final BorderRadiusGeometry? borderRadius;

  /// Optional menu shadow list.
  final List<BoxShadow>? boxShadow;

  /// Optional normal-item foreground color.
  final Color? foregroundColor;

  /// Optional normal-item icon color.
  final Color? iconColor;

  /// Optional hover background for normal items.
  final Color? hoverColor;

  /// Optional foreground/icon color for destructive items.
  final Color? dangerColor;

  /// Optional hover background for destructive items.
  final Color? dangerHoverColor;

  /// Optional base text style for menu labels.
  final TextStyle? itemTextStyle;

  /// Opacity applied to disabled items.
  final double disabledOpacity;
}

/// Context supplied to [TreeContextMenuConfigBuilder] for one node.
///
/// This object exposes both the package defaults and the effective base items,
/// allowing callers to customize one node without duplicating menu logic for
/// the rest of the tree.
@immutable
class TreeContextMenuNodeContext<T> {
  /// Creates context for one node's context-menu configuration.
  const TreeContextMenuNodeContext({
    required this.context,
    required this.controller,
    required this.node,
    required this.packageDefaultItems,
    required this.baseItems,
    required this.defaultStyle,
    required this.defaultAccent,
  });

  /// Build context of the row opening the menu.
  final BuildContext context;

  /// Controller that owns the current tree state.
  final SuperTreeController<T> controller;

  /// Node whose menu is being opened.
  final TreeNode<T> node;

  /// Localized items produced directly by
  /// [buildDefaultTreeContextMenuItems] for [node].
  final List<TreeContextMenuItem> packageDefaultItems;

  /// Effective items before node-level configuration is applied.
  ///
  /// When [TreeContextMenuItemsBuilder] is supplied, this contains its result.
  /// Otherwise it is identical to [packageDefaultItems].
  final List<TreeContextMenuItem> baseItems;

  /// Tree-level style configured by [SuperTree.contextMenuStyle].
  final TreeContextMenuStyle defaultStyle;

  /// Tree-level accent override, or null when the theme provides the accent.
  final Color? defaultAccent;
}

/// Complete context-menu overrides for one tree node.
@immutable
class TreeContextMenuConfig {
  /// Creates node-specific menu overrides.
  const TreeContextMenuConfig({
    this.enabled = true,
    this.items,
    this.style,
    this.accent,
  });

  /// Disables the context menu for only the current node.
  const TreeContextMenuConfig.disabled()
      : enabled = false,
        items = null,
        style = null,
        accent = null;

  /// Whether the context menu is enabled for this node.
  final bool enabled;

  /// Complete item list for this node.
  ///
  /// Leave null to preserve [TreeContextMenuNodeContext.baseItems]. An empty
  /// list intentionally suppresses the popup because there is nothing to show.
  final List<TreeContextMenuItem>? items;

  /// Optional style used only for this node.
  final TreeContextMenuStyle? style;

  /// Optional accent used only for this node.
  final Color? accent;
}

/// Builds complete context-menu configuration independently for every node.
///
/// Inspect [TreeContextMenuNodeContext.node] to branch by code, payload,
/// leaf/group state, or any other node data.
typedef TreeContextMenuConfigBuilder<T> = TreeContextMenuConfig Function(
  TreeContextMenuNodeContext<T> menuContext,
);

/// Builds the localized package-default context menu for [node].
///
/// Readable mode provides open/expand actions. Editable mode provides rename,
/// a nested Add branch, and delete. Returned items carry
/// [TreeContextMenuAction] IDs so callers can safely filter or reorder them.
List<TreeContextMenuItem> buildDefaultTreeContextMenuItems<T>({
  required BuildContext context,
  required SuperTreeController<T> controller,
  required TreeNode<T> node,
}) {
  final l = context.superTreeLocalization;
  final hasKids = node.hasChildren;

  if (!controller.isEditable) {
    return [
      if (hasKids)
        TreeContextMenuItem(
          id: controller.isExpanded(node.code)
              ? TreeContextMenuAction.collapse
              : TreeContextMenuAction.expand,
          leading: Icon(
            controller.isExpanded(node.code)
                ? Icons.unfold_less
                : Icons.unfold_more,
          ),
          label: controller.isExpanded(node.code) ? l.collapse : l.expand,
          onTap: () => controller.toggle(node.code),
        )
      else
        TreeContextMenuItem(
          id: TreeContextMenuAction.open,
          leading: const Icon(Icons.open_in_new),
          label: l.open,
          onTap: () => controller.openLeaf(node),
        ),
      if (hasKids)
        TreeContextMenuItem(
          id: TreeContextMenuAction.expandSubtree,
          leading: const Icon(Icons.schema_outlined),
          label: l.expandSubtree,
          onTap: () => controller.expandSubtree(node.code),
        ),
    ];
  }

  return [
    TreeContextMenuItem(
      id: TreeContextMenuAction.rename,
      leading: const Icon(Icons.edit_outlined),
      label: l.rename,
      onTap: () => controller.beginRename(node.code),
    ),
    TreeContextMenuItem(
      id: TreeContextMenuAction.add,
      leading: const Icon(Icons.add_rounded),
      label: l.add,
      children: [
        TreeContextMenuItem(
          id: TreeContextMenuAction.addChild,
          leading: const Icon(Icons.subdirectory_arrow_right),
          label: l.addChild,
          onTap: () => controller.addChild(
            node.code,
            newNodeName: l.newNode,
          ),
        ),
        TreeContextMenuItem(
          id: TreeContextMenuAction.addSiblingAbove,
          leading: const Icon(Icons.arrow_upward),
          label: l.addSiblingAbove,
          dividerAbove: true,
          onTap: () => controller.addSiblingBefore(
            node.code,
            newNodeName: l.newNode,
          ),
        ),
        TreeContextMenuItem(
          id: TreeContextMenuAction.addSiblingBelow,
          leading: const Icon(Icons.arrow_downward),
          label: l.addSiblingBelow,
          onTap: () => controller.addSiblingAfter(
            node.code,
            newNodeName: l.newNode,
          ),
        ),
      ],
    ),
    TreeContextMenuItem(
      id: TreeContextMenuAction.delete,
      leading: const Icon(Icons.delete_outline),
      label: l.delete,
      danger: true,
      dividerAbove: true,
      onTap: () => controller.deleteNode(node.code),
    ),
  ];
}

/// Opens a reusable context menu at [globalPosition].
///
/// For normal [SuperTree] integration, pass [controller] and [node]. The
/// package defaults are used unless [itemsBuilder] is supplied. Use
/// [configBuilder] when items, style, accent, or enabled state must vary by
/// node.
///
/// To use the popup independently from a tree, omit [controller]/[node] and
/// provide an explicit [items] list.
///
/// If both [items] and [itemsBuilder] are supplied, [items] takes precedence.
Future<void> showTreeContextMenu<T>({
  required BuildContext context,
  required Offset globalPosition,
  SuperTreeController<T>? controller,
  TreeNode<T>? node,
  List<TreeContextMenuItem>? items,
  TreeContextMenuItemsBuilder<T>? itemsBuilder,
  TreeContextMenuConfigBuilder<T>? configBuilder,
  Color? accent,
  TreeContextMenuStyle style = const TreeContextMenuStyle(),
  String? barrierLabel,
  Color barrierColor = const Color(0x00000000),
  Duration? transitionDuration,
}) {
  if (items == null && (controller == null || node == null)) {
    throw ArgumentError(
      'Provide explicit items, or provide both controller and node.',
    );
  }

  if (configBuilder != null && (controller == null || node == null)) {
    throw ArgumentError(
      'configBuilder requires both controller and node.',
    );
  }

  final packageDefaultItems = controller != null && node != null
      ? buildDefaultTreeContextMenuItems<T>(
          context: context,
          controller: controller,
          node: node,
        )
      : const <TreeContextMenuItem>[];

  final baseItems = items ??
      (itemsBuilder != null
          ? itemsBuilder(context, controller!, node!)
          : packageDefaultItems);

  var resolvedItems = baseItems;
  var resolvedStyle = style;
  var resolvedAccent = accent;

  if (configBuilder != null) {
    final config = configBuilder(
      TreeContextMenuNodeContext<T>(
        context: context,
        controller: controller!,
        node: node!,
        packageDefaultItems: List<TreeContextMenuItem>.unmodifiable(
          packageDefaultItems,
        ),
        baseItems: List<TreeContextMenuItem>.unmodifiable(baseItems),
        defaultStyle: style,
        defaultAccent: accent,
      ),
    );

    if (!config.enabled) return Future<void>.value();

    resolvedItems = config.items ?? baseItems;
    resolvedStyle = config.style ?? style;
    resolvedAccent = config.accent ?? accent;
  }

  if (resolvedItems.isEmpty) return Future<void>.value();

  final effectiveAccent =
      resolvedAccent ?? SuperThemeData.of(context).tokens.accent;
  final effectiveBarrierLabel =
      barrierLabel ?? context.superTreeLocalization.dismissMenu;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: effectiveBarrierLabel,
    barrierColor: barrierColor,
    transitionDuration:
        transitionDuration ?? SuperThemeData.of(context).tokens.durFast,
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) => _ContextMenuLayer(
      anchor: globalPosition,
      accent: effectiveAccent,
      items: resolvedItems,
      animation: animation,
      style: resolvedStyle,
    ),
  );
}

class _ContextMenuLayer extends StatelessWidget {
  const _ContextMenuLayer({
    required this.anchor,
    required this.accent,
    required this.items,
    required this.animation,
    required this.style,
  });

  final Offset anchor;
  final Color accent;
  final List<TreeContextMenuItem> items;
  final Animation<double> animation;
  final TreeContextMenuStyle style;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    return CustomSingleChildLayout(
      delegate: _ContextMenuPositionDelegate(
        anchor: anchor,
        textDirection: textDirection,
        edgePadding: style.edgePadding,
      ),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: SuperThemeData.of(context).tokens.curveStandard,
            ),
          ),
          alignment: textDirection == TextDirection.rtl
              ? Alignment.topRight
              : Alignment.topLeft,
          child: _ContextMenuSurface(
            items: items,
            accent: accent,
            style: style,
            onLeafSelected: (item) {
              if (!item.isEnabled || item.hasChildren) return;
              if (item.closeOnTap) Navigator.of(context).pop();
              item.onTap?.call();
            },
          ),
        ),
      ),
    );
  }
}

/// One recursive menu level.
///
/// Every level owns at most one open branch. Branch rows create their submenu
/// in a root [OverlayEntry], so nested menus are painted above the dialog
/// barrier and can cascade to arbitrary depth.
class _ContextMenuLevel extends StatefulWidget {
  const _ContextMenuLevel({
    required this.items,
    required this.accent,
    required this.style,
    required this.onLeafSelected,
  });

  final List<TreeContextMenuItem> items;
  final Color accent;
  final TreeContextMenuStyle style;
  final ValueChanged<TreeContextMenuItem> onLeafSelected;

  @override
  State<_ContextMenuLevel> createState() => _ContextMenuLevelState();
}

class _ContextMenuLevelState extends State<_ContextMenuLevel> {
  int? _openBranchIndex;

  @override
  void didUpdateWidget(covariant _ContextMenuLevel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.items, widget.items)) {
      _openBranchIndex = null;
    }

    final index = _openBranchIndex;
    if (index != null &&
        (index >= widget.items.length ||
            !widget.items[index].hasChildren ||
            !widget.items[index].enabled)) {
      _openBranchIndex = null;
    }
  }

  void _openBranch(int index) {
    final item = widget.items[index];
    if (!item.enabled || !item.hasChildren || _openBranchIndex == index) {
      return;
    }
    setState(() => _openBranchIndex = index);
  }

  void _toggleBranch(int index) {
    final item = widget.items[index];
    if (!item.enabled || !item.hasChildren) return;

    setState(() {
      _openBranchIndex = _openBranchIndex == index ? null : index;
    });
  }

  void _closeBranch() {
    if (_openBranchIndex == null) return;
    setState(() => _openBranchIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < widget.items.length; index++)
          _buildItem(index, widget.items[index]),
      ],
    );
  }

  Widget _buildItem(int index, TreeContextMenuItem item) {
    final divider = item.dividerAbove
        ? Padding(
            padding: widget.style.dividerPadding,
            child: const Hairline(),
          )
        : null;

    final row = item.hasChildren
        ? _ContextMenuBranch(
            item: item,
            open: _openBranchIndex == index,
            accent: widget.accent,
            style: widget.style,
            onHoverOpen: () => _openBranch(index),
            onToggle: () => _toggleBranch(index),
            onLeafSelected: widget.onLeafSelected,
          )
        : MouseRegion(
            onEnter: (_) => _closeBranch(),
            child: _MenuRow(
              item: item,
              accent: widget.accent,
              style: widget.style,
              onSelected: () => widget.onLeafSelected(item),
            ),
          );

    if (divider == null) return row;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [divider, row],
    );
  }
}

/// A branch row that owns one cascading submenu [OverlayEntry].
class _ContextMenuBranch extends StatefulWidget {
  const _ContextMenuBranch({
    required this.item,
    required this.open,
    required this.accent,
    required this.style,
    required this.onHoverOpen,
    required this.onToggle,
    required this.onLeafSelected,
  });

  final TreeContextMenuItem item;
  final bool open;
  final Color accent;
  final TreeContextMenuStyle style;
  final VoidCallback onHoverOpen;
  final VoidCallback onToggle;
  final ValueChanged<TreeContextMenuItem> onLeafSelected;

  @override
  State<_ContextMenuBranch> createState() => _ContextMenuBranchState();
}

class _ContextMenuBranchState extends State<_ContextMenuBranch> {
  final GlobalKey _anchorKey = GlobalKey();

  OverlayEntry? _submenuEntry;
  Rect? _anchorRect;
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    if (widget.open) _scheduleSubmenuSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
    if (widget.open) _scheduleSubmenuSync();
  }

  @override
  void didUpdateWidget(covariant _ContextMenuBranch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != oldWidget.open ||
        widget.accent != oldWidget.accent ||
        widget.style != oldWidget.style ||
        !identical(widget.item.children, oldWidget.item.children)) {
      _scheduleSubmenuSync();
    }
  }

  @override
  void dispose() {
    _removeSubmenu();
    super.dispose();
  }

  void _scheduleSubmenuSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSubmenu();
    });
  }

  void _syncSubmenu() {
    if (!widget.open || !widget.item.enabled || !widget.item.hasChildren) {
      _removeSubmenu();
      return;
    }

    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final origin = box.localToGlobal(Offset.zero);
    _anchorRect = origin & box.size;

    final existing = _submenuEntry;
    if (existing != null) {
      existing.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (overlayContext) {
        final anchorRect = _anchorRect;
        if (anchorRect == null) return const SizedBox.shrink();

        final submenu = Directionality(
          textDirection: _textDirection,
          child: CustomSingleChildLayout(
            delegate: _SubmenuPositionDelegate(
              anchorRect: anchorRect,
              textDirection: _textDirection,
              edgePadding: widget.style.edgePadding,
              gap: widget.style.submenuGap,
            ),
            child: _ContextMenuSurface(
              items: widget.item.children,
              accent: widget.accent,
              style: widget.style,
              onLeafSelected: widget.onLeafSelected,
            ),
          ),
        );

        return InheritedTheme.captureAll(context, submenu);
      },
    );

    _submenuEntry = entry;
    overlay.insert(entry);
  }

  void _removeSubmenu() {
    final entry = _submenuEntry;
    if (entry == null) return;

    _submenuEntry = null;
    entry.remove();
    entry.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _anchorKey,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.item.enabled) widget.onHoverOpen();
        },
        child: Semantics(
          button: true,
          enabled: widget.item.enabled,
          expanded: widget.open,
          child: _MenuRow(
            item: widget.item,
            accent: widget.accent,
            style: widget.style,
            showSubmenuIndicator: true,
            selected: widget.open,
            onSelected: widget.onToggle,
          ),
        ),
      ),
    );
  }
}

/// Surface shared by the root popup and every nested submenu.
class _ContextMenuSurface extends StatelessWidget {
  const _ContextMenuSurface({
    required this.items,
    required this.accent,
    required this.style,
    required this.onLeafSelected,
  });

  final List<TreeContextMenuItem> items;
  final Color accent;
  final TreeContextMenuStyle style;
  final ValueChanged<TreeContextMenuItem> onLeafSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final viewport = MediaQuery.sizeOf(context);
    final availableWidth = math.max(
      0.0,
      viewport.width - (style.edgePadding * 2),
    );
    final availableHeight = math.max(
      0.0,
      viewport.height - (style.edgePadding * 2),
    );
    final menuWidth = math.min(style.width, availableWidth);
    final borderColor = style.borderColor ?? t.borderStrong;
    final borderRadius = style.borderRadius ??
        BorderRadius.circular(context.superTheme.spacing.radiusControl);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: menuWidth,
        decoration: BoxDecoration(
          color: style.backgroundColor ?? t.surface,
          borderRadius: borderRadius,
          border: style.borderWidth == 0
              ? null
              : Border.all(
                  color: borderColor,
                  width: style.borderWidth,
                ),
          boxShadow: style.boxShadow ?? t.cardShadow,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: availableHeight),
          child: SingleChildScrollView(
            padding: style.menuPadding,
            child: _ContextMenuLevel(
              items: items,
              accent: accent,
              style: style,
              onLeafSelected: onLeafSelected,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextMenuPositionDelegate extends SingleChildLayoutDelegate {
  const _ContextMenuPositionDelegate({
    required this.anchor,
    required this.textDirection,
    required this.edgePadding,
  });

  final Offset anchor;
  final TextDirection textDirection;
  final double edgePadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final horizontalPadding = edgePadding * 2;
    final verticalPadding = edgePadding * 2;

    return BoxConstraints(
      minWidth: 0,
      minHeight: 0,
      maxWidth: math.max(0.0, constraints.maxWidth - horizontalPadding),
      maxHeight: math.max(0.0, constraints.maxHeight - verticalPadding),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final roomOnStart = anchor.dx - edgePadding;
    final roomOnEnd = size.width - anchor.dx - edgePadding;

    // Treat the pointer as the logical top-start corner of the menu.
    // In LTR the preferred surface grows toward the end (right). In RTL it
    // grows toward the start side (left). If that side cannot fit, prefer the
    // opposite side only when it has more room.
    var openToStart = textDirection == TextDirection.rtl;
    if (openToStart) {
      if (roomOnStart < childSize.width && roomOnEnd > roomOnStart) {
        openToStart = false;
      }
    } else if (roomOnEnd < childSize.width && roomOnStart > roomOnEnd) {
      openToStart = true;
    }

    var dx = openToStart ? anchor.dx - childSize.width : anchor.dx;
    var dy = anchor.dy;

    if (dy + childSize.height > size.height - edgePadding) {
      dy = anchor.dy - childSize.height;
    }

    final maxX = math.max(
      edgePadding,
      size.width - childSize.width - edgePadding,
    );
    final maxY = math.max(
      edgePadding,
      size.height - childSize.height - edgePadding,
    );

    dx = dx.clamp(edgePadding, maxX).toDouble();
    dy = dy.clamp(edgePadding, maxY).toDouble();

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_ContextMenuPositionDelegate oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.edgePadding != edgePadding;
}

/// Positions a nested menu beside its branch while keeping the entire submenu
/// inside the current viewport.
class _SubmenuPositionDelegate extends SingleChildLayoutDelegate {
  const _SubmenuPositionDelegate({
    required this.anchorRect,
    required this.textDirection,
    required this.edgePadding,
    required this.gap,
  });

  final Rect anchorRect;
  final TextDirection textDirection;
  final double edgePadding;
  final double gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final horizontalPadding = edgePadding * 2;
    final verticalPadding = edgePadding * 2;

    return BoxConstraints(
      minWidth: 0,
      minHeight: 0,
      maxWidth: math.max(0.0, constraints.maxWidth - horizontalPadding),
      maxHeight: math.max(0.0, constraints.maxHeight - verticalPadding),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final roomOnStart = anchorRect.left - edgePadding;
    final roomOnEnd = size.width - anchorRect.right - edgePadding;

    var openToStart = textDirection == TextDirection.rtl;
    if (openToStart) {
      if (roomOnStart < childSize.width + gap && roomOnEnd > roomOnStart) {
        openToStart = false;
      }
    } else if (roomOnEnd < childSize.width + gap && roomOnStart > roomOnEnd) {
      openToStart = true;
    }

    var dx = openToStart
        ? anchorRect.left - childSize.width - gap
        : anchorRect.right + gap;
    var dy = anchorRect.top;

    final maxX = math.max(
      edgePadding,
      size.width - childSize.width - edgePadding,
    );
    final maxY = math.max(
      edgePadding,
      size.height - childSize.height - edgePadding,
    );

    dx = dx.clamp(edgePadding, maxX).toDouble();
    dy = dy.clamp(edgePadding, maxY).toDouble();

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_SubmenuPositionDelegate oldDelegate) =>
      oldDelegate.anchorRect != anchorRect ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.edgePadding != edgePadding ||
      oldDelegate.gap != gap;
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    required this.item,
    required this.accent,
    required this.style,
    required this.onSelected,
    this.showSubmenuIndicator = false,
    this.selected = false,
  });

  final TreeContextMenuItem item;
  final Color accent;
  final TreeContextMenuStyle style;
  final VoidCallback onSelected;
  final bool showSubmenuIndicator;
  final bool selected;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final cs = SuperMaterialThemeData.of(context).colorScheme;
    final item = widget.item;
    final style = widget.style;
    final enabled = item.isEnabled;
    final dangerColor = style.dangerColor ?? cs.error;
    final foreground = item.danger
        ? dangerColor
        : (style.foregroundColor ?? t.fg1);
    final iconColor = item.danger
        ? dangerColor
        : (style.iconColor ?? t.fg3);
    final hoverBackground = item.danger
        ? (style.dangerHoverColor ?? dangerColor.withValues(alpha: 0.12))
        : (style.hoverColor ??
              Color.alphaBlend(
                widget.accent.withValues(alpha: 0.10),
                style.backgroundColor ?? t.surface,
              ));
    final baseTextStyle =
        style.itemTextStyle ?? context.superTextTheme.body.copyWith(fontSize: 13);
    final textStyle = baseTextStyle.copyWith(color: foreground);
    final direction = Directionality.of(context);
    final submenuChevron = Icon(
      direction == TextDirection.rtl
          ? Icons.chevron_left_rounded
          : Icons.chevron_right_rounded,
      // These Material chevrons are directional IconData. Because the icon is
      // already chosen explicitly for RTL/LTR above, force LTR rendering here
      // to prevent Flutter from mirroring it a second time.
      textDirection: TextDirection.ltr,
      size: 18,
      color: iconColor,
    );

    return Opacity(
      opacity: enabled ? 1 : style.disabledOpacity,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hover = true) : null,
        onExit: enabled ? (_) => setState(() => _hover = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onSelected : null,
          child: Container(
            margin: style.itemMargin,
            padding: style.itemPadding,
            decoration: BoxDecoration(
              color: _hover || widget.selected
                  ? hoverBackground
                  : const Color(0x00000000),
              borderRadius: BorderRadius.circular(style.itemRadius),
            ),
            child: Row(
              children: [
                if (item.leading != null) ...[
                  IconTheme(
                    data: IconThemeData(size: 15, color: iconColor),
                    child: item.leading!,
                  ),
                  const SizedBox(width: 11),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: textStyle,
                  ),
                ),
                if (item.trailing != null) ...[
                  const SizedBox(width: 11),
                  DefaultTextStyle.merge(
                    style: textStyle.copyWith(color: iconColor),
                    child: IconTheme(
                      data: IconThemeData(size: 15, color: iconColor),
                      child: item.trailing!,
                    ),
                  ),
                ],
                if (widget.showSubmenuIndicator) ...[
                  const SizedBox(width: 8),
                  submenuChevron,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
