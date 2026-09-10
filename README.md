# super_tree_field

A recursive, generic, keyboard-first hierarchy component for Flutter with search, selection, editing, drag/drop, scrolling, localization, and reusable nested context menus.

Current version: **2.0.0**

`super_tree_field` provides a typed hierarchy model, pure tree algorithms,
controller-owned interaction state, a recursive `SuperTree<T>` view, reusable
rows and controls, selection, editing, drag/drop, localization, and nested
context menus.

`SuperTree<T>` is intentionally focused on the hierarchy and its nodes.
Titles, subtitles, column headings, totals, cards, toolbars, and other
screen-level presentation belong to the host application.

## Features

- Generic `TreeNode<T>` payloads.
- Recursive hierarchy rendering.
- Expand/collapse and subtree expansion.
- Keyboard-first navigation and focus.
- Automatic scrolling to keep the focused node visible.
- Search filtering and matched-text highlighting.
- None, single, and multi selection modes.
- Tri-state group selection.
- Readable and editable modes.
- Inline rename and node insertion/deletion.
- Drag-and-drop reordering.
- Optional external `SuperTreeControls<T>`.
- Reusable standalone context menus.
- Recursive nested context menus.
- Per-node menu items, style, accent, and enabled state.
- LTR/RTL-aware menu placement.
- English and Arabic package localization.
- Configurable Flutter scroll behavior.
- `super_core` design-system integration.

## Getting started

Add the package:

```yaml
dependencies:
  super_tree_field: ^2.0.0
```

Import the public barrel:

```dart
import 'package:super_tree_field/super_tree.dart';
```

## Quick start

```dart
class FileMeta {
  const FileMeta({
    required this.isDirectory,
    this.size,
  });

  final bool isDirectory;
  final int? size;
}

final roots = <TreeNode<FileMeta>>[
  TreeNode<FileMeta>(
    code: 'lib',
    name: 'lib',
    value: const FileMeta(isDirectory: true),
    children: const [
      TreeNode<FileMeta>(
        code: 'lib/main.dart',
        name: 'main.dart',
        value: FileMeta(
          isDirectory: false,
          size: 2048,
        ),
      ),
    ],
  ),
];

final controller = SuperTreeController<FileMeta>(
  roots: roots,
  searchText: (node) =>
      '${node.code} ${node.name} ${node.ar ?? ''}',
  defaultExpandDepth: 1,
  onOpenLeaf: (node) {
    // Open the selected item.
  },
);

SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: (context, node, info) {
    return Icon(
      node.hasChildren
          ? Icons.folder_outlined
          : Icons.insert_drive_file_outlined,
    );
  },
  trailingBuilder: (context, node, info) {
    final size = node.value?.size;
    return size == null ? null : Text('$size B');
  },
);
```

Dispose controllers owned by the host widget:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

## Public API

| Component | Purpose |
| --- | --- |
| `TreeNode<T>` | Immutable generic hierarchy node. |
| `TreeLogic` | Pure tree algorithms and immutable transforms. |
| `DropPosition` | Before/inside/after drag target position. |
| `SearchText<T>` | Node search-text extractor. |
| `LeafValue<T>` | Numeric leaf extractor for rollups. |
| `SuperTreeController<T>` | Expansion, search, focus, selection, and editing state. |
| `SuperTreeMode` | Readable or editable mode. |
| `SuperTreeSelectionMode` | None, single, or multi selection. |
| `TreeCheckState` | Unchecked, partial, or checked state. |
| `SuperTree<T>` | Main hierarchy viewport. |
| `TreeRow<T>` | Reusable recursive row. |
| `TreeRowInfo` | Depth/open/children metadata supplied to builders. |
| `TreeSlotBuilder<T>` | Leading-cell builder. |
| `TreeTrailingBuilder<T>` | Trailing-content builder. |
| `TreeCheckbox` | Standalone tri-state tree checkbox. |
| `HighlightText` | Search-match highlighting widget. |
| `SuperTreeControlsController` | Search state for external controls. |
| `SuperTreeControls<T>` | Optional search/edit/help/expand toolbar. |
| `TreeContextMenuAction` | Stable IDs for built-in menu actions. |
| `TreeContextMenuItem` | Reusable menu leaf or submenu branch. |
| `TreeContextMenuItemsBuilder<T>` | Per-node menu-items builder. |
| `TreeContextMenuStyle` | Menu geometry and visual configuration. |
| `TreeContextMenuNodeContext<T>` | Full node context for menu policy. |
| `TreeContextMenuConfig` | Per-node menu overrides. |
| `TreeContextMenuConfigBuilder<T>` | Complete per-node menu configurator. |
| `buildDefaultTreeContextMenuItems()` | Builds localized package-default actions. |
| `showTreeContextMenu()` | Opens a tree-aware or standalone menu. |
| `showShortcutsHelp()` | Opens the keyboard-shortcuts dialog. |
| `SuperTreeLocalization` | Package localization API. |
| `lookupSuperTreeLocalization()` | Resolves package localization for an explicit locale. |
| `SuperTreeLocalizationBuildContext` | Localization convenience extension. |

