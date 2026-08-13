# super_tree_field

[![pub package](https://img.shields.io/pub/v/super_tree_field.svg)](https://pub.dev/packages/super_tree_field)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.32.0-02569B.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.8.0-0175C2.svg)](https://dart.dev)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A generic, typed, keyboard-first tree widget for Flutter.

`super_tree_field` renders arbitrary hierarchical data through
`TreeNode<T>`, manages interaction state with `SuperTreeController<T>`, and
keeps domain-specific models and presentation outside the package API.

## Features

- Generic `TreeNode<T>` payloads for any application domain.
- Recursive hierarchies with unlimited practical depth.
- Expand, collapse, expand-all, collapse-all, and subtree expansion.
- Ancestor-preserving, case-insensitive search with inline highlighting.
- Keyboard navigation with LTR- and RTL-aware horizontal behavior.
- Single and multi checkbox selection with derived tristate groups.
- Readable and editable modes.
- Inline rename, add, delete, and drag-and-drop tree mutations.
- Custom leading and trailing row content.
- Optional Arabic secondary labels.
- Optional responsive `SuperTreeControls<T>` rendered outside the tree.
- Configurable internal `ListView` scrolling and external `ScrollController`.
- Light and dark design-system theming through `super_core`.
- Text input integration through `super_form_field`.

## Getting started

### Requirements

| Requirement | Version |
| --- | --- |
| Dart | `>=3.8.0 <4.0.0` |
| Flutter | `>=3.32.0` |
| `super_core` | `>=3.3.0 <4.0.0` |
| `super_form_field` | `^1.8.2` |

### Install

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  super_tree_field: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Import the public barrel:

```dart
import 'package:super_tree_field/super_tree.dart';
```

The barrel also re-exports the `super_core` API used by the package.

### Configure the theme

`super_tree_field` reads colors, spacing, typography, radii, and motion from
`SuperMaterialThemeData`. With `super_core >=3.3.0`, provide both
`textTheme` and `primaryTextTheme` explicitly:

```dart
final textTheme = SuperTextTheme(isDesktop: true);

MaterialApp(
  theme: SuperMaterialThemeData.light(
    mode: SuperDeviceMode.desktop,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    mode: SuperDeviceMode.desktop,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  ),
  home: const ProjectTreePage(),
);
```

For adaptive applications, resolve the device mode from the available width and
rebuild the application theme when the active breakpoint changes:

```dart
final mode = SuperDeviceMode.forWidth(width);
```

Use `context.superTextTheme` to read typography. Do not use the removed
`SuperThemeData.textTheme` API from older `super_core` releases.

## Usage

### 1. Define typed nodes

Every node has a stable `code`, a primary `name`, an optional Arabic label,
an optional typed `value`, and optional children:

```dart
@immutable
class FileInfo {
  const FileInfo({required this.isDirectory, this.sizeLabel});

  final bool isDirectory;
  final String? sizeLabel;
}

const projectTree = <TreeNode<FileInfo>>[
  TreeNode<FileInfo>(
    code: 'lib',
    name: 'lib',
    value: FileInfo(isDirectory: true),
    children: [
      TreeNode<FileInfo>(
        code: 'lib/main.dart',
        name: 'main.dart',
        value: FileInfo(isDirectory: false, sizeLabel: '2.4 KB'),
      ),
    ],
  ),
];
```

`TreeNode.code` must be unique across the complete tree. Expansion, focus,
selection, editing, and drag-and-drop identity all depend on it.

Useful node APIs include `hasChildren`, `isLeaf`, `withChildren`, `copyWith`,
and `renamed`.

### 2. Create and dispose the controllers

Create controllers once in `State`, not in `build()`, and dispose every
controller that the host owns:

```dart
class ProjectTreePage extends StatefulWidget {
  const ProjectTreePage({super.key});

  @override
  State<ProjectTreePage> createState() => _ProjectTreePageState();
}

class _ProjectTreePageState extends State<ProjectTreePage> {
  late final SuperTreeController<FileInfo> _treeController;
  late final SuperTreeControlsController _controlsController;

  @override
  void initState() {
    super.initState();
    _treeController = SuperTreeController<FileInfo>(
      roots: projectTree,
      defaultExpandDepth: 0,
      searchText: (node) => '${node.code} ${node.name}',
      onOpenLeaf: (node) => debugPrint('Open ${node.code}'),
    );
    _controlsController = SuperTreeControlsController();
  }

  @override
  void dispose() {
    _controlsController.dispose();
    _treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SuperTreeControls<FileInfo>(
                controller: _treeController,
                controlsController: _controlsController,
                placeholder: 'Search project files',
                samples: const ['lib', 'main.dart'],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SuperTree<FileInfo>(
                  controller: _treeController,
                  title: 'Project files',
                  nameColumnLabel: 'Name',
                  trailingColumnLabel: 'Size',
                  unit: 'files',
                  showArabic: false,
                  onSearchRequested:
                      _controlsController.requestSearchFocus,
                  onShortcutsRequested: () => showShortcutsHelp(context),
                  leadingBuilder: (context, node, info) {
                    final isDirectory =
                        node.value?.isDirectory ?? node.hasChildren;
                    return Icon(
                      isDirectory
                          ? (info.open ? Icons.folder_open : Icons.folder)
                          : Icons.description_outlined,
                      size: 18,
                    );
                  },
                  trailingBuilder: (context, node, info) {
                    final size = node.value?.sizeLabel;
                    return size == null ? null : Text(size);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`SuperTree` renders the hierarchy only. `SuperTreeControls` is an optional,
separate toolbar that provides responsive search, quick-query chips, editing
controls, keyboard help, and expand/collapse actions.

### Build custom controls

You do not have to use `SuperTreeControls`. Any host UI can drive the public
controller API directly:

```dart
controller.setQuery(query);
controller.clearQuery();
controller.expandAll();
controller.collapseAll();
controller.setMode(SuperTreeMode.editable);
controller.addRoot();
```

Connect host-owned search and help UI to keyboard shortcuts with
`onSearchRequested` and `onShortcutsRequested`.

## Controller state

`SuperTreeController<T>` extends `ChangeNotifier` and owns the hierarchy's
interaction state.

Common reads:

```dart
controller.roots;
controller.visible;
controller.query;
controller.matchCount;
controller.focusId;
controller.selected;
controller.mode;
controller.editingId;
controller.checked;
controller.checkedCount;
```

Common updates:

```dart
controller.setRoots(updatedRoots);
controller.setQuery('settings');
controller.clearQuery();
controller.setMode(SuperTreeMode.editable);
controller.toggleMode();
controller.expandAll();
controller.collapseAll();
controller.expandSubtree('root.tools');
```

Supply `onTreeChanged` when structural edits must be persisted, and
`onSelectionChanged` when checkbox selection must be synchronized with
application state.

## Search

Search text is application-defined:

```dart
final controller = SuperTreeController<MyItem>(
  roots: roots,
  searchText: (node) => [
    node.code,
    node.name,
    node.ar,
    node.value?.searchLabel,
  ].whereType<String>().join(' '),
);
```

Search is case-insensitive and ancestor-preserving. A matching descendant keeps
its path visible, and filtered branches render expanded for the duration of the
query.

## Selection

Configure selection when the controller is created:

```dart
final controller = SuperTreeController<Permission>(
  roots: permissions,
  searchText: (node) => node.name,
  selectionMode: SuperTreeSelectionMode.multi,
  initialChecked: const {'permission.read'},
  onSelectionChanged: persistSelection,
);
```

| Mode | Behavior |
| --- | --- |
| `SuperTreeSelectionMode.none` | No checkboxes. This is the default. |
| `SuperTreeSelectionMode.single` | At most one node code is checked. |
| `SuperTreeSelectionMode.multi` | Groups derive checked, partial, or unchecked state from descendant leaves. |

Useful APIs include `checkState`, `isChecked`, `rootCheckState`,
`toggleChecked`, `toggleCheckedFocused`, `checkAll`, `clearChecked`,
`toggleCheckAll`, and `setChecked`.

## Editing

Editing is controlled by `SuperTreeController.mode`; the tree does not render a
built-in Read/Edit switch or Add button.

Provide `newNodeBuilder` when newly created nodes require a non-null typed
payload:

```dart
final controller = SuperTreeController<Category>(
  roots: categories,
  searchText: (node) => node.name,
  newNodeBuilder: (code) => TreeNode<Category>(
    code: code,
    name: 'New category',
    value: const Category(),
  ),
  onTreeChanged: saveTree,
);
```

Editable mode supports:

- Inline rename.
- Add root, child, sibling before, and sibling after.
- Delete a node and its subtree.
- Drag-and-drop before, inside, or after another node.
- Context-menu editing actions.

Programmatic editing APIs include `beginRename`, `commitRename`,
`cancelRename`, `addRoot`, `addChild`, `addSiblingBefore`, `addSiblingAfter`,
`deleteNode`, `moveNode`, and `canDrop`.

Structural editing is intentionally unavailable while a search projection is
active. Clear the query before restructuring the hierarchy.

## Custom row content

`leadingBuilder` is required. `trailingBuilder` is optional. Both receive a
`TreeRowInfo` describing the rendered row:

```dart
SuperTree<MyItem>(
  controller: controller,
  leadingBuilder: (context, node, info) {
    return Icon(info.hasChildren ? Icons.folder : Icons.description);
  },
  trailingBuilder: (context, node, info) {
    return Text(node.value?.statusLabel ?? '');
  },
);
```

`TreeRowInfo` exposes `depth`, `open`, and `hasChildren`.

## Scrolling

There are two different controller roles:

- `controller` is the required `SuperTreeController<T>` for hierarchy state.
- `scrollController` is an optional Flutter `ScrollController` for the tree's
  internal vertical `ListView`.

### Let the tree own scrolling

Give the tree bounded height through `Expanded`, `Flexible`, or `SizedBox`:

```dart
Expanded(
  child: SuperTree<MyItem>(
    controller: controller,
    scrollController: scrollController,
    physics: const BouncingScrollPhysics(),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    restorationId: 'project-tree',
    leadingBuilder: buildLeading,
  ),
);
```

The host owns and disposes an explicitly created `ScrollController`.

### Let a parent own scrolling

When `SuperTree` is inside another vertical scroll view, make ownership
explicit:

```dart
SingleChildScrollView(
  child: SuperTree<MyItem>(
    controller: controller,
    shrinkWrap: true,
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    leadingBuilder: buildLeading,
  ),
);
```

`SuperTree` also falls back to shrink-wrapping when it receives unbounded
vertical constraints.

The 1.0.0 scroll pass-through API is:

| Parameter | Default |
| --- | --- |
| `reverse` | `false` |
| `scrollController` | `null` |
| `primary` | `null` |
| `physics` | `null` |
| `shrinkWrap` | `false` |
| `cacheExtent` | `null` |
| `semanticChildCount` | `null` |
| `dragStartBehavior` | `DragStartBehavior.start` |
| `keyboardDismissBehavior` | `null` → `ScrollViewKeyboardDismissBehavior.manual` |
| `restorationId` | `null` |
| `clipBehavior` | `Clip.hardEdge` |
| `hitTestBehavior` | `HitTestBehavior.opaque` |

Do not combine `primary: true` with an explicit `scrollController`.

## Keyboard shortcuts

The tree must have focus before tree-navigation shortcuts are handled.

| Shortcut | Action |
| --- | --- |
| `↑` / `↓` | Move between visible rows. |
| `←` / `→` | Collapse or step out / expand or step in. Direction is RTL-aware. |
| `Home` / `End` | Jump to the first or last visible row. |
| `Enter` | Open a leaf or toggle a group. |
| `Space` | Toggle the focused checkbox in selection mode; otherwise activate the row. |
| `/` | Calls `onSearchRequested` when provided. |
| `*` | Expand all groups. |
| `\` | Collapse all groups. |
| `?` | Calls `onShortcutsRequested` when provided. |
| Right-click / long-press | Open the node context menu. |

When `SuperTreeControls` owns the search field, `Esc` clears the active search
while that field has focus.

## Tree algorithms

`TreeLogic` contains pure, widget-free hierarchy operations. Useful methods
include:

- `filter` and `countMatches` for search.
- `flattenVisible` and `parentOf` for navigation.
- `leafCount`, `leafCodes`, and `groupCodes` for derived state.
- `rollup` for generic numeric aggregation over leaves.
- `findNode`, `mapNode`, `removeNode`, `insertChild`, and `insertSibling` for
  immutable edits.
- `moveNode` and `isWithin` for safe drag-and-drop transforms.

## Examples

The runnable `example/` application demonstrates different payloads and
interaction models without adding those domains to the package API:

- `file_tree_demo.dart` — editable file hierarchy.
- `org_tree_demo.dart` — organization hierarchy.
- `permission_tree_demo.dart` — single and multi checkbox selection.
- `product_tree_demo.dart` — bilingual product/catalog hierarchy.
- `scroll_tree_demo.dart` — bounded scrolling and `ScrollController` usage.

Run the gallery from the package root:

```bash
cd example
flutter pub get
flutter run
```

## Additional information

### Architecture

The package keeps the reusable hierarchy engine under
`lib/src/features/super_tree/`:

```text
domain/
  entities/tree_node.dart
  usecases/tree_logic.dart
presentation/
  controllers/super_tree_controller.dart
  widgets/...
```

Domain-specific payloads, datasets, summaries, filters, and composed pages
belong in the consuming application or `example/lib/`.

### Public API documentation

Public APIs use Dart documentation comments and the package enables the
`public_member_api_docs` lint. New exported classes, constructors, fields,
methods, typedefs, and top-level functions should be documented before release.

### Issues and changes

- Repository: <https://github.com/GeniusSystems24/super_tree_field>
- Issues: <https://github.com/GeniusSystems24/super_tree_field/issues>
- Release history: [CHANGELOG.md](CHANGELOG.md)

### License

This package is distributed under the terms in [LICENSE](LICENSE).
