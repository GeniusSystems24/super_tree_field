---
name: super-tree
description: >
  Use the super_tree_field Flutter package to build GeniusLink design-system tree /
  hierarchy views — SuperTree, a recursive, generic, keyboard-first component,
  and its flagship AccountTree (a five-level bilingual chart of accounts with
  roll-up balances, KPI summary, A = L + E balance badge, type filters, DR/CR
  nature column and ancestor-preserving search). Apply when a Flutter app needs
  a themed (light/dark, LTR/RTL) tree, an account/category/file/org hierarchy,
  or any nested data with search + keyboard navigation.
---

# Super Tree — Agent Skill

`super_tree_field` provides **`SuperTree<T>`**, a recursive keyboard-first hierarchy
component, and **`AccountTree`**, its productized chart-of-accounts instance.
The engine is generic over a node payload `T`, so the same model renders
accounts, files, org charts, or any nested data. This skill tells you how to
wire it correctly.

## When to use

- Any tree / hierarchy / nested-list UI in the GeniusLink visual language
  (dark-first ERP / accounting screens, bilingual English + Arabic).
- A chart of accounts, category tree, file explorer, org chart, or BOM.
- Anywhere you need expand/collapse + recursive search + full keyboard nav.

Do **not** hand-roll an `ExpansionTile` stack or a custom recursive `Column`
with your own expansion state — use this component so theme, keyboard model,
roll-ups and RTL come for free.

## Install & setup

```yaml
dependencies:
  super_tree_field: ^0.3.0
```

```dart
import 'package:super_tree_field/super_tree.dart';
```

Register the theme extension on your `ThemeData` (most common omission — without
it colors fall back to defaults):

```dart
theme:     ThemeData(brightness: Brightness.light, extensions: [SuperThemeData.light]),
darkTheme: ThemeData(brightness: Brightness.dark,  extensions: [SuperThemeData.dark]),
```

## The data model

Every node is a `TreeNode<T>`:

```dart
const TreeNode<AccountData>(
  code: '1111-01',                    // stable unique id + keyboard cursor key
  name: 'Al Rajhi Bank — Main',       // English / primary label
  ar: 'مصرف الراجحي — الرئيسي',        // optional Arabic label (RTL)
  value: AccountData(type: AccountType.asset, balance: 186420), // typed payload
  // children: [...]                  // omit / empty ⇒ a leaf
);
```

Rules:
- `code` must be **unique across the whole tree** — it's the expansion key and
  the keyboard cursor. Keep it stable.
- A node with no `children` is a leaf. Only leaves should carry a real metric
  (e.g. a balance); groups roll up.

## AccountTree (the flagship)

The fastest path — a complete chart-of-accounts widget:

```dart
AccountTree(
  roots: myChartOfAccounts,           // optional; defaults to AccountTreeData.tree
  onOpenAccount: (node) => openLedger(node.code),
);
```

It renders the KPI grid (assets / liabilities / equity / net income), the
`A = L + E` balance badge, type filter chips, the DR/CR nature column and
per-account share bars automatically. Use `const AccountTreeDemo()` for a
ready-to-route full page. `AccountData` carries an `AccountType` (asset,
liability, equity, income, expense — each with a color + debit/credit nature)
and a leaf `balance`.

## SuperTree (the generic engine)

Drive it from a `SuperTreeController<T>` (the Model) and render `SuperTree<T>`
(the View) with `leading` / `trailing` cell builders:

```dart
final controller = SuperTreeController<FileMeta>(
  roots: myFileTree,
  defaultExpandDepth: 0,              // groups open to this depth initially
  searchText: (n) => n.name,         // the haystack the search matches
  onOpenLeaf: (n) => open(n),        // optional: leaf opened (Enter / tap)
);

SuperTree<FileMeta>(
  controller: controller,
  title: 'Project files',
  subtitle: 'folders roll up a child count, files show size',
  titleIcon: Icons.folder_open,
  nameColumnLabel: 'Name',
  trailingColumnLabel: 'Size',
  placeholder: 'Search files…   ( / )',
  samples: const ['.dart', 'docs'],  // quick-search chips
  unit: 'files',                      // count badge noun
  showArabic: false,                  // hide the Arabic label column
  leadingBuilder: (context, node, info) => Icon(/* type icon */),
  trailingBuilder: (context, node, info) => node.value!.isDir ? null : Text(/* meta */),
);
```

- `leadingBuilder` fills the cell after the twisty (a type dot, file icon,
  avatar). `info` gives `depth`, `open`, `hasChildren`.
- `trailingBuilder` fills the right side (balance, size, role badge); return
  `null` for none.
- Group rows show a leaf-count badge automatically (toggle with
  `showLeafCount`). The name is highlighted on search by the engine.
- Use `above:` for content over the toolbar (a KPI grid) and `toolbarExtra:` for
  an extra toolbar row (filter chips) — this is exactly how `AccountTree` is
  composed.

## Keyboard model (automatic)

