// ============================================================
// example/lib/tree_context_menu_demo.dart
// ------------------------------------------------------------
// Context-menu scenario gallery. Demonstrates recursive nested menus,
// standalone usage, package defaults, editable actions, replacement,
// extension, filtering, styling, disabled entries, and disabling menus.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_tree_field/super_tree.dart';

import 'responsive_example_layout.dart';

import 'localization/localizations.dart';
import 'widgets/demo_kit.dart';
import 'usage_sources.dart';
/// Demonstrates the reusable and customizable tree context-menu APIs.
class TreeContextMenuDemo extends StatefulWidget {
  /// Creates the context-menu scenario gallery.
  const TreeContextMenuDemo({super.key});

  @override
  State<TreeContextMenuDemo> createState() => _TreeContextMenuDemoState();
}

class _TreeContextMenuDemoState extends State<TreeContextMenuDemo> {
  final GlobalKey _standaloneButtonKey = GlobalKey();
  late final SuperTreeController<String> _readable;
  late final SuperTreeController<String> _editable;
  late final SuperTreeController<String> _replaced;
  late final SuperTreeController<String> _extended;
  late final SuperTreeController<String> _filtered;
  late final SuperTreeController<String> _perNode;
  late final SuperTreeController<String> _styled;
  late final SuperTreeController<String> _disabled;

  @override
  void initState() {
    super.initState();
    _readable = _controller();
    _editable = _controller(mode: SuperTreeMode.editable);
    _replaced = _controller();
    _extended = _controller(mode: SuperTreeMode.editable);
    _filtered = _controller(mode: SuperTreeMode.editable);
    _perNode = _controller(mode: SuperTreeMode.editable);
    _styled = _controller();
    _disabled = _controller();
  }

  SuperTreeController<String> _controller({
    SuperTreeMode mode = SuperTreeMode.readable,
  }) => SuperTreeController<String>(
    roots: _roots(),
    mode: mode,
    defaultExpandDepth: 2,
    searchText: (node) => '${node.code} ${node.name}',
    onOpenLeaf: (node) {
      if (!mounted) return;
      _message('Opened ${node.name}');
    },
  );

  static List<TreeNode<String>> _roots() => const [
    TreeNode<String>(
      code: 'workspace',
      name: 'Workspace',
      value: 'folder',
      children: [
        TreeNode<String>(
          code: 'workspace/src',
          name: 'src',
          value: 'folder',
          children: [
            TreeNode<String>(
              code: 'workspace/src/main.dart',
              name: 'main.dart',
              value: 'file',
            ),
            TreeNode<String>(
              code: 'workspace/src/app.dart',
              name: 'app.dart',
              value: 'file',
            ),
          ],
        ),
        TreeNode<String>(
          code: 'workspace/readme',
          name: 'README.md',
          value: 'file',
        ),
      ],
    ),
  ];

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showStandaloneMenu() async {
    final buttonContext = _standaloneButtonKey.currentContext;
    final box = buttonContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final anchor = box.localToGlobal(Offset(0, box.size.height + 4));
    await showTreeContextMenu<void>(
      context: context,
      globalPosition: anchor,
      items: [
        TreeContextMenuItem(
          id: 'create',
          leading: const Icon(Icons.add_rounded),
          label: 'Create',
          children: [
            TreeContextMenuItem(
              id: 'folder',
              leading: const Icon(Icons.folder_outlined),
              label: 'Folder',
              onTap: () => _message('Standalone: Create folder'),
            ),
            TreeContextMenuItem(
              id: 'file',
              leading: const Icon(Icons.insert_drive_file_outlined),
              label: 'File',
              onTap: () => _message('Standalone: Create file'),
            ),
            TreeContextMenuItem(
              id: 'more',
              leading: const Icon(Icons.more_horiz),
              label: 'More',
              dividerAbove: true,
              children: [
                TreeContextMenuItem(
                  id: 'shortcut',
                  leading: const Icon(Icons.link_outlined),
                  label: 'Shortcut',
                  onTap: () => _message('Standalone: Create shortcut'),
                ),
                TreeContextMenuItem(
                  id: 'template',
                  leading: const Icon(Icons.description_outlined),
                  label: 'From template',
                  onTap: () => _message('Standalone: Create from template'),
                ),
              ],
            ),
          ],
        ),
        TreeContextMenuItem(
          id: 'duplicate',
          leading: const Icon(Icons.copy_outlined),
          label: 'Duplicate',
          onTap: () => _message('Standalone: Duplicate'),
        ),
        TreeContextMenuItem(
          id: 'share',
          leading: const Icon(Icons.ios_share_outlined),
          label: 'Share',
          trailing: const Text('⌘S'),
          onTap: () => _message('Standalone: Share'),
        ),
        const TreeContextMenuItem(
          id: 'archived',
          leading: Icon(Icons.archive_outlined),
          label: 'Archived action',
          enabled: false,
          dividerAbove: true,
        ),
        TreeContextMenuItem(
          id: 'remove',
          leading: const Icon(Icons.delete_outline),
          label: 'Remove',
          danger: true,
          onTap: () => _message('Standalone: Remove'),
        ),
      ],
      style: const TreeContextMenuStyle(width: 280),
    );
  }

