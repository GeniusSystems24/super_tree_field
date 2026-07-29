# super_tree_field

[![pub package](https://img.shields.io/pub/v/super_tree_field.svg)](https://pub.dev/packages/super_tree_field)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.32.0-02569B.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.8.0-0175C2.svg)](https://dart.dev)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A generic, recursive, keyboard-first tree widget for Flutter.

`super_tree_field` provides a reusable hierarchy engine built around
`TreeNode<T>`, `SuperTreeController<T>`, and `SuperTree<T>`. It supports
search, expansion, keyboard navigation, single or multi-selection, inline
editing, drag-and-drop reordering, contextual actions, bilingual node labels,
and light/dark themes through `super_core`.

The package also includes `AccountTree`, a ready-made chart-of-accounts tree
with account types, debit/credit nature, roll-up balances, KPI cards, filters,
and bundled sample data.

## Features

- Generic tree nodes with typed payloads.
- Recursive rendering for hierarchies of any depth.
- Ancestor-preserving search with inline highlighting.
- Keyboard navigation with LTR and RTL-aware arrow behavior.
- Readable and editable modes.
- Inline rename, add, delete, and drag-and-drop operations.
- Single and multi-selection with tristate group checkboxes.
- Expand all, collapse all, and expand-subtree actions.
- Custom leading and trailing cells.
- Optional Arabic labels on every node.
- Responsive layouts using `super_core` device modes.
- A chart-of-accounts implementation with financial summaries.

## Requirements

| Dependency | Minimum version |
| --- | --- |
| Dart | `3.8.0` |
| Flutter | `3.32.0` |
| `super_core` | `3.0.0` |

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  super_tree_field: ^0.5.0
```

Then install dependencies:

```bash
flutter pub get
```

Import the public barrel:

```dart
import 'package:super_tree_field/super_tree.dart';
```

The barrel also re-exports the public `super_core` API used by this package.

## Theme setup

`super_tree_field` reads its colors, spacing, typography, radii, and motion
from `SuperMaterialThemeData`. Configure the theme at the application root:

```dart
import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: SuperMaterialThemeData.light(
        palette: SuperPalette.bluePalette,
        mode: SuperDeviceMode.desktop,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        palette: SuperPalette.bluePalette,
        mode: SuperDeviceMode.desktop,
      ),
      home: const FileTreePage(),
    );
  }
}
```

Choose the device mode that matches the current layout:

```dart
final mode = SuperDeviceMode.forWidth(MediaQuery.sizeOf(context).width);
```

When the application supports multiple form factors, rebuild the root theme
when the active width crosses the mobile, tablet, or desktop breakpoint.

## Quick start

The following example creates a reusable file tree. The controller is created
once in `initState` and disposed with the widget, following Flutter controller
lifecycle conventions.

```dart
import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';

@immutable
class FileItem {
  const FileItem.folder() : isFolder = true, size = null;
  const FileItem.file(this.size) : isFolder = false;

  final bool isFolder;
  final String? size;
}

const files = <TreeNode<FileItem>>[
  TreeNode<FileItem>(
    code: 'lib',
    name: 'lib',
    value: FileItem.folder(),
    children: [
      TreeNode<FileItem>(
        code: 'lib/main.dart',
        name: 'main.dart',
        value: FileItem.file('2.4 KB'),
      ),
      TreeNode<FileItem>(
        code: 'lib/features',
        name: 'features',
        value: FileItem.folder(),
        children: [
          TreeNode<FileItem>(
            code: 'lib/features/home.dart',
            name: 'home.dart',
            value: FileItem.file('5.1 KB'),
          ),
        ],
      ),
    ],
  ),
  TreeNode<FileItem>(
    code: 'README.md',
    name: 'README.md',
    value: FileItem.file('8.7 KB'),
  ),
];

class FileTreePage extends StatefulWidget {
  const FileTreePage({super.key});

  @override
  State<FileTreePage> createState() => _FileTreePageState();
}