## TreeNode<T>

`TreeNode<T>` is the immutable hierarchy entity. `code` must be unique across
the tree.

```dart
const node = TreeNode<double>(
  code: 'assets/cash',
  name: 'Cash',
  ar: 'النقدية',
  value: 12500,
);

final renamed = node.renamed(
  'Cash and equivalents',
  ar: 'النقد وما في حكمه',
);

final branch = TreeNode<String>(
  code: 'settings',
  name: 'Settings',
  children: const [
    TreeNode<String>(
      code: 'settings/profile',
      name: 'Profile',
      value: 'profile',
    ),
  ],
);

print(branch.hasChildren);
print(branch.isLeaf);
```

Use `copyWith()` and `withChildren()` for immutable transforms.

## TreeLogic

`TreeLogic` is widget-free and can be used independently.

```dart
final count = TreeLogic.leafCount(branch);
final leafCodes = TreeLogic.leafCodes(branch);

final groups = TreeLogic.groupCodes(
  roots,
  maxDepth: 2,
);

final filtered = TreeLogic.filter(
  roots,
  'main',
  (node) => '${node.code} ${node.name}',
);

final visible = TreeLogic.flattenVisible(
  roots,
  {'lib', 'lib/src'},
  false,
);

final parent = TreeLogic.parentOf(
  roots,
  'lib/main.dart',
);

final found = TreeLogic.findNode(
  roots,
  'lib/main.dart',
);
```

Numeric rollup:

```dart
LeafValue<double> leafValue =
    (node) => node.value ?? 0;

final total = TreeLogic.rollup<double>(
  accountRoot,
  leafValue,
);
```

Immutable editing:

```dart
final renamedRoots = TreeLogic.mapNode(
  roots,
  'lib/main.dart',
  (node) => node.renamed('app.dart'),
);

final withoutNode = TreeLogic.removeNode(
  roots,
  'lib/old.dart',
);

final withChild = TreeLogic.insertChild(
  roots,
  'lib',
  newNode,
);

final withSibling = TreeLogic.insertSibling(
  roots,
  'lib/main.dart',
  newNode,
  after: true,
);

final moved = TreeLogic.moveNode(
  roots,
  'lib/a.dart',
  'lib/b.dart',
  DropPosition.after,
);
```

### DropPosition

```dart
const drop = DropPosition.inside;

switch (drop) {
  case DropPosition.before:
    break;
  case DropPosition.inside:
    break;
  case DropPosition.after:
    break;
}
```

### SearchText<T>

```dart
SearchText<FileMeta> searchText =
    (node) => '${node.code} ${node.name}';
```

### LeafValue<T>

```dart
LeafValue<double> amount =
    (node) => node.value ?? 0;
```

## SuperTreeController<T>

