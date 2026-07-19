# super_tree_field

A **GeniusLink design-system** Flutter package providing **`SuperTree`** — a recursive, generic, keyboard-first hierarchy component.

The flagship instance is **`AccountTree`**: a five-level bilingual (English + Arabic) chart of accounts with **roll-up balances**, a financial-summary **KPI grid**, a live **A = L + E balance badge**, **type filters**, an ancestor-preserving **recursive search**, a **DR/CR nature column**, and per-account **share bars** — all under full keyboard control.

The underlying engine (`SuperTree<T>` + `SuperTreeController<T>` + `TreeLogic`) is **generic over a node payload `T`**, so the same model reskins for files, org charts, categories — any nested data. The `example/` app ships all three.

A faithful Dart port of the React `super-tree` tool. Light + dark themes, LTR + RTL.

---

## Install

```yaml
# pubspec.yaml
dependencies:
  super_tree: ^0.4.2
```

```dart
import 'package:super_tree/super_tree.dart';
```

### Register the theme extension

`SuperTree` themes through a `ThemeExtension`. Register it once on your `ThemeData` so colors track light/dark:

```dart
MaterialApp(
  theme:     ThemeData(brightness: Brightness.light, extensions: [SuperThemeData.light]),
  darkTheme: ThemeData(brightness: Brightness.dark,  extensions: [SuperThemeData.dark]),
);
```

> Fonts: the design system uses Manrope (display), Inter (body), JetBrains Mono (numerics) and Noto Naskh Arabic. Drop the `.ttf` files under `assets/fonts/` and uncomment the `fonts:` block in `pubspec.yaml` to match it exactly; otherwise platform defaults are used.

---

## Quick start — the flagship AccountTree

```dart
import 'package:super_tree/super_tree.dart';

// uses the bundled sample chart of accounts (AccountTreeData.tree)
AccountTree(
  onOpenAccount: (node) => debugPrint('open ledger ${node.code}'),
);

// …or a full page, ready to route:
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const AccountTreeDemo()),
);
```

Pass your own data with `AccountTree(roots: myChartOfAccounts)`, where each node is a `TreeNode<AccountData>`.

---

## Quick start — the generic engine

`SuperTree<T>` is generic over any payload. Give it a controller, a `searchText` accessor, and `leading` / `trailing` cell builders:

```dart
class FileMeta {
  const FileMeta(this.kind, {this.size});
  final String kind;
  final String? size;
}

final controller = SuperTreeController<FileMeta>(
  roots: myFileTree,                       // List<TreeNode<FileMeta>>
  defaultExpandDepth: 0,                    // groups open to this depth initially
  searchText: (n) => n.name,                // what the search matches against
);

SuperTree<FileMeta>(
  controller: controller,
  title: 'Project files',
  subtitle: 'folders roll up a child count, files show size',
  titleIcon: Icons.folder_open,
  nameColumnLabel: 'Name',
  trailingColumnLabel: 'Size',
  placeholder: 'Search files…   ( / )',
  samples: const ['.dart', 'docs', 'README'],
  unit: 'files',
  showArabic: false,
  leadingBuilder: (context, node, info) =>
      Icon(node.value!.kind == 'dir' ? Icons.folder : Icons.code, size: 15),
  trailingBuilder: (context, node, info) =>
      node.value!.kind == 'dir' ? null : Text(node.value!.size ?? ''),
);
```

`TreeNode<T>` carries a stable `code` (id + cursor key), an English `name`, an optional Arabic `ar`, an optional typed `value`, and optional `children` (null/empty ⇒ a leaf).

---

## Keyboard model

Click the tree to focus it, then:

| Key | Action |
|---|---|
| `↑` / `↓` | move between visible rows |
| `→` | expand a group · step into its first child (mirrored under RTL) |
| `←` | collapse a group · step out to its parent (mirrored under RTL) |
| `Home` / `End` | jump to the first / last visible row |
| `Enter` / `Space` | open a leaf · toggle a group (`Space` toggles the checkbox in selection mode) |
| `/` | focus the search field |
| `Esc` | clear the search |
| `*` / `\` | expand all · collapse all |
| right-click | open the node context menu |
| `?` | open the keyboard cheatsheet |

Arrow direction is resolved **visually** — under RTL, `→` and `←` swap so the key that steps *toward children* always points inward.

---

## Selection (checkboxes)

`SuperTree` can render a checkbox on every row. Set `selectionMode` on the
controller:

```dart
final controller = SuperTreeController<Permission>(
  roots: myTree,
  searchText: (n) => n.name,
  selectionMode: SuperTreeSelectionMode.multi,   // none (default) · single · multi
  initialChecked: const {'acc.view', 'acc.create'},
  onSelectionChanged: (checked) => save(checked), // fires with the checked leaf codes
);
```

- **`single`** — radio-like: at most one checkbox is on at a time (any node),
  still drawn as a checkbox.
- **`multi`** — many checkboxes. Checking a **group** cascades to every
  descendant leaf, and each group row shows a **tristate** — checked, a dash for
  **partial**, or unchecked — derived from its leaves. The column header gains a
  master **select-all** checkbox.
- **`none`** (default) — no checkboxes.

Leaves are the single source of truth, so a group's state always agrees with its
children. In selection mode `Space` toggles the focused row's checkbox; tapping a
checkbox never opens/expands the row beneath it.

Read and drive selection from the controller:

```dart
controller.checkState(code);   // TreeCheckState.checked / partial / unchecked
controller.isChecked(code);    // fully checked?
controller.checked;            // Set<String> of checked leaf codes
controller.checkedCount;       // how many
controller.checkedNodes;       // resolved TreeNode<T>s
controller.toggleChecked(node);
controller.checkAll();         // multi only
controller.clearChecked();
controller.setChecked(codes);  // host-driven
```

---

## Editing

`SuperTree` has two modes (`SuperTreeMode.readable` / `.editable`). Opt into
editing UI with `enableEditing: true` — that surfaces a **Read / Edit** toggle
and an **Add node** button in the toolbar. The controller's `mode` is the source
of truth; flip it programmatically with `controller.setMode(...)` /
`toggleMode()`.

**In editable mode each row gains:**

- **Inline rename** — `Enter` or blur commits, `Esc` cancels.
- **Add child / add sibling above / below** — via the context menu; new nodes
  are minted by your `newNodeBuilder` and opened for rename.
- **Drag-and-drop** — grab the drag handle; a live indicator shows whether the
  drop lands **before**, **inside**, or **after** the target. Dropping a node
  into its own subtree is rejected.
- **Delete** — removes the node and its whole subtree.

**Context menu** — right-click (or long-press, or the hover `⋮` button) opens a
themed menu that adapts to the mode: Open / Expand / Collapse / Expand subtree in
readable mode; Rename · Add child · Add sibling above / below · Delete in
editable mode.

```dart
final controller = SuperTreeController<FileMeta>(
  roots: myFileTree,
  searchText: (n) => n.name,
  mode: SuperTreeMode.editable,                 // start in edit mode (optional)
  newNodeBuilder: (code) =>                      // payload for "add" actions
      TreeNode<FileMeta>(code: code, name: 'new_folder', value: const FileMeta('dir')),
  onTreeChanged: (roots) => persist(roots),      // called after every edit
);

SuperTree<FileMeta>(
  controller: controller,
  enableEditing: true,                           // show the Read/Edit toggle + Add node
  // … builders as before …
);
```

All edits are also available as controller methods (drive them from your own UI
if you'd rather not use the built-in menu): `beginRename` / `commitRename` /
`cancelRename`, `addChild`, `addSiblingBefore`, `addSiblingAfter`, `addRoot`,
`deleteNode`, and `moveNode(dragCode, targetCode, DropPosition)`. Every mutation
is an immutable transform under the hood (`TreeLogic.moveNode`, `insertChild`,
`removeNode`, …), so the previous tree is never aliased.

---

## Search

The search is recursive and **ancestor-preserving**: a node is kept if it (or any descendant) matches, and a match keeps its whole subtree, so the path to every hit stays visible. A live match count shows in the field; matches are highlighted inline. While searching, every branch is forced open. Drive it programmatically:

```dart
controller.setQuery('Bank');   // filter
controller.matchCount;          // → number of matching nodes
controller.clearQuery();        // reset
```

---

## Roll-up balances (AccountTree)

Only **leaves** carry an explicit `balance`; every group total rolls up from its children via `TreeLogic.rollup`, so figures reconcile with no double-counting. The KPI grid totals each account type, and the badge verifies **Assets = Liabilities + Equity**. The per-row share bar shows each account's size relative to its root.

---

## Architecture

Clean Architecture, MVC-aligned, split per feature:

```
lib/
├── super_tree.dart                       # public barrel — import this
└── src/
    ├── core/                             # shared tokens, widgets, utils, extensions
    └── features/
        └── super_tree/
            ├── data/
            │   └── datasources/          # AccountTreeData (sample chart of accounts)
            ├── domain/
            │   ├── entities/             # TreeNode<T>, AccountData / AccountType
            │   └── usecases/             # TreeLogic (flatten, filter, parentOf, rollup)
            └── presentation/
                ├── controllers/          # SuperTreeController<T>  (the Model/state)
                ├── widgets/              # SuperTree, TreeRow, AccountTree, atoms (the View)
                └── pages/                # AccountTreeDemo
```

- **Model** — `SuperTreeController<T>` is a `ChangeNotifier` holding all state (expansion set, query, focus cursor, selection) and the keyboard intent methods. It imports no widget.
- **View** — `SuperTree<T>` / `TreeRow<T>` observe the controller and render; they forward intents back.
- **Domain** — `TreeNode`, `AccountData` and `TreeLogic` are pure Dart with no Flutter UI.

---

## Example

A runnable gallery lives in `example/` — it registers the theme extension, toggles light/dark and LTR/RTL, and links three demos that share **one** engine:

```bash
cd example
flutter run
```

- **Account Tree** — the flagship `SuperTree<AccountData>` (KPIs · balance · DR/CR).
- **File Explorer** — `SuperTree<FileMeta>`.
- **Org Chart** — `SuperTree<Person>`.
- **Permission Settings** — `SuperTree<Permission>` with single + multi checkbox selection.

---

## License

Internal GeniusLink design-system package.