class _FileTreePageState extends State<FileTreePage> {
  late final SuperTreeController<FileItem> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SuperTreeController<FileItem>(
      roots: files,
      defaultExpandDepth: 0,
      searchText: (node) => '${node.code} ${node.name}',
      onOpenLeaf: (node) {
        debugPrint('Open ${node.code}');
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SuperTree<FileItem>(
            controller: _controller,
            title: 'Project files',
            subtitle: 'Browse the current Flutter project',
            titleIcon: Icons.folder_open_outlined,
            nameColumnLabel: 'Name',
            trailingColumnLabel: 'Size',
            placeholder: 'Search files',
            samples: const ['dart', 'features', 'README'],
            unit: 'files',
            showArabic: false,
            leadingBuilder: (context, node, info) {
              final isFolder = node.value?.isFolder ?? node.hasChildren;
              return Icon(
                isFolder
                    ? (info.open ? Icons.folder_open : Icons.folder)
                    : Icons.description_outlined,
                size: 18,
              );
            },
            trailingBuilder: (context, node, info) {
              final size = node.value?.size;
              return size == null ? null : Text(size);
            },
          ),
        ),
      ),
    );
  }
}
```

## Tree data model

Every hierarchy is represented by `TreeNode<T>`:

```dart
const node = TreeNode<String>(
  code: 'departments.engineering.mobile',
  name: 'Mobile',
  ar: 'تطبيقات الجوال',
  value: 'mobile-team',
  children: [
    TreeNode<String>(
      code: 'employees.42',
      name: 'Anwar',
      ar: 'أنور',
      value: 'employee-42',
    ),
  ],
);
```

| Property | Description |
| --- | --- |
| `code` | Stable unique identifier used for expansion, focus, selection, editing, and drag-and-drop. |
| `name` | Primary node label. |
| `ar` | Optional Arabic label. |
| `value` | Optional domain payload of type `T`. |
| `children` | Optional child nodes. A null or empty list creates a leaf. |

Useful node APIs:

```dart
node.hasChildren;
node.isLeaf;
node.withChildren(updatedChildren);
node.copyWith(name: 'Updated name');
node.renamed('Updated name', ar: 'اسم محدّث');
```

Codes must be unique across the complete tree. Duplicate codes cause expansion,
focus, selection, and editing state to target the wrong node.

## Controller

`SuperTreeController<T>` is the state owner for the tree. It extends
`ChangeNotifier`, so the widget reacts automatically when controller state
changes.

```dart
final controller = SuperTreeController<MyItem>(
  roots: roots,
  searchText: (node) => '${node.code} ${node.name} ${node.ar ?? ''}',
  defaultExpandDepth: 1,
  query: '',
  mode: SuperTreeMode.readable,
  selectionMode: SuperTreeSelectionMode.none,
  onOpenLeaf: openItem,
  onTreeChanged: saveTree,
  onSelectionChanged: saveSelection,
);
```

The host that creates the controller owns it and must call `dispose()`.

### Reading state

```dart
controller.roots;
controller.visible;
controller.query;
controller.searching;
controller.matchCount;
controller.totalLeaves;
controller.visibleLeaves;
controller.focusId;
controller.selected;
controller.mode;
controller.isEditable;
controller.editingId;
controller.checked;
controller.checkedCount;
controller.checkedNodes;
```

### Updating state

```dart
controller.setRoots(updatedRoots);
controller.setQuery('invoice');
controller.clearQuery();
controller.setMode(SuperTreeMode.editable);
controller.toggleMode();
controller.expandAll();
controller.collapseAll();
controller.expandSubtree('root-code');
controller.clearSelection();
```

## Search

Supply a `searchText` callback when creating the controller. The callback should
return every field that must participate in search:

```dart
searchText: (node) => [
  node.code,
  node.name,
  node.ar,
  node.value?.category,
].whereType<String>().join(' '),
```

Search is case-insensitive and ancestor-preserving:

- A matching node keeps its complete subtree.
- A matching descendant keeps the path from the root to that descendant.
- All filtered branches are rendered expanded while the query is active.
- Matching text is highlighted by `HighlightText`.

Drive search programmatically when needed:

```dart
controller.setQuery('bank');
final matches = controller.matchCount;
controller.clearQuery();
```

## Selection

Selection is configured when the controller is created.

### Single selection

```dart
final controller = SuperTreeController<Permission>(
  roots: permissionTree,
  searchText: (node) => node.name,
  selectionMode: SuperTreeSelectionMode.single,
  initialChecked: const {'permission.read'},
  onSelectionChanged: (codes) {
    debugPrint('Selected: $codes');
  },
);
```

Single selection keeps at most one node code.

### Multi-selection

```dart
final controller = SuperTreeController<Permission>(
  roots: permissionTree,
  searchText: (node) => node.name,
  selectionMode: SuperTreeSelectionMode.multi,
  initialChecked: const {
    'permission.read',
    'permission.create',
  },
  onSelectionChanged: persistPermissions,
);
```

In multi-selection mode:

- Selecting a group selects all descendant leaves.
- Group checkboxes derive a checked, partial, or unchecked state from leaves.
- The table header provides a select-all checkbox.
- `checked` contains checked leaf codes.

Selection APIs:

```dart
controller.checkState('permission.manage');
controller.isChecked('permission.read');
controller.rootCheckState;
controller.toggleChecked(node);
controller.toggleCheckedFocused();
controller.checkAll();
controller.clearChecked();
controller.toggleCheckAll();
controller.setChecked({'permission.read'});
```

The available states are:

```dart
TreeCheckState.unchecked
TreeCheckState.partial
TreeCheckState.checked
```

## Editing

Editing requires two related settings:

1. The controller mode controls whether mutations are active.
2. `SuperTree.enableEditing` displays the built-in Read/Edit switch and Add node action.

```dart
late final controller = SuperTreeController<Category>(
  roots: categories,
  searchText: (node) => node.name,
  mode: SuperTreeMode.readable,
  newNodeBuilder: (code) => TreeNode<Category>(
    code: code,
    name: 'New category',
    value: const Category(),
  ),
  onTreeChanged: (updatedRoots) {
    repository.save(updatedRoots);
  },
);