  @override
  void dispose() {
    _readable.dispose();
    _editable.dispose();
    _replaced.dispose();
    _extended.dispose();
    _filtered.dispose();
    _perNode.dispose();
    _styled.dispose();
    _disabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;

    return DemoScaffold(
      title: context.exampleLocalization.contextMenuDemoTitle,
      subtitle: context.exampleLocalization.contextMenuDemoSubtitle,
      usageCode: ExampleUsageSources.contextMenus,
      body: ResponsiveExampleLayout(
        maxWidth: 1050,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Right-click a row on desktop or long-press it on touch devices. '
              'Editable trees also expose the row menu button.',
              style: context.superTextTheme.body.copyWith(color: t.fg2),
            ),
            SizedBox(height: context.superTheme.spacing.space5),
            _ScenarioCard(
              title: '1. Standalone reusable menu',
              description:
                  'Explicit items can contain recursive children. Hover or tap Create, then open More for a third menu level.',
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SuperButton(
                  key: _standaloneButtonKey,
                  label: 'Open standalone menu',
                  variant: SuperButtonVariant.secondary,
                  onPressed: _showStandaloneMenu,
                ),
              ),
            ),
            _gap(context),
            _ScenarioCard(
              title: '2. ${context.exampleLocalization.defaultReadOnlyMenu}',
              description:
                  'Uses localized Open / Expand / Collapse / Expand subtree actions.',
              child: _tree(_readable,),
            ),
            _gap(context),
            _ScenarioCard(
              title: '3. ${context.exampleLocalization.defaultEditableMenu}',
              description:
                  'Uses Rename, Add child, sibling actions, and Delete from the package defaults.',
              child: _tree(_editable,),
            ),
            _gap(context),
            _ScenarioCard(
              title: '4. Replace all default items',
              description:
                  'contextMenuItemsBuilder can fully replace the built-in actions for each node.',
              child: _tree(
                _replaced,
                contextMenuItemsBuilder: (context, controller, node) => [
                  TreeContextMenuItem(
                    id: 'inspect',
                    leading: const Icon(Icons.info_outline),
                    label: 'Inspect ${node.name}',
                    onTap: () => _message('Inspect ${node.code}'),
                  ),
                  TreeContextMenuItem(
                    id: 'copy-code',
                    leading: const Icon(Icons.tag),
                    label: 'Copy node code',
                    trailing: Text(node.code),
                    onTap: () => _message('Code: ${node.code}'),
                  ),
                ],
              ),
            ),
            _gap(context),
            _ScenarioCard(
              title: '5. Extend package defaults',
              description:
                  'Build the defaults first, then append domain-specific actions.',
              child: _tree(
                _extended,
                contextMenuItemsBuilder: (context, controller, node) => [
                  ...buildDefaultTreeContextMenuItems<String>(
                    context: context,
                    controller: controller,
                    node: node,
                  ),
                  TreeContextMenuItem(
                    id: 'audit',
                    leading: const Icon(Icons.history_outlined),
                    label: 'View audit history',
                    dividerAbove: true,
                    onTap: () => _message('Audit history: ${node.name}'),
                  ),
                ],
              ),
            ),
            _gap(context),
            _ScenarioCard(
              title: '6. Filter package defaults by stable action ID',
              description:
                  'This example hides Delete for the root while preserving the rest of the localized defaults.',
              child: _tree(
                _filtered,
                contextMenuItemsBuilder: (context, controller, node) {
                  final defaults = buildDefaultTreeContextMenuItems<String>(
                    context: context,
                    controller: controller,
                    node: node,
                  );
                  if (node.code != 'workspace') return defaults;
                  return defaults
                      .where((item) => item.id != TreeContextMenuAction.delete)
                      .toList(growable: false);
                },
              ),
            ),

            _gap(context),
            _ScenarioCard(
              title: '7. ${context.exampleLocalization.flexibleMenuPerNode}',
              description:
                  'contextMenuConfigBuilder can independently configure every TreeNode.',
              child: _tree(
                _perNode,
                contextMenuConfigBuilder: (menu) {
                  final node = menu.node;

                  if (node.code == 'workspace/readme') {
                    return const TreeContextMenuConfig.disabled();
                  }

                  if (node.code == 'workspace') {
                    return TreeContextMenuConfig(
                      style: const TreeContextMenuStyle(width: 310),
                      items: [
                        ...menu.baseItems.where(
                          (item) =>
                              item.id != TreeContextMenuAction.delete,
                        ),
                        TreeContextMenuItem(
                          id: 'workspace-settings',
                          leading: const Icon(Icons.settings_outlined),
                          label: 'Workspace settings',
                          dividerAbove: true,
                          onTap: () => _message('Workspace settings'),
                        ),
                      ],
                    );
                  }

                  if (node.value == 'folder') {
                    return TreeContextMenuConfig(
                      items: [
                        TreeContextMenuItem(
                          id: 'open-folder',
                          leading: const Icon(Icons.folder_open_outlined),
                          label: 'Open ${node.name}',
                          onTap: () =>
                              _message('Open folder ${node.code}'),
                        ),
                        TreeContextMenuItem(
                          id: 'create-in-folder',
                          leading:
                              const Icon(Icons.create_new_folder_outlined),
                          label: 'Create in folder',
                          children: [
                            TreeContextMenuItem(
                              id: 'new-file',
                              leading: const Icon(Icons.note_add_outlined),
                              label: 'New file',
                              onTap: () =>
                                  _message('New file in ${node.name}'),
                            ),
                            TreeContextMenuItem(
                              id: 'new-folder',
                              leading: const Icon(
                                Icons.create_new_folder_outlined,
                              ),
                              label: 'New folder',
                              onTap: () =>
                                  _message('New folder in ${node.name}'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  if (node.name.endsWith('.dart')) {
                    final rename = menu.packageDefaultItems.where(
                      (item) =>
                          item.id == TreeContextMenuAction.rename,
                    );

                    return TreeContextMenuConfig(
                      items: [
                        ...rename,
                        TreeContextMenuItem(
                          id: 'analyze-dart',
                          leading: const Icon(Icons.analytics_outlined),
                          label: 'Analyze Dart file',
                          onTap: () =>
                              _message('Analyze ${node.name}'),
                        ),
                        TreeContextMenuItem(
                          id: 'refactor',
                          leading:
                              const Icon(Icons.account_tree_outlined),
                          label: 'Refactor',
                          children: [
                            TreeContextMenuItem(
                              id: 'extract-widget',
                              label: 'Extract widget',
                              onTap: () =>
                                  _message('Extract from ${node.name}'),
                            ),
                            TreeContextMenuItem(
                              id: 'rename-symbol',
                              label: 'Rename symbol',
                              onTap: () =>
                                  _message('Rename in ${node.name}'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return const TreeContextMenuConfig();
                },
              ),
            ),
            _gap(context),
            _ScenarioCard(
              title: '8. ${context.exampleLocalization.styleCustomization}',
              description:
                  'TreeContextMenuStyle controls menu width, spacing, radius, outline, shadow and colors.',
              child: _tree(
                _styled,
                contextMenuStyle: const TreeContextMenuStyle(
                  width: 320,
                  menuPadding: EdgeInsets.symmetric(vertical: 9),
                  itemMargin: EdgeInsets.symmetric(horizontal: 8),
                  itemPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  itemRadius: 10,
                  borderWidth: 1.5,
                ),
              ),
            ),
            _gap(context),
            _ScenarioCard(
              title: '9. ${context.exampleLocalization.disableContextMenus}',
              description:
                  'Set contextMenuEnabled to false when the host owns all row interaction.',
              child: _tree(
                _disabled,
                contextMenuEnabled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tree(
    SuperTreeController<String> controller, {
    bool contextMenuEnabled = true,
    TreeContextMenuItemsBuilder<String>? contextMenuItemsBuilder,
    TreeContextMenuConfigBuilder<String>? contextMenuConfigBuilder,
    TreeContextMenuStyle contextMenuStyle = const TreeContextMenuStyle(),
  }) => SuperTree<String>(
    controller: controller,
    showArabic: false,
    showLeafCount: true,
    contextMenuEnabled: contextMenuEnabled,
    contextMenuItemsBuilder: contextMenuItemsBuilder,
    contextMenuConfigBuilder: contextMenuConfigBuilder,
    contextMenuStyle: contextMenuStyle,
    leadingBuilder: (context, node, info) => Icon(
      info.hasChildren ? Icons.folder_outlined : Icons.description_outlined,
      size: 16,
      color: context.superTheme.fg3,
    ),
    trailingBuilder: (context, node, info) => Text(
      node.code,
      style: context.superTextTheme.mono.copyWith(
        fontSize: 10.5,
        color: context.superTheme.fg4,
      ),
    ),
  );

  static Widget _gap(BuildContext context) =>
      SizedBox(height: context.superTheme.spacing.space4);
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Container(
      padding: EdgeInsets.all(context.superTheme.spacing.space4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(
          context.superTheme.spacing.radiusCard,
        ),
        border: Border.all(color: t.border),
        boxShadow: t.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.superTextTheme.heading.copyWith(color: t.fg1),
          ),
          SizedBox(height: context.superTheme.spacing.space1),
          Text(
            description,
            style: context.superTextTheme.caption.copyWith(color: t.fg3),
          ),
          SizedBox(height: context.superTheme.spacing.space4),
          child,
        ],
      ),
    );
  }
}