```dart
final controller = SuperTreeController<FileMeta>(
  roots: roots,
  searchText: (node) => '${node.code} ${node.name}',
  mode: SuperTreeMode.editable,
  selectionMode: SuperTreeSelectionMode.multi,
  initialChecked: {'lib/main.dart'},
  onOpenLeaf: (node) => openFile(node),
  onTreeChanged: (newRoots) => saveTree(newRoots),
  onSelectionChanged: (checked) {
    debugPrint('$checked');
  },
  newNodeBuilder: (code) => TreeNode<FileMeta>(
    code: code,
    name: 'Untitled',
    value: const FileMeta(isDirectory: false),
  ),
);
```

Expansion and search:

```dart
controller.toggle('lib');
controller.expandSubtree('lib');
controller.expandAll();
controller.collapseAll();

controller.setQuery('main');
controller.clearQuery();

print(controller.visible);
print(controller.matchCount);
print(controller.totalLeaves);
print(controller.visibleLeaves);
```

Focus and activation:

```dart
controller.setFocus('lib/main.dart');
controller.moveDown();
controller.moveUp();
controller.jumpFirst();
controller.jumpLast();
controller.stepInto();
controller.stepOut();
controller.activate();
```

Selection:

```dart
controller.toggleChecked(node);
controller.toggleCheckedFocused();
controller.checkAll();
controller.clearChecked();
controller.toggleCheckAll();

controller.setChecked({
  'lib/main.dart',
  'lib/app.dart',
});

final checked = controller.checked;
final nodes = controller.checkedNodes;
final state = controller.checkState('lib');
```

Editing:

```dart
controller.setMode(SuperTreeMode.editable);

controller.beginRename('lib/main.dart');
controller.commitRename(
  'lib/main.dart',
  'app.dart',
);

controller.addChild('lib');
controller.addSiblingBefore('lib/main.dart');
controller.addSiblingAfter('lib/main.dart');
controller.addRoot();

controller.deleteNode('lib/old.dart');

if (controller.canDrop(
  'lib/a.dart',
  'lib/b.dart',
)) {
  controller.moveNode(
    'lib/a.dart',
    'lib/b.dart',
    DropPosition.after,
  );
}
```

## SuperTreeMode

```dart
controller.setMode(SuperTreeMode.readable);
controller.setMode(SuperTreeMode.editable);
controller.toggleMode();
```

## SuperTreeSelectionMode

```dart
final controller = SuperTreeController<String>(
  roots: roots,
  searchText: (node) => node.name,
  selectionMode: SuperTreeSelectionMode.multi,
);
```

Available values:

```dart
SuperTreeSelectionMode.none
SuperTreeSelectionMode.single
SuperTreeSelectionMode.multi
```

## TreeCheckState

```dart
final state = controller.checkState(node.code);

final icon = switch (state) {
  TreeCheckState.unchecked =>
    Icons.check_box_outline_blank,
  TreeCheckState.partial =>
    Icons.indeterminate_check_box,
  TreeCheckState.checked =>
    Icons.check_box,
};
```

## SuperTree<T>

`SuperTree<T>` owns tree and node interaction only.

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Project files',
          style: Theme.of(context)
              .textTheme
              .titleLarge,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SuperTree<FileMeta>(
            controller: controller,
            leadingBuilder: buildLeading,
            trailingBuilder: buildTrailing,
            showArabic: true,
            showLeafCount: true,
            onSearchRequested:
                controls.requestSearchFocus,
            onShortcutsRequested:
                () => showShortcutsHelp(context),
          ),
        ),
      ],
    ),
  ),
);
```

### Scrolling

The widget exposes Flutter scroll configuration directly:

```dart
final scrollController = ScrollController();

SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: buildLeading,
  scrollController: scrollController,
  primary: false,
  physics: const ClampingScrollPhysics(),
  reverse: false,
  shrinkWrap: false,
  cacheExtent: 600,
  restorationId: 'file-tree-scroll',
  keyboardDismissBehavior:
      ScrollViewKeyboardDismissBehavior.onDrag,
);
```

The focused row is kept visible when focus changes, including when a
shrink-wrapped tree is inside another scrollable.

## TreeRowInfo

```dart
Widget buildLeading(
  BuildContext context,
  TreeNode<FileMeta> node,
  TreeRowInfo info,
) {
  return Icon(
    info.hasChildren
        ? (info.open
            ? Icons.folder_open_outlined
            : Icons.folder_outlined)
        : Icons.description_outlined,
  );
}
```

## TreeSlotBuilder<T>

```dart
TreeSlotBuilder<FileMeta> leadingBuilder =
    (context, node, info) {
  return Icon(
    info.hasChildren
        ? Icons.folder_outlined
        : Icons.description_outlined,
  );
};
```

## TreeTrailingBuilder<T>

```dart
TreeTrailingBuilder<FileMeta> trailingBuilder =
    (context, node, info) {
  if (info.hasChildren) return null;
  return Text('${node.value?.size ?? 0} B');
};
```

## TreeRow<T>

`TreeRow<T>` is available for advanced host compositions.

```dart
TreeRow<FileMeta>(
  node: roots.first,
  depth: 0,
  controller: controller,
  accent: Theme.of(context)
      .colorScheme
      .primary,
  leadingBuilder: buildLeading,
  trailingBuilder: buildTrailing,
  showArabic: true,
  showLeafCount: true,
  onFocusRequest:
      focusNode.requestFocus,
);
```

Prefer `SuperTree<T>` for normal usage because it wires the full viewport,
keyboard model, empty/search state, and root rows.

## TreeCheckbox

```dart
TreeCheckbox(
  state: controller.checkState(node.code),
  accent: Theme.of(context)
      .colorScheme
      .primary,
  onTap: () => controller.toggleChecked(node),
);
```

## HighlightText

```dart
HighlightText(
  text: node.name,
  query: controller.query,
  style: Theme.of(context)
      .textTheme
      .bodyMedium!,
  overflow: TextOverflow.ellipsis,
);
```

## SuperTreeControlsController

```dart
final controls = SuperTreeControlsController(
  query: controller.query,
);

controls.requestSearchFocus();

