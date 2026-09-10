# Migration guide: 1.0.1 → 2.0.0

This guide covers the consumer-facing changes required to migrate
`super_tree_field` from **1.0.1** to **2.0.0**.

Version 2.0.0 narrows `SuperTree<T>` to the hierarchy itself: recursive node
rendering, navigation, expansion, selection, editing, drag/drop, scrolling, and
node context menus. Page-level presentation such as titles, column headings,
totals, selection summaries, and cards now belongs to the host application.

It also adds package localization and a reusable recursive context-menu API.

## 1. Update the dependency

Update the package version in `pubspec.yaml`:

```yaml
dependencies:
  super_tree_field: ^2.0.0
```

Then use your normal project dependency workflow.

## 2. Remove presentation arguments from `SuperTree`

The following `SuperTree` parameters are removed in 2.0.0:

- `title`
- `subtitle`
- `titleIcon`
- `nameColumnLabel`
- `trailingColumnLabel`
- `selectionLabel`
- `localizeDefaultText`
- `unit`

These properties represented page/card presentation rather than tree
behavior.

### Before

```dart
SuperTree<FileInfo>(
  controller: controller,
  title: 'Workspace',
  subtitle: 'Project files',
  titleIcon: Icons.account_tree_outlined,
  nameColumnLabel: 'Name',
  trailingColumnLabel: 'Size',
  selectionLabel: 'Selected',
  unit: 'items',
  localizeDefaultText: true,
  leadingBuilder: buildLeading,
  trailingBuilder: buildTrailing,
)
```

### After

Compose the presentation outside `SuperTree`:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Row(
      children: [
        const Icon(Icons.account_tree_outlined),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Workspace'),
              Text('Project files'),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 12),
    const Row(
      children: [
        Expanded(child: Text('Name')),
        Text('Size'),
      ],
    ),
    const SizedBox(height: 8),
    SuperTree<FileInfo>(
      controller: controller,
      leadingBuilder: buildLeading,
      trailingBuilder: buildTrailing,
    ),
  ],
)
```

Use `Card`, `Container`, `DecoratedBox`, or your own design-system surface
outside `SuperTree` when a card presentation is needed.

## 3. Move totals and selection summaries to the host

The built-in tree header/footer summaries were removed. The controller already
exposes the state needed to compose them externally.

Useful values include:

```dart
controller.totalLeaves
controller.visibleLeaves
controller.matchCount
controller.checkedCount
controller.checked
controller.checkedNodes
controller.selected
controller.rootCheckState
```

Because `SuperTreeController<T>` extends `ChangeNotifier`, host presentation can
listen to it directly:

```dart
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return Text(
      '${controller.checkedCount} selected '
      'of ${controller.totalLeaves}',
    );
  },
)
```

If the old header select-all control was used, compose it in the host and call:

```dart
controller.toggleCheckAll();
```

Other selection operations remain available:

```dart
controller.checkAll();
controller.clearChecked();
controller.setChecked(codes);
```

## 4. Keep optional controls outside the tree

`SuperTreeControls<T>` remains a separate optional widget. It is not rendered
inside `SuperTree`.

```dart
Column(
  children: [
    SuperTreeControls<FileInfo>(
      controller: controller,
      controlsController: controlsController,
    ),
    const SizedBox(height: 8),
    Expanded(
      child: SuperTree<FileInfo>(
        controller: controller,
        leadingBuilder: buildLeading,
      ),
    ),
  ],
)
```

If your application has its own toolbar, you can omit `SuperTreeControls`
completely and drive `SuperTreeController<T>` directly.

## 5. Configure package localization

Version 2.0.0 moves package-owned user-visible text into `lib/localization` and
ships English and Arabic localizations.

Register the package localization delegates in the host application:

```dart
MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    ...SuperTreeLocalization.localizationsDelegates,
    SuperFormTranslation.delegate,
  ],
  supportedLocales: SuperTreeLocalization.supportedLocales,
  home: const MyHomePage(),
)
```

Package-owned text includes tree empty/search states, editing text, built-in
context-menu actions, and default external-control labels.

For custom package-aware UI, access localization through:

```dart
final l10n = context.superTreeLocalization;