The user clicks the tree to focus it, then: `↑ ↓` move · `→` expand / step-in ·
`←` collapse / step-out (both **RTL-mirrored**) · `Home`/`End` first/last ·
`Enter`/`Space` open-leaf / toggle-group · `/` focus search · `Esc` clear
search · `*`/`\` expand-all / collapse-all · right-click node menu · `?`
cheatsheet. Don't reimplement this — it ships in `SuperTree`.

## Selection (checkbox)

Render a checkbox on every row by setting `selectionMode` on the controller:

```dart
final controller = SuperTreeController<Permission>(
  roots: myTree,
  searchText: (n) => n.name,
  selectionMode: SuperTreeSelectionMode.multi,   // none (default) · single · multi
  initialChecked: const {'acc.view'},            // seed the checked set
  onSelectionChanged: (checked) => save(checked), // fires with checked leaf codes
);
```

| Mode | Behaviour |
|---|---|
| `none` | No checkboxes (default) — existing trees are unaffected. |
| `single` | Radio-like: at most one checkbox on at a time (any node), drawn as a checkbox. |
| `multi` | Many checkboxes; checking a group cascades to its leaves; group rows show a **tristate** (`TreeCheckState.checked / partial / unchecked`); the header gets a master select-all. |

Leaves are the source of truth — a group's state is always derived, never stored,
so parent and children can't disagree. Read / drive it from the controller:
`checkState(code)`, `isChecked(code)`, `rootCheckState`, `checked`,
`checkedCount`, `checkedNodes`, `toggleChecked(node)`, `toggleCheckedFocused()`,
`checkAll()` (multi), `clearChecked()`, `toggleCheckAll()`, `setChecked(codes)`.
In selection mode `Space` toggles the focused row's checkbox; tapping a checkbox
never activates the row beneath it. See the **Permission Settings** example
(`PermissionTreeDemo`) for both modes over one tree.

## Editing (editable mode)

`SuperTree` has two modes. Pass `enableEditing: true` to show a Read / Edit
toggle + Add node button; the controller's `mode` (`SuperTreeMode.readable` /
`.editable`) is the source of truth (`setMode` / `toggleMode`). The five
requested capabilities map to:

| Capability | How |
|---|---|
| Rename a node | inline field (double-purpose row), or `controller.beginRename(code)` → `commitRename` / `cancelRename` |
| Add sibling before / after | context menu, or `controller.addSiblingBefore(code)` / `addSiblingAfter(code)` |
| Add a child | context menu, or `controller.addChild(code)` (a leaf becomes a group) |
| Move a node + its children (drag-and-drop) | drag the row handle onto a target's before / inside / after zone, or `controller.moveNode(dragCode, targetCode, DropPosition)` |
| Delete a node + its children | context menu, or `controller.deleteNode(code)` |

Readable mode still gets a right-click **context menu** (Open / Expand /
Collapse / Expand subtree) and click-to-toggle — both built in.

New nodes for the "add" actions come from an optional `newNodeBuilder: (code) =>
TreeNode<T>(...)` on the controller — supply it so added nodes carry a sensible
`value`. Persist edits via `onTreeChanged: (roots) { … }`. All mutations are
pure immutable transforms in `TreeLogic` (`moveNode` / `insertChild` /
`insertSibling` / `removeNode` / `mapNode`, guarded by `isWithin` so a node can
never be dropped into its own subtree).

## Search

Recursive and ancestor-preserving: a node is kept if it (or any descendant)
matches `searchText`; a match keeps its whole subtree so the path stays visible;
every branch is forced open while searching. Drive it from the controller:
`setQuery(q)`, `matchCount`, `clearQuery()`. The flagship type filter calls
`controller.setRoots(...)` to swap the visible roots.

## Roll-ups

`TreeLogic.rollup(node, (leaf) => metric)` sums a numeric metric over leaves so
groups never double-count. `TreeLogic.leafCount` powers the count badge. These
are pure functions — reuse them for totals outside the widget.

## Architecture (when extending)

Clean Architecture per feature under `lib/src/features/super_tree_field/`:
`data/` (the sample chart-of-accounts datasource) · `domain/` (`TreeNode`,
`AccountData` entities; `TreeLogic` usecases — pure Dart) · `presentation/`
(`controllers/` = `SuperTreeController` Model as a `ChangeNotifier`, `widgets/`
+ `pages/` = View). Shared tokens/widgets live in `lib/src/core/`. Add new tree
algorithms in `domain/usecases/tree_logic.dart`; keep the controller widget-free.

## Common mistakes

- Forgetting to register `SuperThemeData` → the tree looks unstyled.
- Non-unique `TreeNode.code` → broken expansion and keyboard cursor; codes must
  be globally unique. (The `addRoot`/`addChild`/`addSibling*` helpers mint unique
  codes for you.)
- Editing without a `newNodeBuilder` → added nodes have a null `value`; your
  leading/trailing builders must tolerate that, or supply the builder.
- Expecting drag-and-drop while a search query is active → editing affordances
  are intentionally hidden during search (the filtered tree is a projection).
- Putting a balance on a group node → totals double-count. Only leaves carry a
  metric; groups roll up via `TreeLogic.rollup`.
- Mutating the roots list in place instead of `controller.setRoots(...)` → no
  rebuild.
- Expecting a group's checkbox in **multi** mode to be storable on its own — it
  isn't; group tristate is derived from leaf codes, so `checked` returns leaf
  codes only. (Single mode stores the one selected code, which may be a group.)
- Expecting keyboard nav before the tree has focus — the user (or a row tap)
  must focus the tree body first; `SuperTree` focuses it on row tap for you.
