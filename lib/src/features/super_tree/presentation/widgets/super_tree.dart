// ============================================================
// features/super_tree_field/presentation/widgets/super_tree.dart
// ------------------------------------------------------------
// The generic SuperTree view: a focused recursive hierarchy viewport.
// It renders tree nodes and tree-owned interaction only. Titles, subtitles,
// column headings, totals, selection summaries, cards, toolbars, and other
// page chrome are composed by the host around this widget.
// ============================================================

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';
import 'package:super_tree_field/localization/localizations.dart';
import 'package:super_tree_field/src/features/super_tree/domain/entities/tree_node.dart';

import '../controllers/super_tree_controller.dart';
import 'tree_context_menu.dart';
import 'tree_row.dart';

/// A keyboard-first recursive hierarchy view over a [SuperTreeController].
///
/// [SuperTree] owns tree/node rendering and interaction only. Compose titles,
/// column labels, totals, selection summaries, and surface/card decoration in
/// the host UI when they are required.
class SuperTree<T> extends StatefulWidget {
  /// Creates a generic hierarchy view driven by [controller].
  const SuperTree({
    super.key,
    required this.controller,
    required this.leadingBuilder,
    this.trailingBuilder,
    this.accent,
    this.showArabic = true,
    this.showLeafCount = true,
    this.contextMenuEnabled = true,
    this.contextMenuItemsBuilder,
    this.contextMenuConfigBuilder,
    this.contextMenuStyle = const TreeContextMenuStyle(),
    this.onSearchRequested,
    this.onShortcutsRequested,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  /// Controller for hierarchy, search, focus, selection, and editing state.
  final SuperTreeController<T> controller;

  /// Builds the leading cell for each rendered node.
  final TreeSlotBuilder<T> leadingBuilder;

  /// Builds the optional trailing cell for each rendered node.
  final TreeTrailingBuilder<T>? trailingBuilder;

  /// Overrides the theme accent used by tree interactions.
  final Color? accent;

  /// Whether [TreeNode.ar] labels are displayed when available.
  final bool showArabic;

  /// Whether group rows display their descendant leaf count.
  final bool showLeafCount;

  /// Whether rows can open their context menu from pointer/touch gestures
  /// and the editable row menu button.
  final bool contextMenuEnabled;

  /// Optional per-node context-menu builder.
  ///
  /// When null, [buildDefaultTreeContextMenuItems] supplies the localized
  /// readable/editable actions. Use the default builder inside this callback
  /// when the host needs to extend, filter, or reorder those actions.
  final TreeContextMenuItemsBuilder<T>? contextMenuItemsBuilder;

  /// Optional complete context-menu configuration for each node.
  ///
  /// Use this when different nodes need different items, styles, accents, or
  /// enabled states. The older [contextMenuItemsBuilder] remains supported and
  /// its output becomes [TreeContextMenuNodeContext.baseItems].
  final TreeContextMenuConfigBuilder<T>? contextMenuConfigBuilder;

  /// Visual configuration applied to every node context menu.
  final TreeContextMenuStyle contextMenuStyle;

  /// Called when the focused tree receives the `/` shortcut.
  ///
  /// Use this to focus a search field composed outside [SuperTree]. If
  /// null, `/` is ignored by the tree.
  final VoidCallback? onSearchRequested;

  /// Called when the focused tree receives the `?` shortcut.
  ///
  /// Use this to show help UI composed by the host. If null, `?` is
  /// ignored by the tree.
  final VoidCallback? onShortcutsRequested;


  /// Whether the tree's scroll view scrolls in the reverse direction.
  ///
  /// This follows [ScrollView.reverse]. With the vertical tree axis, false uses
  /// the normal downward direction and true reverses it.
  final bool reverse;

  /// Controls the scroll position of the tree rows.
  ///
  /// This has the same role as [ScrollView.controller]. When [primary] is true,
  /// leave this null so Flutter can use the nearest [PrimaryScrollController].
  final ScrollController? scrollController;

  /// Whether this is the primary scroll view associated with the parent.
  ///
  /// This follows [ScrollView.primary]. A primary scroll view can inherit a
  /// [PrimaryScrollController] from its context.
  final bool? primary;

  /// Defines how the tree responds to user scrolling.
  ///
  /// See [ScrollView.physics] and [ScrollPhysics]. When null, Flutter derives
  /// the effective physics from the ambient [ScrollBehavior].
  final ScrollPhysics? physics;

  /// Whether the scroll view's extent is determined by its contents.
  ///
  /// This follows [ScrollView.shrinkWrap]. Shrink-wrapping is more expensive
  /// because the scroll view can need to recompute its size while scrolling.
  /// If [SuperTree] receives unbounded vertical constraints, it safely falls
  /// back to shrink-wrapping so it can remain embedded in another scroll view.
  final bool shrinkWrap;

  /// The number of logical pixels before and after the visible viewport to
  /// cache.
  ///
  /// See [ScrollView.cacheExtent]. A null value lets Flutter use its default
  /// viewport cache extent.
  final double? cacheExtent;

  /// The number of children that contribute semantic information.
  ///
  /// See [ScrollView.semanticChildCount]. Leave null to use [ListView]'s
  /// normal semantic child-count behavior.
  final int? semanticChildCount;

  /// Determines how a drag gesture's initial position is reported.
  ///
  /// This follows [ScrollView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Defines how the on-screen keyboard is dismissed while the tree scrolls.
  ///
  /// A null value uses [ScrollViewKeyboardDismissBehavior.manual], matching the
  /// default behavior of Flutter scroll views.
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// Restoration ID used to save and restore the tree's scroll offset.
  ///
  /// See [ScrollView.restorationId]. A null value disables restoration for this
  /// scroll view.
  final String? restorationId;

  /// The clipping behavior applied to the tree's scrollable viewport.
  ///
  /// This follows [ScrollView.clipBehavior].
  final Clip clipBehavior;

  /// How the tree's scrollable viewport behaves during hit testing.
  ///
  /// This follows [ScrollView.hitTestBehavior].
  final HitTestBehavior hitTestBehavior;


  @override
  State<SuperTree<T>> createState() => _SuperTreeState<T>();
}

class _SuperTreeState<T> extends State<SuperTree<T>> {
  final FocusNode _treeFocus = FocusNode();

  SuperTreeController<T> get _c => widget.controller;

  @override
  void dispose() {
    _treeFocus.dispose();
    super.dispose();
  }


  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final ch = event.character;
    if (ch == '/' && widget.onSearchRequested != null) {
      widget.onSearchRequested!();
      return KeyEventResult.handled;
    }
    if (ch == '?' && widget.onShortcutsRequested != null) {
      widget.onShortcutsRequested!();
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
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowLeft) {
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
        return LayoutBuilder(
          builder: (context, constraints) {
            // The widget intentionally renders only the recursive tree viewport
            // and its nodes. Titles, column headings, counts, card surfaces,
            // and selection summaries belong to host composition.
            final boundedViewport =
                !widget.shrinkWrap && constraints.hasBoundedHeight;
            final accent =
                widget.accent ?? SuperThemeData.of(context).tokens.accent;
            final visible = _c.visible;

            Widget body;
            if (visible.isEmpty) {
              body = _emptyState(context);
            } else {
              body = _treeRows(
                context,
                visible,
                accent,
                shrinkWrap: !boundedViewport,
              );
            }

            if (boundedViewport) {
              body = Expanded(child: body);
            }

            return Focus(
              focusNode: _treeFocus,
              onKeyEvent: _onKey,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _treeFocus.requestFocus,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize:
                      boundedViewport ? MainAxisSize.max : MainAxisSize.min,
                  children: [body],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _treeRows(
    BuildContext context,
    List<TreeNode<T>> visible,
    Color accent, {
    required bool shrinkWrap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: ListView(
        reverse: widget.reverse,
        controller: widget.scrollController,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: shrinkWrap,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior ??
            ScrollViewKeyboardDismissBehavior.manual,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        hitTestBehavior: widget.hitTestBehavior,
        children: [
          for (final n in visible)
            TreeRow<T>(
              key: ValueKey(n.code),
              node: n,
              depth: 0,
              controller: _c,
              accent: accent,
              leadingBuilder: widget.leadingBuilder,
              trailingBuilder: widget.trailingBuilder,
              showArabic: widget.showArabic,
              showLeafCount: widget.showLeafCount,
              contextMenuEnabled: widget.contextMenuEnabled,
              contextMenuItemsBuilder: widget.contextMenuItemsBuilder,
              contextMenuConfigBuilder: widget.contextMenuConfigBuilder,
              contextMenuStyle: widget.contextMenuStyle,
              onFocusRequest: _treeFocus.requestFocus,
            ),
        ],
      ),
    );
  }


  Widget _emptyState(BuildContext context) {
    final t = context.superTheme;
    final l = context.superTreeLocalization;
    if (!_c.searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.schema_outlined, size: 26, color: t.fg4),
            const SizedBox(height: 12),
            Text(
              l.treeEmpty,
              style: context.superTextTheme.body.copyWith(
                fontWeight: FontWeight.w600,
                color: t.fg2,
              ),
            ),
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
          Text(
            l.noMatchesFor(_c.query),
            style: context.superTextTheme.body.copyWith(
              fontWeight: FontWeight.w600,
              color: t.fg2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.tryDifferentCodeOrName,
            style: context.superTextTheme.caption.copyWith(color: t.fg3),
          ),
        ],
      ),
    );
  }


  // The selection summary footer shown while one or more checkboxes are on.
}