Text(l10n.expandAll);
```

### `localizeDefaultText` moved out of `SuperTree`

`SuperTree.localizeDefaultText` no longer exists.

If legacy English labels are required for the optional external controls, use:

```dart
SuperTreeControls<FileInfo>(
  controller: controller,
  controlsController: controlsController,
  localizeDefaultText: false,
)
```

Do not use a localization switch on `SuperTree`. Tree-owned package strings
follow the active locale automatically.

Custom labels supplied by the host remain host-owned and are not silently
translated.

## 6. Context menus are reusable in 2.0.0

Version 2.0.0 exposes reusable context-menu primitives:

```dart
TreeContextMenuItem
TreeContextMenuAction
TreeContextMenuItemsBuilder<T>
TreeContextMenuStyle
TreeContextMenuConfig
TreeContextMenuNodeContext<T>
TreeContextMenuConfigBuilder<T>
buildDefaultTreeContextMenuItems<T>()
showTreeContextMenu<T>()
```

If the default menu is sufficient, no migration is required:

```dart
SuperTree<FileInfo>(
  controller: controller,
  leadingBuilder: buildLeading,
)
```

Disable all node context menus with:

```dart
SuperTree<FileInfo>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuEnabled: false,
)
```

## 7. Replace or extend context-menu items

Use `contextMenuItemsBuilder` for straightforward per-node item customization.

### Replace the menu

```dart
SuperTree<FileInfo>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuItemsBuilder: (context, controller, node) {
    return [
      TreeContextMenuItem(
        id: 'open',
        label: 'Open',
        leading: const Icon(Icons.open_in_new),
        onTap: () => openNode(node),
      ),
    ];
  },
)
```

### Extend package defaults

Use stable `TreeContextMenuAction` IDs rather than localized label text:

```dart
contextMenuItemsBuilder: (context, controller, node) {
  final defaults = buildDefaultTreeContextMenuItems<FileInfo>(
    context: context,
    controller: controller,
    node: node,
  );

  return [
    ...defaults.where(
      (item) => item.id != TreeContextMenuAction.delete,
    ),
    TreeContextMenuItem(
      id: 'audit',
      label: 'Audit history',
      leading: const Icon(Icons.history_outlined),
      dividerAbove: true,
      onTap: () => openAudit(node),
    ),
  ];
},
```

## 8. Use nested context menus

`TreeContextMenuItem.children` creates recursive cascading submenus.

```dart
contextMenuItemsBuilder: (context, controller, node) => [
  TreeContextMenuItem(
    id: 'create',
    label: 'Create',
    leading: const Icon(Icons.add_rounded),
    children: [
      TreeContextMenuItem(
        id: 'child',
        label: 'Child',
        onTap: () => createChild(node),
      ),
      TreeContextMenuItem(
        id: 'advanced',
        label: 'Advanced',
        children: [
          TreeContextMenuItem(
            id: 'template',
            label: 'From template',
            onTap: () => createFromTemplate(node),
          ),
        ],
      ),
    ],
  ),
],
```

Branches open a submenu. Enabled leaf items execute `onTap`.

The built-in editable menu now groups creation commands under a localized
nested **Add** branch.

Nested menus automatically account for LTR/RTL direction, viewport boundaries,
and available space.

## 9. Configure a different menu for every node

Use `contextMenuConfigBuilder` when each node may need a different combination
of items, styling, accent color, or enabled state.

```dart
SuperTree<FileInfo>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuConfigBuilder: (menu) {
    final node = menu.node;

    if (node.code == 'protected') {
      return const TreeContextMenuConfig.disabled();
    }

    if (node.hasChildren) {
      return TreeContextMenuConfig(
        style: const TreeContextMenuStyle(width: 300),
        items: [
          ...menu.baseItems,
          TreeContextMenuItem(
            id: 'folder-tools',
            label: 'Folder tools',
            children: [
              TreeContextMenuItem(
                id: 'inspect',
                label: 'Inspect',
                onTap: () => inspectFolder(node),
              ),
            ],
          ),
        ],
      );
    }

    return const TreeContextMenuConfig();
  },
)
```

The builder receives `TreeContextMenuNodeContext<T>`.

Important values are:

```dart
menu.context
menu.controller
menu.node
menu.packageDefaultItems
menu.baseItems
menu.defaultStyle
menu.defaultAccent
```

`menu.packageDefaultItems` always contains the package-generated localized
defaults.

`menu.baseItems` contains the effective menu before
`contextMenuConfigBuilder` is applied. If `contextMenuItemsBuilder` is also
provided, its result becomes `menu.baseItems`.

This allows both APIs to be composed without breaking existing customization.

## 10. Customize menu appearance

Use `contextMenuStyle` for a tree-wide style:

```dart
SuperTree<FileInfo>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuStyle: const TreeContextMenuStyle(
    width: 280,
  ),
)
```

Use `TreeContextMenuConfig.style` for a node-specific override.

The 2.0.0 menu implementation is content-sized rather than expanding to the
available overlay size. Recursive submenus are rendered above the root dismiss
barrier and automatically choose an appropriate side based on text direction
and viewport space.

## 11. Standalone context-menu usage

The menu surface can also be used without `SuperTree`:

```dart
await showTreeContextMenu<void>(
  context: context,
  globalPosition: position,
  items: [
    TreeContextMenuItem(
      id: 'copy',
      label: 'Copy',
      leading: const Icon(Icons.copy_outlined),
      onTap: copy,
    ),
  ],
);
```

Explicit standalone items support the same recursive `children` structure.

## 12. Review custom node creation

Built-in editing actions now use localized fallback names for newly created
nodes when no custom `newNodeBuilder` is provided.

If the application requires domain-specific node creation, continue supplying a
custom builder to `SuperTreeController<T>`:

```dart
final controller = SuperTreeController<FileInfo>(
  roots: roots,
  searchText: searchText,
  newNodeBuilder: (code) => TreeNode<FileInfo>(
    code: code,
    name: 'Untitled file',
    value: const FileInfo(isDirectory: false),
  ),
);
```

Host-provided values remain unchanged by package localization.

## Migration checklist

After upgrading to 2.0.0, verify that:

- all removed `SuperTree` arguments have been deleted;
- titles, subtitles, column headings, totals, selection summaries, and card
  decoration are composed outside the tree;
- `unit` is no longer passed to `SuperTree`;
- any old `SuperTree.localizeDefaultText` usage is removed;
- `SuperTreeControls.localizeDefaultText` is used only when fixed legacy control
  labels are intentionally required;
- `SuperTreeLocalization` delegates and supported locales are registered;
- custom context-menu filtering uses `TreeContextMenuAction` IDs rather than
  translated labels;
- per-node menu differences use `contextMenuConfigBuilder` when appropriate;
- nested custom menu branches use `TreeContextMenuItem.children`;
- application-specific labels remain localized by the host application.

## Minimal migrated example

```dart
class FileTreeView extends StatefulWidget {
  const FileTreeView({super.key});

  @override
  State<FileTreeView> createState() => _FileTreeViewState();
}

class _FileTreeViewState extends State<FileTreeView> {
  late final SuperTreeController<FileInfo> controller;

  @override
  void initState() {
    super.initState();

    controller = SuperTreeController<FileInfo>(
      roots: buildRoots(),
      searchText: (node) => '${node.code} ${node.name} ${node.ar ?? ''}',
      selectionMode: SuperTreeSelectionMode.multi,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Workspace'),
            const SizedBox(height: 12),
            Expanded(
              child: SuperTree<FileInfo>(
                controller: controller,
                leadingBuilder: buildLeading,
                trailingBuilder: buildTrailing,
                contextMenuConfigBuilder: (menu) {
                  if (menu.node.code == 'protected') {
                    return const TreeContextMenuConfig.disabled();
                  }

                  return const TreeContextMenuConfig();
                },
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Text(
                  '${controller.checkedCount} selected',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

The key migration principle in 2.0.0 is that `SuperTree<T>` owns the hierarchy
and node interaction, while the host application owns surrounding
presentation.