SuperTree<Category>(
  controller: controller,
  enableEditing: true,
  leadingBuilder: buildCategoryIcon,
);
```

Editable mode provides:

- Inline rename.
- Add root, child, sibling before, or sibling after.
- Delete a node and its subtree.
- Drag-and-drop before, inside, or after another node.
- A contextual menu through right-click, long-press, or the row menu button.

Programmatic editing APIs:

```dart
controller.beginRename(code);
controller.commitRename(code, 'New name', ar: 'اسم جديد');
controller.cancelRename();
controller.addRoot();
controller.addChild(parentCode);
controller.addSiblingBefore(code);
controller.addSiblingAfter(code);
controller.deleteNode(code);
controller.moveNode(dragCode, targetCode, DropPosition.inside);
controller.canDrop(dragCode, targetCode);
```

Structural changes are emitted through `onTreeChanged`. Persist the returned
roots in the application repository or state-management layer.

Drag-and-drop and row editing are paused while search is active. Clear the query
before restructuring the tree.

## Custom cells and layout slots

`SuperTree<T>` requires a leading-cell builder and accepts an optional trailing
builder. Both receive `TreeRowInfo`:

```dart
leadingBuilder: (context, node, info) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(info.hasChildren ? Icons.folder : Icons.description),
      const SizedBox(width: 8),
      Text(node.code),
    ],
  );
},
trailingBuilder: (context, node, info) {
  return Text(node.value?.statusLabel ?? '');
},
```

`TreeRowInfo` exposes:

| Property | Description |
| --- | --- |
| `depth` | Zero-based depth of the node. |
| `open` | Whether the branch is currently rendered expanded. |
| `hasChildren` | Whether the node is a branch. |

Use `above` for content above the search toolbar and `toolbarExtra` for an
additional row beneath it:

```dart
SuperTree<Project>(
  controller: controller,
  leadingBuilder: buildLeading,
  above: const ProjectSummary(),
  toolbarExtra: const ProjectFilters(),
);
```

## `SuperTree` configuration

| Parameter | Purpose |
| --- | --- |
| `controller` | Required state controller. |
| `leadingBuilder` | Required leading-cell builder. |
| `trailingBuilder` | Optional trailing-cell builder. |
| `accent` | Overrides the theme accent for tree interactions. |
| `title` | Tree-card title. |
| `subtitle` | Optional descriptive subtitle. |
| `titleIcon` | Optional title icon. |
| `nameColumnLabel` | Main-column heading. |
| `trailingColumnLabel` | Trailing-column heading. |
| `placeholder` | Search-field hint. |
| `samples` | Search suggestion chips. |
| `unit` | Noun used in leaf-count summaries. |
| `showArabic` | Shows or hides `TreeNode.ar`. |
| `showLeafCount` | Shows or hides branch leaf counts. |
| `selectionLabel` | Label used in the selected/opened summary. |
| `enableEditing` | Displays built-in editing controls. |
| `above` | Widget rendered above the toolbar. |
| `toolbarExtra` | Additional toolbar content. |

## Keyboard navigation

Focus the tree, then use:

| Key | Action |
| --- | --- |
| `Arrow Up` / `Arrow Down` | Move between visible rows. |
| `Arrow Right` | Expand or move toward children in LTR. Mirrored in RTL. |
| `Arrow Left` | Collapse or move toward the parent in LTR. Mirrored in RTL. |
| `Home` / `End` | Move to the first or last visible row. |
| `Enter` | Open a leaf or toggle a branch. |
| `Space` | Toggle the focused checkbox when selection is enabled; otherwise activate the row. |
| `/` | Focus the search field. |
| `Escape` | Clear the query while the search field is focused. |
| `*` | Expand all branches. |
| `\` | Collapse all branches. |
| `?` | Open the keyboard-shortcuts dialog. |
| Right-click / long-press | Open the node context menu. |

The horizontal arrow behavior is resolved through `Directionality`, so tree
navigation remains visually correct in RTL layouts.

## Chart of accounts

`AccountTree` is a specialized `SuperTree<AccountData>` implementation:

```dart
AccountTree(
  roots: myAccounts,
  onOpenAccount: (account) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountLedgerPage(accountCode: account.code),
      ),
    );
  },
);
```

Omit `roots` to use `AccountTreeData.tree`:

```dart
const AccountTree();
```

The built-in account tree includes:

- Five account types: asset, liability, equity, income, and expense.
- Debit and credit account nature.
- English and Arabic account names.
- Leaf balances and recursive group roll-ups.
- Total assets, liabilities, equity, and net-income KPI cards.
- An assets-versus-liabilities-plus-equity balance indicator.
- Account-type filters.
- A balance share bar for each node.
- Read and edit modes.

`AccountTree` labels monetary values as SAR. Build a custom
`SuperTree<AccountData>` when the product requires another currency, formatter,
column layout, or persistence workflow.

A ready-to-route page is also exported:

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => const AccountTreeDemo(),
  ),
);
```

