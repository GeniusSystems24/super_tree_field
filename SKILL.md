---
name: super-tree
description: >
  Use super_tree_field 1.0.0 to build generic, typed Flutter hierarchy views
  with recursive rendering, search, keyboard navigation, checkbox selection,
  inline editing, drag-and-drop, external responsive controls, configurable
  scrolling, LTR/RTL behavior, and GeniusLink design-system theming.
---

# Super Tree — Agent Skill

Use this skill for `super_tree_field` **1.0.0**.

The package is a generic hierarchy engine. Keep business-domain models,
datasets, summaries, filters, and specialized pages outside `lib/`; place them
in the consuming application or under `example/lib/`.

## Core architecture

Use these public types as the main integration surface:

- `TreeNode<T>` — immutable generic hierarchy data.
- `TreeLogic` — pure, widget-free hierarchy algorithms.
- `SuperTreeController<T>` — expansion, search, focus, selection, and editing
  state.
- `SuperTree<T>` — hierarchy rendering and keyboard interaction.
- `SuperTreeControls<T>` — optional responsive controls composed outside the
  tree.
- `SuperTreeControlsController` — owns the standard control bar's search field
  and search focus.

Do not add domain-specific models or presentation widgets to
`lib/src/features/super_tree/`.

## Install and import

```yaml
dependencies:
  super_tree_field: ^1.0.0
```

```dart
import 'package:super_tree_field/super_tree.dart';
```

The package requires Dart `>=3.8.0`, Flutter `>=3.32.0`, `super_core >=3.3.0`,
and `super_form_field ^1.8.2`.

## Theme rules

Use `SuperMaterialThemeData` and provide both text-theme arguments required by
`super_core >=3.3.0`:

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
);
```

Inside widgets, read typography with `context.superTextTheme`. Do not generate
`context.superTheme.textTheme` or `SuperThemeData.of(context).textTheme`.

## Data-model rules

Every node is a `TreeNode<T>` and `T` belongs to the host application:

```dart
class ProductMeta {
  const ProductMeta({required this.kind, this.status});

  final String kind;
  final String? status;
}

const node = TreeNode<ProductMeta>(
  code: 'catalog.hardware.keyboards',
  name: 'Keyboards',
  ar: 'لوحات المفاتيح',
  value: ProductMeta(kind: 'category'),
);
```

Required invariants:

- `code` is globally unique across the complete tree.
- `code` stays stable across rebuilds and persistence.
- `children == null` or an empty list means leaf.
- `value` is optional and may be null for newly minted nodes unless the host
  supplies `newNodeBuilder`.
- Builders must tolerate null `value` unless the controller guarantees one.

## Controller lifecycle

Create `SuperTreeController<T>` once in `State` and dispose it:

```dart
late final SuperTreeController<ProductMeta> _controller;

