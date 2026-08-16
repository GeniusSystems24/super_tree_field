# Changelog

All notable changes to **super_tree_field** are documented in this file. The
format follows [Keep a Changelog](https://keepachangelog.com/), and the package
uses [Semantic Versioning](https://semver.org/).

Earlier entries describe the API as it existed in those releases.

## [1.0.1] - 2026-08-16

### Fixed

- Updated search and inline rename focus handling for the nullable
  `SuperTextFieldController.focusNode` contract resolved by newer
  `super_form_field` releases.

---

## [1.0.0] — 2026-08-13

### Added

- Added configurable internal scrolling to `SuperTree<T>` with
  `reverse`, `scrollController`, `primary`, `physics`, `shrinkWrap`,
  `cacheExtent`, `semanticChildCount`, `dragStartBehavior`,
  `keyboardDismissBehavior`, `restorationId`, `clipBehavior`, and
  `hitTestBehavior`.
- Added `onSearchRequested` and `onShortcutsRequested` so `/` and `?` can
  delegate to UI composed outside the tree.
- Added the public `SuperTreeControls<T>` and `SuperTreeControlsController` as
  an optional responsive toolbar for search, quick queries, editing actions,
  keyboard help, and expand/collapse actions.
- Added a Product Tree example with bilingual categories and product metadata.
- Added a Scroll Configuration example covering bounded scrolling, an external
  `ScrollController`, restoration, keyboard dismissal, and scroll actions.
- Added a shared responsive example layout and applied responsive control
  wrapping across the example application.
- Added Flutter-style public API documentation coverage and enabled the
  `public_member_api_docs` lint.

### Changed

- Promoted `SuperTreeControls<T>` and `SuperTreeControlsController` from
  `example/lib/` into the package's public widget API as an optional
  responsive control bar composed outside `SuperTree`.

- **Breaking:** restored `controller` as the required
  `SuperTreeController<T>` parameter and renamed the Flutter scroll controller
  parameter to `scrollController`.
- **Breaking:** `SuperTree` now renders the hierarchy card only. Search,
  quick-query chips, Add node, Read/Edit, keyboard help, Expand all, Collapse,
  filters, and other toolbar content are composed outside the tree.
- Moved the standard external toolbar into the package as
  `SuperTreeControls<T>` while keeping it independent from the `SuperTree`
  widget tree.
- Migrated tree search and inline rename input to the real
  `super_form_field` 1.8.2 APIs: `SuperTextFormField` and
  `SuperTextFieldController`.
- Made `SuperTreeControls` responsive: the search field becomes full width on
  compact layouts, while chips and actions retain intrinsic width and wrap as
  needed.
- Updated all example screens to use responsive layouts and wrapping controls
  rather than dedicating a full row to each action.
- `SuperTree` now falls back to shrink-wrapping its internal row list when it
  receives unbounded vertical constraints, preserving nested-scroll usage.
- Standardized package, README, example, and agent-skill terminology around a
  generic hierarchy engine rather than a domain-specific tree.
- Updated README and SKILL documentation to match the final 1.0.0 API,
  controller lifecycle, scroll ownership, external controls, and architecture.

### Removed

- **Breaking:** removed the old built-in toolbar configuration from
  `SuperTree`, including `placeholder`, `samples`, `enableEditing`, `above`,
  and `toolbarExtra`.
- Removed the `scrollBehavior` and `paintOrder` scroll pass-through properties.
- Removed domain-specific hierarchy code from the package API. The specialized
  example composition, payload, dataset, page, KPI helper, and indicator helper
  now live entirely under `example/lib/`.

### Fixed

- Fixed invalid `SuperFormField` references introduced during migration by
  using the exported `SuperTextFormField` widget and its
  `SuperTextFieldController` contract.
- Fixed inline rename overflow by removing the hard-coded 26 px wrapper,
  allowing the compact form field to own its design-system height, and reducing
  row padding while editing.
- Fixed duplicate borders around the inline rename field.
- Fixed quick-query chips stretching to full-row width inside responsive
  `Wrap` layouts.

---

## [0.5.2] — 2026-08-10

### Changed

- Raised the minimum `super_core` version to **3.3.0**.
- Migrated all tree typography reads from the removed
  `SuperThemeData.textTheme` API to `context.superTextTheme`, which resolves
  the active `SuperMaterialThemeData.textTheme`.
- Updated the example app and documentation to pass the now-required
  `SuperTextTheme textTheme` and `SuperTextTheme primaryTextTheme` values to
  `SuperMaterialThemeData.light` / `dark`.
- The example now rebuilds `SuperTextTheme(isArabic: true)` when switching to
  RTL so the typography follows the selected language direction.
- Documented the `super_core 3.3.0` `_familyOf` removal: font families from
  `SuperTextTheme` are not inferred back into `SuperTokensData`; token-level
  font metadata must be configured explicitly when required.
- Updated the agent skill with the new typography access and migration rules.

---

## [0.4.0] — 2026-07-16

### Changed

- Upgraded to **super_core 1.2.0**. No source changes required — surfaces are
  read via `SuperThemeData.of(context)`, which `SuperMaterialThemeData` (now a
  `ThemeData` subclass) registers automatically, so palette, brightness **and**
  the responsive `SuperDeviceMode` (mobile / tablet / desktop) tokens flow
  through with no extra wiring:

  ```dart
  MaterialApp(
    theme:     SuperMaterialThemeData.light(mode: SuperDeviceMode.desktop),
    darkTheme: SuperMaterialThemeData.dark(mode: SuperDeviceMode.desktop),
  );
  ```

- Minimum raised to `dart >=3.8.0`, `flutter >=3.32.0`.

---

## [0.3.1] — 2026-07-14

### Changed

- Upgraded to **super_core 1.0.0**. No source changes required — tree row
  surfaces, borders, and text colors are read via `SuperThemeData.of(context)`,
  which is now auto-registered by `SuperMaterialThemeData`. Palette switching and
  light/dark mode work without any extra wiring:

  ```dart
  MaterialApp(
    theme:     SuperMaterialThemeData.light(palette: SuperPalette.grayPalette),
    darkTheme: SuperMaterialThemeData.dark(palette: SuperPalette.grayPalette),
    // SuperTree, AccountTree, File Explorer, Org Chart — all adapt automatically.
  );
  ```

- `AccountTree` KPI badges and the `A = L + E` balance indicator now resolve
  their accent from `SuperMaterialThemeData.of(context).colorScheme.primary` for full palette
  awareness.

---

## [0.3.0] — 2026-06-18

### Added

- **Checkbox selection modes** — opt in with `SuperTreeController(selectionMode: …)`:
  - **`SuperTreeSelectionMode.single`** — radio-like: at most one checkbox on at
    a time (any node), still rendered as a checkbox.
  - **`SuperTreeSelectionMode.multi`** — many checkboxes. Checking a group
    cascades to every descendant leaf; each group row shows a **tristate**
    (`TreeCheckState.checked / partial / unchecked`) derived from its leaves —
    leaves are the single source of truth, so a group can never disagree with
    its children. The column header gains a master **select-all** checkbox.
  - **`SuperTreeSelectionMode.none`** (default) — checkboxes hidden; unchanged
    behaviour for existing trees.
- Selection state + intents on `SuperTreeController`: `checkState(code)`,
  `isChecked`, `rootCheckState`, `checked` / `checkedCount` / `checkedNodes`,
  `toggleChecked(node)`, `toggleCheckedFocused()`, `checkAll` / `clearChecked` /
  `toggleCheckAll`, and host-driven `setChecked(codes)`. An `onSelectionChanged`
  callback fires with the checked leaf codes after every change; seed the
  initial state with `initialChecked`.
- **Keyboard**: in selection mode `Space` toggles the focused row's checkbox
  (`Enter` still opens a leaf / toggles a group). Cheatsheet updated.
- **UI**: a tristate `TreeCheckbox` cell on every row, a header select-all (multi
  mode), and a selection-summary footer ("N items selected · Clear").
- **`TreeLogic.leafCodes(node)`** — the leaf codes under a node (the selection
  model's truth set).
- **New example — `PermissionTreeDemo`** ("Permission Settings"): a role's
  permissions granted via checkboxes, with a Single / Multi segmented toggle
  demonstrating both modes over one `SuperTree<Permission>`. Bilingual, scoped
  by access level (View / Write / Admin) with a destructive-permission accent.

## [0.2.0] — 2026-06-17

### Added

- **Editable mode** (`SuperTreeMode.editable`) — opt in with
  `SuperTree(enableEditing: true)`, which adds a Read / Edit segmented toggle and
  an "Add node" action to the toolbar. In edit mode every row gains:
  - **Inline rename** — double-purpose edit field swaps in for the node name;
    `Enter` / blur commits, `Esc` cancels. (`beginRename` / `commitRename` /
    `cancelRename`.)
  - **Add child** and **add sibling above / below** — fresh nodes are minted via
    an optional `newNodeBuilder`, inserted, selected and opened for rename.
    (`addChild` / `addSiblingBefore` / `addSiblingAfter` / `addRoot`.)
  - **Drag-and-drop reordering** — a drag handle starts a `Draggable`; every row
    is a drop target with a live **before / inside / after** indicator. Drops
    into a node's own subtree are rejected. (`moveNode` / `canDrop`.)
  - **Delete subtree** — removes a node and all descendants. (`deleteNode`.)
  - An editable empty state that invites the first node.
- **Node context menu** — right-click (or long-press) any row to open a themed
  menu. In **readable** mode: Open / Expand / Collapse / Expand subtree. In
  **editable** mode: Rename · Add child · Add sibling above / below · Delete. A
  hover-revealed `⋮` button opens the same menu for touch / trackpad.
  (`showTreeContextMenu`.)
- **`TreeLogic`** edit algorithms (pure, immutable transforms): `findNode`,
  `isWithin`, `mapNode`, `removeNode`, `insertChild`, `insertSibling`,
  `moveNode`; plus the `DropPosition { before, inside, after }` enum.
- **`TreeNode.copyWith` / `renamed`** for non-destructive edits.
- `SuperTreeController` gains `mode` / `setMode` / `toggleMode`, an `editingId`
  cursor, an `onTreeChanged` persistence hook, and `expandSubtree`.
- The flagship **`AccountTree`** is now editable (right-click to rename / add /
  delete, drag to move). Roll-up totals, KPIs and the `A = L + E` badge
  recompute live after every edit; the type filter is paused while editing. The
  File Explorer and Org Chart examples are editable too.
- Cheatsheet adds a "Right-click → node menu" entry.

## [0.1.0] — 2026-06-16

### Added

- Initial release, extracted as a focused package from `super_toolkit` and
  ported from the React `super-tree` tool.
- **`SuperTree<T>`** — a recursive, generic, keyboard-first hierarchy view.
  Search toolbar (live filter · match count · sample chips · expand-all /
  collapse · keyboard help) over a bordered tree card (heading + column header +
  recursive rows + empty state + selection footer). Customizable via `leading` /
  `trailing` cell builders, a `searchText` accessor, accent, title/subtitle,
  column labels, sample queries and unit noun. Optional `above` (KPI grid) and
  `toolbarExtra` (filter chips) slots.
- **`SuperTreeController<T>`** — the `ChangeNotifier` Model: expansion set,
  search query, keyboard focus cursor and selected leaf, plus widget-free
  navigation intents (`moveDown`/`moveUp`/`jumpFirst`/`jumpLast`,
  `stepInto`/`stepOut`, `activate`, `expandAll`/`collapseAll`, `toggle`,
  `setQuery`/`clearQuery`, `setRoots`).
- **`AccountTree`** — the flagship instance: a five-level bilingual chart of
  accounts with roll-up balances, a financial-summary KPI grid (assets,
  liabilities, equity, net income), a live `A = L + E` balance badge, type
  filter chips (All + 5 account types), a DR/CR nature column, per-account share
  bars, and the bundled `AccountTreeData` sample dataset. `AccountTreeDemo` is a
  ready-to-route page.
- **Full keyboard model** — `↑ ↓` move, `← →` collapse/expand-or-step
  (RTL-mirrored), `Home`/`End`, `Enter`/`Space` open-leaf/toggle, `/` focus
  search, `Esc` clear, `*`/`\` expand-all/collapse-all, `?` cheatsheet.
- **Recursive ancestor-preserving search** — keeps matched subtrees and the
  path to every match; live match count and inline highlight.
- **`TreeLogic`** — pure, widget-free algorithms: `flattenVisible`, `parentOf`,
  `filter`, `countMatches`, `leafCount`, `groupCodes`, and a generic numeric
  `rollup`.
- `SuperThemeData` `ThemeExtension` with light + dark variants; full LTR + RTL
  support.
- Runnable `example/` gallery with light/dark + LTR/RTL toggles and three demos
  that share one engine (Account Tree, File Explorer, Org Chart).
- `README.md` and `SKILL.md` (agent usage guide).