@override
void dispose() {
  controls.dispose();
  controller.dispose();
  super.dispose();
}
```

## SuperTreeControls<T>

The optional toolbar is composed outside `SuperTree`.

```dart
Column(
  children: [
    SuperTreeControls<FileMeta>(
      controller: controller,
      controlsController: controls,
      placeholder: 'Search project files…',
      samples: const [
        'lib',
        'test',
        '.dart',
      ],
      enableEditing: true,
      extra: Text(
        '${controller.visibleLeaves} visible leaves',
      ),
    ),
    const SizedBox(height: 12),
    Expanded(
      child: SuperTree<FileMeta>(
        controller: controller,
        leadingBuilder: buildLeading,
        onSearchRequested:
            controls.requestSearchFocus,
        onShortcutsRequested:
            () => showShortcutsHelp(context),
      ),
    ),
  ],
);
```

`localizeDefaultText: false` keeps fixed default control labels instead of
resolving package defaults from the active locale.

## Context menus

### TreeContextMenuAction

Filter built-in actions by stable ID, not by translated label:

```dart
final withoutDelete = defaults.where(
  (item) =>
      item.id != TreeContextMenuAction.delete,
);
```

## TreeContextMenuItem

```dart
final items = <TreeContextMenuItem>[
  TreeContextMenuItem(
    id: 'open',
    label: 'Open',
    leading:
        const Icon(Icons.open_in_new),
    onTap: openCurrent,
  ),
  TreeContextMenuItem(
    id: 'create',
    label: 'Create',
    leading: const Icon(Icons.add),
    children: [
      TreeContextMenuItem(
        id: 'file',
        label: 'File',
        onTap: createFile,
      ),
      TreeContextMenuItem(
        id: 'folder',
        label: 'Folder',
        onTap: createFolder,
      ),
    ],
  ),
];
```

`children` can recursively contain more branch items.

## TreeContextMenuItemsBuilder<T>

```dart
TreeContextMenuItemsBuilder<FileMeta>
    menuItemsBuilder =
    (context, controller, node) {
  final defaults =
      buildDefaultTreeContextMenuItems<FileMeta>(
    context: context,
    controller: controller,
    node: node,
  );

  return [
    ...defaults.where(
      (item) =>
          item.id !=
          TreeContextMenuAction.delete,
    ),
    TreeContextMenuItem(
      id: 'properties',
      label: 'Properties',
      dividerAbove: true,
      onTap: () => openProperties(node),
    ),
  ];
};
```

Use it directly on the tree:

```dart
SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuItemsBuilder:
      menuItemsBuilder,
);
```

## TreeContextMenuStyle

```dart
const menuStyle = TreeContextMenuStyle(
  width: 280,
  edgePadding: 12,
  submenuGap: 6,
  itemPadding: EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 9,
  ),
  borderWidth: 1,
  disabledOpacity: 0.4,
);
```

```dart
SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuStyle: menuStyle,
);
```

## TreeContextMenuNodeContext<T>

The per-node configuration builder receives the complete context:

```dart
TreeContextMenuConfigBuilder<FileMeta>
    inspectMenu = (menu) {
  final node = menu.node;
  final defaults =
      menu.packageDefaultItems;
  final base = menu.baseItems;

  debugPrint(node.code);
  debugPrint('${defaults.length}');
  debugPrint('${base.length}');

  return const TreeContextMenuConfig();
};
```

It also provides `context`, `controller`, `defaultStyle`, and
`defaultAccent`.

## TreeContextMenuConfig

```dart
contextMenuConfigBuilder: (menu) {
  if (menu.node.code == 'protected') {
    return const TreeContextMenuConfig.disabled();
  }

  if (menu.node.hasChildren) {
    return TreeContextMenuConfig(
      style: const TreeContextMenuStyle(
        width: 300,
      ),
      accent: Theme.of(menu.context)
          .colorScheme
          .secondary,
      items: [
        ...menu.baseItems,
        TreeContextMenuItem(
          id: 'folder-info',
          label: 'Folder information',
          onTap: () =>
              showFolderInfo(menu.node),
        ),
      ],
    );
  }

  return const TreeContextMenuConfig();
},
```

## TreeContextMenuConfigBuilder<T>

```dart
TreeContextMenuConfigBuilder<FileMeta>
    menuPolicy = (menu) {
  if (menu.node.value?.isDirectory == true) {
    return TreeContextMenuConfig(
      items: [
        ...menu.baseItems,
        TreeContextMenuItem(
          id: 'new-file',
          label: 'New file here',
          onTap: () =>
              createFileIn(menu.node),
        ),
      ],
    );
  }

  return const TreeContextMenuConfig();
};
```

```dart
SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: buildLeading,
  contextMenuConfigBuilder: menuPolicy,
);
```

## buildDefaultTreeContextMenuItems()

```dart
final defaults =
    buildDefaultTreeContextMenuItems<FileMeta>(
  context: context,
  controller: controller,
  node: node,
);

final safeItems = defaults
    .where(
      (item) =>
          item.id !=
          TreeContextMenuAction.delete,
    )
    .toList();
```

## showTreeContextMenu()

Use the menu independently from `SuperTree`:

```dart
GestureDetector(
  onSecondaryTapDown: (details) {
    showTreeContextMenu<void>(
      context: context,
      globalPosition:
          details.globalPosition,
      items: [
        TreeContextMenuItem(
          label: 'Refresh',
          leading:
              const Icon(Icons.refresh),
          onTap: refresh,
        ),
        TreeContextMenuItem(
          label: 'More',
          children: [
            TreeContextMenuItem(
              label: 'Details',
              onTap: openDetails,
            ),
          ],
        ),
      ],
    );
  },
  child: const Text('Right-click me'),
);
```

## Keyboard shortcuts

| Key | Action |
| --- | --- |
| `↑` / `↓` | Move between visible rows. |
| `←` / `→` | Collapse or expand according to text direction. |
| `Home` / `End` | Jump to first or last visible row. |
| `Enter` / `Space` | Activate the focused node. |
| `Space` | Toggle checkbox selection when applicable. |
| `/` | Request focus for host search UI. |
| `*` | Expand all. |
| `\` | Collapse all. |
| `?` | Request keyboard help. |

## showShortcutsHelp()

```dart
SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: buildLeading,
  onShortcutsRequested:
      () => showShortcutsHelp(context),
);
```

Or open it from host UI:

```dart
IconButton(
  icon: const Icon(
    Icons.keyboard_command_key,
  ),
  onPressed:
      () => showShortcutsHelp(context),
);
```

## SuperTreeLocalization

Package-owned text is localized in English and Arabic.

```dart
MaterialApp(
  locale: locale,
  localizationsDelegates:
      SuperTreeLocalization.localizationsDelegates,
  supportedLocales:
      SuperTreeLocalization.supportedLocales,
  home: const MyHomePage(),
);
```

If the host owns the full delegate list:

```dart
MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    SuperTreeLocalization.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales:
      SuperTreeLocalization.supportedLocales,
  home: const MyHomePage(),
);
```

## lookupSuperTreeLocalization()

Resolve package strings without a `BuildContext` when an explicit locale is
already available:

```dart
final l10n = lookupSuperTreeLocalization(
  const Locale('ar'),
);

