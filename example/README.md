# super_tree_field example

Interactive gallery for `super_tree_field`.

The example app demonstrates the same `SuperTree<T>` engine with different
payloads and interaction models:

- **Account Tree** — chart of accounts, KPI summaries, roll-up balances, DR/CR
  nature, filters, and editing.
- **File Explorer** — editable `TreeNode<FileMeta>` hierarchy with file metadata.
- **Org Chart** — editable `TreeNode<Person>` hierarchy with headcount roll-ups.
- **Permission Settings** — single and multi checkbox selection with tristate
  groups.
- **Product Tree** — bilingual product catalog with category branches plus SKU,
  unit, price, and stock metadata.
- **Scroll Configuration** — the scroll API, including the distinction
  between `controller` (`SuperTreeController<T>`) and `scrollController`
  (`ScrollController`).

## Run

From the package root:

```bash
cd example
flutter pub get
flutter run
```

## Scroll examples

Existing page-scroll demos explicitly make the outer `SingleChildScrollView`
own vertical scrolling:

```dart
SuperTree<FileMeta>(
  controller: _controller,
  shrinkWrap: true,
  primary: false,
  physics: const NeverScrollableScrollPhysics(),
  leadingBuilder: buildLeading,
);
```

`scroll_tree_demo.dart` shows the opposite arrangement: `SuperTree` receives a
bounded height and its internal row list owns scrolling through a separate
`ScrollController`. The example `MaterialApp` also sets `restorationScopeId` so
the demo's `restorationId` participates in Flutter state restoration.

## External tree controls

`SuperTree` itself renders only the hierarchy. The example screens compose
search, sample queries, edit mode, Add node, help, Expand all, and Collapse
with the package's public `SuperTreeControls<T>` and
`SuperTreeController<T>` APIs.

The chart-of-accounts implementation is example-only. None of its domain
types or presentation helpers are exported by `super_tree_field`.

## Chart of accounts example

All accounting-specific code intentionally lives in `example/lib/`, not in the
published package API:

- `account_data.dart` — account payload, type, and DR/CR nature.
- `account_tree_data.dart` — sample chart-of-accounts hierarchy.
- `kpi_card.dart` — financial KPI presentation helper.
- `nature_pill.dart` — DR/CR presentation helper.
- `account_tree.dart` — `SuperTree<AccountData>` composition.
- `super_tree_demo.dart` — ready-to-route demo page.

This separation is deliberate: `super_tree_field` itself contains no account
model, accounting widget, financial formatter, debit/credit semantics, or
chart-of-accounts composition.

The account example demonstrates how a host application can build a specialized
tree without adding domain assumptions to the generic package:

```dart
SuperTree<AccountData>(
  controller: controller,
  leadingBuilder: buildAccountLeading,
  trailingBuilder: buildAccountTrailing,
);
```

The KPI summary, account filters, balance calculations, DR/CR indicators, and
sample data are all composed outside `SuperTree`.

