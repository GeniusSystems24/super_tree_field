# Changelog

All notable changes to **super_tree_field** are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

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