print(l10n.treeEmpty);
```


### SuperTreeLocalizationBuildContext

The exported extension provides direct access through `BuildContext`:

```dart
final l10n = context.superTreeLocalization;

Text(l10n.keyboardShortcuts);
```


### superTreeEnglishLocalizationFallback

Use the English fallback only when package localization is unavailable in the
current context:

```dart
final emptyMessage =
    superTreeEnglishLocalizationFallback.treeEmpty;
```

Application-specific titles, node labels, custom menu labels, and page text
remain owned by the host application's localization layer.

## Host composition

Screen-level presentation stays outside the tree:

```dart
AnimatedBuilder(
  animation: controller,
  builder: (context, _) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Text(
          'Files',
          style: Theme.of(context)
              .textTheme
              .headlineSmall,
        ),
        Text(
          '${controller.checkedCount} selected · '
          '${controller.totalLeaves} leaves',
        ),
        const SizedBox(height: 12),
        SuperTreeControls<FileMeta>(
          controller: controller,
          controlsController: controls,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SuperTree<FileMeta>(
            controller: controller,
            leadingBuilder: buildLeading,
            trailingBuilder: buildTrailing,
          ),
        ),
      ],
    );
  },
);
```

This lets the same tree work inside cards, dialogs, settings pages, desktop
panels, mobile screens, and domain-specific layouts.

## Complete component coverage

The README generator verifies the exports from `lib/super_tree.dart` before
writing. The package-owned API documented here includes:

```text
TreeNode<T>
TreeLogic
DropPosition
SearchText<T>
LeafValue<T>

SuperTreeController<T>
SuperTreeMode
SuperTreeSelectionMode
TreeCheckState

SuperTree<T>
TreeRow<T>
TreeRowInfo
TreeSlotBuilder<T>
TreeTrailingBuilder<T>
TreeCheckbox
HighlightText

SuperTreeControlsController
SuperTreeControls<T>

TreeContextMenuAction
TreeContextMenuItem
TreeContextMenuItemsBuilder<T>
TreeContextMenuStyle
TreeContextMenuNodeContext<T>
TreeContextMenuConfig
TreeContextMenuConfigBuilder<T>
buildDefaultTreeContextMenuItems()
showTreeContextMenu()

showShortcutsHelp()

SuperTreeLocalization
lookupSuperTreeLocalization()
SuperTreeLocalizationBuildContext
```

## Example application

The `example/` application demonstrates account, file, organization,
permission, product, scrolling, and context-menu scenarios.

Example screens can show the live widget and its Dart usage code together,
making it easier to compare behavior with the integration code.

## Additional information

- Homepage: https://geniussystems24.github.io/super_tree_field
- Repository: https://github.com/GeniusSystems24/super_tree_field
- Issues: https://github.com/GeniusSystems24/super_tree_field/issues

For bugs and feature requests, use the package issue tracker when available.
Contributions should preserve the generic hierarchy boundary: domain-specific
screen presentation should remain outside the core tree API.
