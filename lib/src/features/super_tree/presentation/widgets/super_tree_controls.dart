// ============================================================
// features/super_tree/presentation/widgets/super_tree_controls.dart
// ------------------------------------------------------------
// Optional external controls for SuperTree. The SuperTree widget itself renders
// only the hierarchy; this reusable toolbar composes search, edit-mode, add,
// help, and expansion actions through SuperTreeController.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_form_field/super_form_field.dart';
import 'package:super_tree_field/super_tree.dart' hide FieldDensity;

/// Owns the search input used by [SuperTreeControls].
///
/// Keeping this controller outside [SuperTree] lets the host connect the tree's
/// `/` keyboard shortcut through [SuperTree.onSearchRequested].
class SuperTreeControlsController {
  /// Creates external controls with an optional initial [query].
  SuperTreeControlsController({String query = ''})
      : searchController = SuperTextFieldController(initialValue: query);

  /// Controller used by the external search field.
  final SuperTextFieldController searchController;

  /// Moves focus to the external search field.
  void requestSearchFocus() => searchController.focusNode.requestFocus();

  /// Releases the search field controller.
  void dispose() => searchController.dispose();
}

/// A responsive optional control bar composed outside [SuperTree].
///
/// The widget provides search, quick-query chips, optional editing actions,
/// keyboard-shortcut help, and expand/collapse actions. All behavior is
/// delegated to [SuperTreeController], so [SuperTree] remains focused on
/// rendering and interacting with the hierarchy itself.
///
/// Applications may use this control bar directly or compose their own UI
/// around the same controller APIs.
class SuperTreeControls<T> extends StatefulWidget {
  /// Creates a responsive control bar for [controller].
  const SuperTreeControls({
    super.key,
    required this.controller,
    required this.controlsController,
    this.placeholder = 'Search…   ( / )',
    this.samples = const [],
    this.accent,
    this.enableEditing = false,
    this.extra,
  });

  /// Hierarchy state controlled by this toolbar.
  final SuperTreeController<T> controller;

  /// Search and focus state used by this control bar.
  final SuperTreeControlsController controlsController;

  /// Hint shown in the external search field.
  final String placeholder;

  /// Quick-search values rendered as compact chips.
  final List<String> samples;

  /// Optional interaction accent.
  final Color? accent;

  /// Whether to expose edit-mode and add-node controls.
  final bool enableEditing;

  /// Optional content shown below the main responsive control row.
  final Widget? extra;

  @override
  State<SuperTreeControls<T>> createState() => _SuperTreeControlsState<T>();
}

class _SuperTreeControlsState<T> extends State<SuperTreeControls<T>> {
  SuperTreeController<T> get _tree => widget.controller;

  SuperTextFieldController get _search =>
      widget.controlsController.searchController;

  @override
  void initState() {
    super.initState();
    _tree.addListener(_syncQuery);
    _syncQuery();
  }