@override
void initState() {
  super.initState();
  _controller = SuperTreeController<ProductMeta>(
    roots: roots,
    searchText: (node) => '${node.code} ${node.name} ${node.ar ?? ''}',
  );
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

Never create a `SuperTreeController` or `ScrollController` inside `build()`.

## Render the tree

`leadingBuilder` is required. `trailingBuilder` is optional:

```dart
SuperTree<ProductMeta>(
  controller: _controller,
  title: 'Catalog',
  nameColumnLabel: 'Name',
  trailingColumnLabel: 'Status',
  unit: 'items',
  leadingBuilder: (context, node, info) {
    return Icon(info.hasChildren ? Icons.folder : Icons.inventory_2_outlined);
  },
  trailingBuilder: (context, node, info) {
    final status = node.value?.status;
    return status == null ? null : Text(status);
  },
);
```

`TreeRowInfo` provides `depth`, `open`, and `hasChildren`.

## External controls are the 1.0.0 default

`SuperTree` must not contain search, quick-query chips, Add node, Read/Edit,
help, Expand all, Collapse, filters, or other page-level controls.

Use `SuperTreeControls<T>` when the standard responsive controls are suitable:

```dart
late final SuperTreeControlsController _controls;

@override
void initState() {
  super.initState();
  _controls = SuperTreeControlsController();
}

@override
void dispose() {
  _controls.dispose();
  super.dispose();
}

Column(
  children: [
    SuperTreeControls<ProductMeta>(
      controller: _controller,
      controlsController: _controls,
      samples: const ['Active', 'Draft'],
      enableEditing: true,
    ),
    const SizedBox(height: 12),
    Expanded(
      child: SuperTree<ProductMeta>(
        controller: _controller,
        onSearchRequested: _controls.requestSearchFocus,
        onShortcutsRequested: () => showShortcutsHelp(context),
        leadingBuilder: buildLeading,
      ),
    ),
  ],
);
```

Hosts can replace `SuperTreeControls` completely and call the controller API
from any UI:

```dart
_controller.setQuery(query);
_controller.clearQuery();
_controller.expandAll();
_controller.collapseAll();
_controller.setMode(SuperTreeMode.editable);
_controller.addRoot();
```

## Responsive-layout rules

Examples and host pages should adapt controls to available width:

- Prefer `Wrap` for peer actions that should remain adjacent when space exists.
- Do not put each action button in its own full-width row unless that layout is
  intentional.
- Avoid `Expanded` inside a `Wrap`.
- Keep chip/button content at intrinsic width.
- Make search full width on compact layouts and bounded on wider layouts.
- Use `LayoutBuilder` when behavior depends on actual available constraints.
- Keep `SuperTree` in `Expanded`, `Flexible`, or `SizedBox` when the tree owns
  vertical scrolling.

## Search

Search is controlled by `SuperTreeController`:

```dart
_controller.setQuery('keyboard');
_controller.matchCount;
_controller.clearQuery();
```

`searchText` defines the searchable haystack. Filtering is case-insensitive and
ancestor-preserving. While searching, matched branches are rendered open.

Use `onSearchRequested` to connect the tree's `/` shortcut to external search
UI. `SuperTreeControls` handles `Esc` to clear search while its search field has
focus.

## Selection

Configure selection when creating the controller:

```dart
SuperTreeController<Permission>(
  roots: permissions,
  searchText: (node) => node.name,
  selectionMode: SuperTreeSelectionMode.multi,
  initialChecked: const {'permission.read'},
  onSelectionChanged: persistSelection,
);
```

Modes:

- `none` — no checkboxes.
- `single` — at most one checked node code.
- `multi` — leaf codes are the source of truth; groups derive checked, partial,
  or unchecked state from descendant leaves.

Useful APIs: `checkState`, `isChecked`, `rootCheckState`, `checked`,
`checkedCount`, `checkedNodes`, `toggleChecked`, `toggleCheckedFocused`,
`checkAll`, `clearChecked`, `toggleCheckAll`, and `setChecked`.

## Editing

Editing state belongs to `SuperTreeController.mode`:

```dart
_controller.setMode(SuperTreeMode.editable);
_controller.toggleMode();
```

Provide `newNodeBuilder` when added nodes need a domain payload:

```dart
newNodeBuilder: (code) => TreeNode<ProductMeta>(
  code: code,
  name: 'New node',
  value: const ProductMeta(kind: 'item'),
),
```

Persist structural edits through `onTreeChanged`.

Editing APIs:

- `beginRename` / `commitRename` / `cancelRename`.
- `addRoot` / `addChild`.
- `addSiblingBefore` / `addSiblingAfter`.
- `deleteNode`.
- `moveNode` / `canDrop` with `DropPosition.before`, `.inside`, or `.after`.

Do not expect drag-and-drop or row editing while search is active. The filtered
hierarchy is a projection; clear the query before restructuring it.

## Form-field rules

Version 1.0.0 uses `super_form_field` for tree search and inline rename.

The valid text widget is:

```dart
SuperTextFormField(...)
```

The valid controller is:

```dart
SuperTextFieldController
```

Do not generate `SuperFormField`; that symbol does not exist in
`super_form_field 1.8.2`.

`SuperTextFieldController` owns its backing `TextEditingController` and
`FocusNode`. Access them through `.text` and `.focusNode`, and read/write values
through `.value` and `.setValue(...)` where appropriate.

Do not constrain an inline `SuperTextFormField` to an arbitrary height smaller
than `FieldDensity.compact`; let the design-system field own its control height.

## Scrolling and controller names

The two controller roles are intentionally distinct:

- `controller:` → required `SuperTreeController<T>`.
- `scrollController:` → optional Flutter `ScrollController`.

Bounded internal scrolling:

```dart
Expanded(
  child: SuperTree<ProductMeta>(
    controller: _controller,
    scrollController: _scrollController,
    physics: const BouncingScrollPhysics(),
    leadingBuilder: buildLeading,
  ),
);
```

Parent-owned vertical scrolling:

```dart
SingleChildScrollView(
  child: SuperTree<ProductMeta>(
    controller: _controller,
    shrinkWrap: true,
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    leadingBuilder: buildLeading,
  ),
);
```

The 1.0.0 scroll API is exactly:

- `reverse`
- `scrollController`
- `primary`
- `physics`
- `shrinkWrap`
- `cacheExtent`
- `semanticChildCount`
- `dragStartBehavior`
- `keyboardDismissBehavior`
- `restorationId`
- `clipBehavior`
- `hitTestBehavior`

Do not add `scrollBehavior` or `paintOrder`; they are not part of the 1.0.0
`SuperTree` API.

Do not combine `primary: true` with an explicit `scrollController`.

## Keyboard behavior

After the tree has focus:

- `↑` / `↓` — previous / next visible row.
- `←` / `→` — collapse/step out or expand/step in, mirrored for RTL.
- `Home` / `End` — first / last visible row.
- `Enter` — activate focused row.
- `Space` — checkbox toggle in selection mode; otherwise activate.
- `/` — call `onSearchRequested` when provided.
- `*` — expand all.
- `\` — collapse all.
- `?` — call `onShortcutsRequested` when provided.
- Right-click / long-press — context menu.

Do not reimplement keyboard navigation in individual examples.

## TreeLogic

Use `TreeLogic` for pure hierarchy work instead of duplicating recursive code:

- Search: `filter`, `countMatches`.
- Visibility/navigation: `flattenVisible`, `parentOf`, `findNode`.
- Derived data: `leafCount`, `leafCodes`, `groupCodes`, `rollup`.
- Immutable editing: `mapNode`, `removeNode`, `insertChild`, `insertSibling`.
- Drag-and-drop safety: `moveNode`, `isWithin`.

## Package boundaries

Keep `lib/src/features/super_tree/` generic.

Allowed in `lib/`:

- Generic tree entities and algorithms.
- Generic tree/controller widgets.
- Generic row, selection, context-menu, search-highlight, shortcut, and control
  primitives.

Keep outside `lib/`:

- Business-domain payload classes.
- Domain-specific sample data.
- Domain-specific KPI/summary widgets.
- Product-specific filters or badges.
- Ready-made pages tied to one business domain.

The runnable examples belong under `example/lib/`.

## Reference examples

Use these examples when generating or modifying integrations:

- `example/lib/file_tree_demo.dart` — editable generic hierarchy.
- `example/lib/org_tree_demo.dart` — custom leading/trailing content.
- `example/lib/permission_tree_demo.dart` — selection modes.
- `example/lib/product_tree_demo.dart` — bilingual metadata hierarchy.
- `example/lib/scroll_tree_demo.dart` — scroll ownership and restoration.
- `example/lib/responsive_example_layout.dart` — shared adaptive page layout.

## Documentation rules

Follow Dart/Flutter documentation conventions for exported APIs:

- Use `///` Dartdoc comments.
- Start with a concise summary sentence ending in a period.
- Put supporting paragraphs after the summary.
- Link Dart symbols with brackets, for example `[SuperTree]` and
  `[ScrollController]`.
- Document every exported class, enum, constructor, field, getter, method,
  typedef, and top-level function.
- Describe behavior and ownership rather than internal implementation details.
- Document controller disposal requirements.
- Keep examples syntactically valid and use fenced `dart` blocks in Markdown.

The package enables `public_member_api_docs`; new undocumented public APIs
should fail analysis before release.

## Common mistakes

- Passing a `ScrollController` to `controller:` instead of `scrollController:`.
- Creating controllers in `build()` and losing state on rebuild.
- Forgetting to dispose host-owned tree, controls, or scroll controllers.
- Using non-unique `TreeNode.code` values.
- Putting page-level controls back inside the `SuperTree` widget.
- Putting domain-specific models or presentation helpers under `lib/`.
- Using a vertical `Row`/`Column` layout that gives every peer action a full
  line instead of responsive `Wrap` behavior.
- Nesting vertical scroll views without explicitly choosing scroll ownership.
- Using `primary: true` together with an explicit `scrollController`.
- Generating the nonexistent `SuperFormField` widget.
- Hard-coding inline form-field heights below the design-system compact field
  size.
