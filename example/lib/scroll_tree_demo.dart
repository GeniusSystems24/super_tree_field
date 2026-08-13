// ============================================================
// example/lib/scroll_tree_demo.dart
// ------------------------------------------------------------
// EXAMPLE 6 — bounded SuperTree scrolling. Demonstrates the distinction between
// SuperTreeController<T> (hierarchy state) and ScrollController (viewport
// state), plus the ScrollView-style properties exposed by SuperTree.
// ============================================================

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';
import 'responsive_example_layout.dart';

/// Payload used by rows in the scrolling demonstration.
class ScrollItem {
  /// Creates a scroll-demo item at [index].
  const ScrollItem(this.index);

  /// Zero-based item index.
  final int index;
}

final List<TreeNode<ScrollItem>> _scrollTree = List<TreeNode<ScrollItem>>.generate(
  60,
  (index) => TreeNode<ScrollItem>(
    code: 'row-${index + 1}',
    name: 'Scrollable item ${index + 1}',
    value: ScrollItem(index),
  ),
);

/// Demonstrates the scroll configuration exposed by [SuperTree].
class ScrollTreeDemo extends StatefulWidget {
  /// Creates the scroll-configuration demonstration page.
  const ScrollTreeDemo({super.key});

  @override
  State<ScrollTreeDemo> createState() => _ScrollTreeDemoState();
}

class _ScrollTreeDemoState extends State<ScrollTreeDemo> {
  final SuperTreeControlsController _controls = SuperTreeControlsController();
  late final SuperTreeController<ScrollItem> _controller;
  late final ScrollController _scrollController;

  bool _reverse = false;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _controller = SuperTreeController<ScrollItem>(
      roots: _scrollTree,
      searchText: (node) => '${node.code} ${node.name}',
    )..addListener(_handleTreeState);
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleTreeState() {
    if (mounted) setState(() {});
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    setState(() => _offset = _scrollController.offset);
  }

  Future<void> _scrollTo(double offset) async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _scrollToStart() => _scrollTo(0);

  Future<void> _scrollToEnd() {
    if (!_scrollController.hasClients) return Future<void>.value();
    return _scrollTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _controls.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _controller
      ..removeListener(_handleTreeState)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final accent = SuperMaterialThemeData.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: t.fg2),
        title: Text(
          'Scroll Configuration',
          style: context.superTextTheme.heading.copyWith(color: t.fg1),
        ),
      ),
      body: ResponsiveExampleLayout(
        maxWidth: 900,
        scrollable: false,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: context.superTheme.spacing.space3,
                runSpacing: context.superTheme.spacing.space3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SuperButton(
                    label: 'Jump to start',
                    variant: SuperButtonVariant.secondary,
                    onPressed: _scrollToStart,
                  ),
                  SuperButton(
                    label: 'Jump to end',
                    variant: SuperButtonVariant.secondary,
                    onPressed: _scrollToEnd,
                  ),
                  Container(
                    height: context.superTheme.spacing.controlHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.inputBg,
                      borderRadius: BorderRadius.circular(
                        context.superTheme.spacing.radiusControl,
                      ),
                      border: Border.all(color: t.borderStrong),
                    ),
                    child: Text(
                      'offset ${_offset.toStringAsFixed(0)} px',
                      style: context.superTextTheme.mono.copyWith(
                        fontSize: 11.5,
                        color: t.fg2,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reverse',
                        style: context.superTextTheme.body.copyWith(
                          fontSize: 12.5,
                          color: t.fg2,
                        ),
                      ),
                      Switch(
                        value: _reverse,
                        onChanged: (value) => setState(() => _reverse = value),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.superTheme.spacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  SuperTreeControls<ScrollItem>(
                                    controller: _controller,
                                    controlsController: _controls,
                                    placeholder: 'Search scrollable items…   ( / )',
                                    samples: const ['item 10', 'item 30', 'item 60'],
                                    accent: accent,
                                  ),
                  SizedBox(height: context.superTheme.spacing.space4),
                  Expanded(
                                      child: SuperTree<ScrollItem>(
                                                      controller: _controller,
                                      onSearchRequested: _controls.requestSearchFocus,
                                      onShortcutsRequested: () => showShortcutsHelp(context),
                                                      // Flutter ScrollView / ListView configuration.
                                                      reverse: _reverse,
                                                      scrollController: _scrollController,
                                                      primary: false,
                                                      physics: const BouncingScrollPhysics(),
                                                      shrinkWrap: false,
                                                      cacheExtent: 240,
                                                      semanticChildCount: _controller.visible.length,
                                                      dragStartBehavior: DragStartBehavior.start,
                                                      keyboardDismissBehavior:
                                                          ScrollViewKeyboardDismissBehavior.onDrag,
                                                      restorationId: 'super-tree-scroll-demo',
                                                      clipBehavior: Clip.hardEdge,
                                                      hitTestBehavior: HitTestBehavior.opaque,
                                                      accent: accent,
                                                      title: 'Bounded scrolling tree',
                                                      subtitle:
                                                          'controller owns hierarchy state · scrollController owns scroll position',
                                                      titleIcon: Icons.swap_vert_circle_outlined,
                                                      nameColumnLabel: 'Item',
                                                      trailingColumnLabel: 'Index',
                                                      unit: 'items',
                                                      showArabic: false,
                                                      leadingBuilder: (context, node, info) => Icon(
                                                        Icons.view_list_outlined,
                                                        size: 16,
                                                        color: accent,
                                                      ),
                                                      trailingBuilder: (context, node, info) => Text(
                                                        '#${node.value!.index + 1}',
                                                        style: context.superTextTheme.mono.copyWith(
                                                          fontSize: 11.5,
                                                          color: t.fg3,
                                                        ),
                                                      ),
                                                    ),
                                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}