### Account domain types

```dart
const account = AccountData(
  type: AccountType.asset,
  balance: 125000,
);

final nature = AccountType.asset.nature; // AccountNature.debit
final code = nature.code;                // DR
```

`AccountType.ordered` returns the stable display order used by the built-in
filters and KPI layout.

## Tree algorithms

`TreeLogic` contains stateless hierarchy operations and can be used without the
`SuperTree` widget:

```dart
final leafCount = TreeLogic.leafCount(root);
final leafCodes = TreeLogic.leafCodes(root);
final total = TreeLogic.rollup(root, (node) => node.value?.amount ?? 0);
final groups = TreeLogic.groupCodes(roots, maxDepth: 2);
final filtered = TreeLogic.filter(roots, 'sales', searchText);
final matches = TreeLogic.countMatches(roots, 'sales', searchText);
final visible = TreeLogic.flattenVisible(roots, expandedCodes, false);
final parent = TreeLogic.parentOf(roots, nodeCode);
```

Immutable edit operations:

```dart
final renamed = TreeLogic.mapNode(
  roots,
  nodeCode,
  (node) => node.renamed('Updated'),
);

final withoutNode = TreeLogic.removeNode(roots, nodeCode);
final withChild = TreeLogic.insertChild(roots, parentCode, child);
final withSibling = TreeLogic.insertSibling(
  roots,
  targetCode,
  sibling,
  after: true,
);
final moved = TreeLogic.moveNode(
  roots,
  dragCode,
  targetCode,
  DropPosition.inside,
);
```

These operations return new tree lists rather than mutating the supplied
hierarchy.

## RTL and bilingual labels

Place the tree below a `Directionality` or a localized `MaterialApp`:

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: SuperTree<MyItem>(
    controller: controller,
    showArabic: true,
    leadingBuilder: buildLeading,
  ),
);
```

`TreeNode.ar` is a secondary Arabic label. Setting `showArabic: false` hides it.
The package mirrors directional indentation and horizontal keyboard navigation,
but its built-in toolbar and action labels are English strings. Application-wide
localization of those labels requires a custom wrapper or package-level string
customization.

## Responsive usage

The toolbar uses wrapping layouts and the account KPI cards adjust their column
count based on available width. For predictable component density, generate the
`super_core` theme with the matching `SuperDeviceMode`:

```dart
final mode = SuperDeviceMode.forWidth(width);