  @override
  void didUpdateWidget(covariant SuperTreeControls<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncQuery);
      widget.controller.addListener(_syncQuery);
      _syncQuery();
    }
  }

  @override
  void dispose() {
    _tree.removeListener(_syncQuery);
    super.dispose();
  }

  void _syncQuery() {
    if (_search.value != _tree.query) {
      _search.setValue(_tree.query);
    }
  }

  void _runQuery(String query) {
    _tree.setQuery(query);
    widget.controlsController.requestSearchFocus();
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.superTheme.spacing.space3;

    return AnimatedBuilder(
      animation: _tree,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;
            final searchWidth = compact
                ? constraints.maxWidth
                : (constraints.maxWidth * 0.42)
                    .clamp(300.0, 380.0)
                    .toDouble();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: searchWidth,
                      child: _SearchField<T>(
                        controller: _tree,
                        searchController: _search,
                        placeholder: widget.placeholder,
                        accent: widget.accent,
                      ),
                    ),
                    for (final query in widget.samples)
                      _SampleChip(
                        query: query,
                        selected: _tree.query == query,
                        accent: widget.accent,
                        onTap: () => _runQuery(query),
                      ),
                    if (widget.enableEditing) ...[
                      if (_tree.isEditable)
                        _ToolbarButton(
                          icon: Icons.add,
                          label: 'Add node',
                          accent: widget.accent,
                          emphasized: true,
                          onTap: _tree.addRoot,
                        ),
                      _ModeToggle<T>(
                        controller: _tree,
                        accent: widget.accent,
                      ),
                    ],
                    SuperIconButton(
                      icon: Icons.keyboard_outlined,
                      tooltip: 'Keyboard shortcuts  ·  ?',
                      onPressed: () => showShortcutsHelp(context),
                    ),
                    _ToolbarButton(
                      icon: Icons.expand_more,
                      label: 'Expand all',
                      accent: widget.accent,
                      onTap: _tree.expandAll,
                    ),
                    _ToolbarButton(
                      icon: Icons.expand_less,
                      label: 'Collapse',
                      accent: widget.accent,
                      onTap: _tree.collapseAll,
                    ),
                  ],
                ),
                if (widget.extra != null) ...[
                  SizedBox(height: gap),
                  widget.extra!,
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _SearchField<T> extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.searchController,
    required this.placeholder,
    this.accent,
  });

  final SuperTreeController<T> controller;
  final SuperTextFieldController searchController;
  final String placeholder;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent =
        accent ?? SuperMaterialThemeData.of(context).colorScheme.primary;

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          controller.clearQuery();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SuperTextFormField(
        controller: searchController,
        density: FieldDensity.compact,
        clearable: true,
        onChanged: controller.setQuery,
        cursorColor: effectiveAccent,
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip({
    required this.query,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final String query;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final effectiveAccent =
        accent ?? SuperMaterialThemeData.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  effectiveAccent.withValues(alpha: 0.18),
                  theme.surface,
                )
              : theme.inputBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? effectiveAccent : theme.border,
          ),
        ),
        child: Text(
          query,
          style: context.superTextTheme.mono.copyWith(
            fontSize: 11.5,
            height: 1.2,
            color: selected ? effectiveAccent : theme.fg2,
          ),
        ),
      ),
    );
  }
}

class _ModeToggle<T> extends StatelessWidget {
  const _ModeToggle({
    required this.controller,
    this.accent,
  });

  final SuperTreeController<T> controller;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final effectiveAccent =
        accent ?? SuperMaterialThemeData.of(context).colorScheme.primary;

    Widget segment(
      String label,
      IconData icon,
      SuperTreeMode mode,
    ) {
      final active = controller.mode == mode;
      return InkWell(
        borderRadius: BorderRadius.circular(
          context.superTheme.spacing.radiusControl - 2,
        ),
        onTap: () => controller.setMode(mode),
        child: AnimatedContainer(
          duration: SuperThemeData.of(context).tokens.durFast,
          height: context.superTheme.spacing.controlHeight - 6,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: active
                ? Color.alphaBlend(
                    effectiveAccent.withValues(alpha: 0.20),
                    theme.surface,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              context.superTheme.spacing.radiusControl - 2,
            ),
            border: Border.all(
              color: active ? effectiveAccent : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: active ? effectiveAccent : theme.fg3,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.superTextTheme.body.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active ? effectiveAccent : theme.fg3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: context.superTheme.spacing.controlHeight,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.inputBg,
        borderRadius: BorderRadius.circular(
          context.superTheme.spacing.radiusControl,
        ),
        border: Border.all(color: theme.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment('Read', Icons.visibility_outlined, SuperTreeMode.readable),
          const SizedBox(width: 3),
          segment('Edit', Icons.edit_outlined, SuperTreeMode.editable),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accent;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final effectiveAccent =
        accent ?? SuperMaterialThemeData.of(context).colorScheme.primary;
    final foreground = emphasized ? effectiveAccent : theme.fg2;

    return InkWell(
      borderRadius: BorderRadius.circular(
        context.superTheme.spacing.radiusControl,
      ),
      onTap: onTap,
      child: Container(
        height: context.superTheme.spacing.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: emphasized
              ? Color.alphaBlend(
                  effectiveAccent.withValues(alpha: 0.10),
                  theme.surface,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            context.superTheme.spacing.radiusControl,
          ),
          border: Border.all(
            color: emphasized
                ? effectiveAccent.withValues(alpha: 0.5)
                : theme.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 7),
            Text(
              label,
              style: context.superTextTheme.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
