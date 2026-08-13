// ============================================================
// features/super_tree_field/presentation/widgets/super_tree.dart
// ------------------------------------------------------------
// The generic SuperTree View: a focused hierarchy card with recursive rows,
// selection, editing, keyboard navigation and configurable scrolling. Search,
// mode toggles, add actions, help and expansion controls are composed by the
// host through `SuperTreeController<T>` rather than rendered by this widget.
// ============================================================

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_tree_field/src/features/super_tree/domain/entities/tree_node.dart';

import '../../../../core/core.dart' hide FieldDensity;
import '../controllers/super_tree_controller.dart';
import 'tree_row.dart';

/// A themed, keyboard-first hierarchy view over a [SuperTreeController].
class SuperTree<T> extends StatefulWidget {
  /// Creates a generic hierarchy view driven by [controller].
  const SuperTree({
    super.key,
    required this.controller,
    required this.leadingBuilder,
    this.trailingBuilder,
    this.accent,
    this.title = 'Hierarchy',
    this.subtitle,
    this.titleIcon,
    this.nameColumnLabel = 'Name',
    this.trailingColumnLabel = '',
    this.unit = 'items',
    this.showArabic = true,
    this.showLeafCount = true,
    this.selectionLabel = 'Selected',
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

  /// Title displayed in the tree card header.
  final String title;

  /// Optional subtitle displayed below [title].
  final String? subtitle;

  /// Optional icon displayed beside [title].
  final IconData? titleIcon;

  /// Label for the primary name column.
  final String nameColumnLabel;

  /// Label for the optional trailing column.
  final String trailingColumnLabel;


  /// Plural noun used in count labels, such as "items" or "records".
  final String unit;

  /// Whether [TreeNode.ar] labels are displayed when available.
  final bool showArabic;

  /// Whether group rows display their descendant leaf count.
  final bool showLeafCount;

  /// Label used in the selected-leaf footer, such as "Selected".
  final String selectionLabel;

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
            // A normal (non-shrink-wrapped) ListView needs a finite viewport.
            // Preserve SuperTree's ability to live inside another scroll view
            // by falling back to shrink-wrap when height is unbounded.
            final boundedViewport =
                !widget.shrinkWrap && constraints.hasBoundedHeight;
            final treeCard = _treeCard(
              context,
              boundedViewport: boundedViewport,
            );

            return treeCard;
          },
        );
      },
    );
  }

  Widget _treeCard(
    BuildContext context, {
    required bool boundedViewport,
  }) {
    final t = context.superTheme;
    final accent = (widget.accent ?? SuperThemeData.of(context).tokens.accent);
    final visible = _c.visible;

    Widget body;
    if (visible.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: _emptyState(context),
      );
      if (boundedViewport) body = Expanded(child: body);
    } else {
      body = _treeRows(
        context,
        visible,
        accent,
        shrinkWrap: !boundedViewport,
      );
      if (boundedViewport) body = Expanded(child: body);
    }

    return Focus(
      focusNode: _treeFocus,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onTap: () => _treeFocus.requestFocus(),
        child: Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(
              context.superTheme.spacing.radiusCard,
            ),
            border: Border.all(color: t.border),
            boxShadow: t.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize:
                boundedViewport ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _cardHeader(context),
              _columnHeader(context),
              body,
              if (_c.selected != null) _selectionFooter(context),
              if (_c.selectable && _c.checkedCount > 0) _checkedFooter(context),
            ],
          ),
        ),
      ),
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
              onFocusRequest: _treeFocus.requestFocus,
            ),
        ],
      ),
    );
  }

  Widget _cardHeader(BuildContext context) {
    final t = context.superTheme;
    final accent = (widget.accent ?? SuperThemeData.of(context).tokens.accent);
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
              color: accent,
              borderRadius: BorderRadius.circular(
                context.superTheme.spacing.radiusPill,
              ),
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
                      child: Text(
                        widget.title,
                        style: context.superTextTheme.heading.copyWith(
                          fontSize: 15,
                          color: t.fg1,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: context.superTextTheme.caption.copyWith(
                      fontSize: 12,
                      color: t.fg3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: context.superTheme.spacing.space3),
          Text(
            searching
                ? '${_c.visibleLeaves} of ${_c.totalLeaves}'
                : '${_c.totalLeaves} ${widget.unit}',
            style: context.superTextTheme.label.copyWith(
              fontSize: 10,
              letterSpacing: 0.5,
              color: t.fg3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _columnHeader(BuildContext context) {
    final t = context.superTheme;
    final accent = (widget.accent ?? SuperThemeData.of(context).tokens.accent);
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
              accent: accent,
              onTap: _c.toggleCheckAll,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              widget.nameColumnLabel.toUpperCase(),
              style: context.superTextTheme.label.copyWith(
                fontSize: 9.5,
                letterSpacing: 0.76,
                color: t.fg3,
              ),
            ),
          ),
          if (widget.trailingColumnLabel.isNotEmpty)
            Text(
              widget.trailingColumnLabel.toUpperCase(),
              style: context.superTextTheme.label.copyWith(
                fontSize: 9.5,
                letterSpacing: 0.76,
                color: t.fg3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final t = context.superTheme;
    if (!_c.searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.schema_outlined, size: 26, color: t.fg4),
            const SizedBox(height: 12),
            Text(
              'This tree is empty',
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
            'No matches for “${_c.query}”',
            style: context.superTextTheme.body.copyWith(
              fontWeight: FontWeight.w600,
              color: t.fg2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different code or name, or clear the filters.',
            style: context.superTextTheme.caption.copyWith(color: t.fg3),
          ),
        ],
      ),
    );
  }

  Widget _selectionFooter(BuildContext context) {
    final t = context.superTheme;
    final accent = (widget.accent ?? SuperThemeData.of(context).tokens.accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.07), t.surface),
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 15, color: widget.accent),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: context.superTextTheme.body.copyWith(fontSize: 12.5, color: t.fg2),
                children: [
                  TextSpan(text: '${widget.selectionLabel} '),
                  TextSpan(
                    text: _c.selected,
                    style: context.superTextTheme.mono.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: t.fg1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _c.clearChecked,
            child: Text(
              'Clear',
              style: context.superTextTheme.label.copyWith(
                fontSize: 10.5,
                letterSpacing: 0.5,
                color: t.fg3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The selection summary footer shown while one or more checkboxes are on.
  Widget _checkedFooter(BuildContext context) {
    final t = context.superTheme;
    final accent = (widget.accent ?? SuperThemeData.of(context).tokens.accent);
    final n = _c.checkedCount;
    final single = _c.selectionMode == SuperTreeSelectionMode.single;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.07), t.surface),
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Icon(
            single ? Icons.radio_button_checked : Icons.check_box_outlined,
            size: 15,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: context.superTextTheme.body.copyWith(fontSize: 12.5, color: t.fg2),
                children: [
                  TextSpan(
                    text: '$n',
                    style: context.superTextTheme.mono.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: t.fg1,
                    ),
                  ),
                  TextSpan(
                    text: single
                        ? ' selected'
                        : ' ${n == 1 ? 'item' : 'items'} selected',
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _c.clearChecked,
            child: Text(
              'Clear',
              style: context.superTextTheme.label.copyWith(
                fontSize: 10.5,
                letterSpacing: 0.5,
                color: t.fg3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