final lightTheme = SuperMaterialThemeData.light(
  palette: SuperPalette.purplePalette,
  mode: mode,
);
```

For narrow screens, place the tree in a vertically scrollable page and provide
sufficient horizontal space for custom trailing columns. Keep custom cells
compact and prefer `TextOverflow.ellipsis` for unbounded labels.

## Public API overview

### Domain

| API | Purpose |
| --- | --- |
| `TreeNode<T>` | Generic immutable hierarchy node. |
| `AccountData` | Account payload containing type and balance. |
| `AccountType` | Asset, liability, equity, income, and expense metadata. |
| `AccountNature` | Debit or credit nature. |
| `DropPosition` | Before, inside, or after drag-and-drop position. |
| `SearchText<T>` | Search-text callback type. |
| `LeafValue<T>` | Numeric leaf-value callback type. |
| `TreeLogic` | Pure hierarchy query and edit operations. |

### State

| API | Purpose |
| --- | --- |
| `SuperTreeController<T>` | Expansion, focus, search, selection, and editing state. |
| `SuperTreeMode` | Readable or editable interaction mode. |
| `SuperTreeSelectionMode` | None, single, or multi-selection. |
| `TreeCheckState` | Unchecked, partial, or checked state. |

### Widgets and helpers

| API | Purpose |
| --- | --- |
| `SuperTree<T>` | Generic tree shell and interaction view. |
| `TreeRow<T>` | Low-level recursive node-row widget. |
| `TreeRowInfo` | Row depth, expansion, and branch metadata. |
| `TreeSlotBuilder<T>` | Leading-cell builder type. |
| `TreeTrailingBuilder<T>` | Trailing-cell builder type. |
| `TreeCheckbox` | Themed tristate checkbox. |
| `HighlightText` | Highlights a matching search substring. |
| `showTreeContextMenu<T>` | Opens the mode-aware node context menu. |
| `showShortcutsHelp` | Opens the keyboard-shortcuts dialog. |
| `AccountTree` | Ready-made chart-of-accounts tree. |
| `AccountTreeDemo` | Scaffolded chart-of-accounts page. |
| `KpiCard` | Financial summary card used by `AccountTree`. |
| `NaturePill` | Debit/credit indicator. |
| `AccountTreeData` | Bundled sample account hierarchy. |

Most applications should compose `SuperTree<T>` instead of constructing
`TreeRow<T>` directly.

## Flutter usage guidelines

- Create long-lived controllers in `initState`, not inside `build`.
- Dispose every controller created by the host widget.
- Keep every `TreeNode.code` unique and stable across rebuilds and persistence.
- Treat `TreeNode` values and root lists as immutable application state.
- Persist `onTreeChanged` output instead of reading private widget state.
- Include codes, translated labels, and domain keywords in `searchText`.
- Keep expensive calculations outside cell builders when the tree is large.
- Use `const` constructors for static nodes and widgets where possible.
- Keep leading and trailing builders small to reduce rebuild cost.
- Test keyboard focus, RTL navigation, selection cascades, and edit persistence.
- Provide meaningful tooltips or semantics for custom icon-only controls.

## Testing

A widget test can create a controller, pump `SuperTree`, then interact with
labels or controller methods:

```dart
testWidgets('filters nodes through the controller', (tester) async {
  final controller = SuperTreeController<FileItem>(
    roots: files,
    searchText: (node) => node.name,
  );
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: SuperMaterialThemeData.light(),
      home: Scaffold(
        body: SuperTree<FileItem>(
          controller: controller,
          showArabic: false,
          leadingBuilder: (context, node, info) {
            return const Icon(Icons.description_outlined);
          },
        ),
      ),
    ),
  );

  controller.setQuery('README');
  await tester.pump();

  expect(find.text('README.md'), findsOneWidget);
  expect(find.text('main.dart'), findsNothing);
});
```

Prefer domain tests for `TreeLogic` and widget tests for focus, keyboard,
selection, editing controls, and rendered labels.

## License

See [LICENSE](LICENSE).
