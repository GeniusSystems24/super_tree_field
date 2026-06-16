/// Super Tree — a GeniusLink design-system Flutter package providing
/// **SuperTree**, a recursive, generic, keyboard-first hierarchy component.
///
/// The flagship instance is **AccountTree** — a five-level bilingual chart of
/// accounts with roll-up balances, a financial-summary KPI grid, a live
/// A = L + E balance badge, type filters, an ancestor-preserving recursive
/// search, a DR/CR nature column, per-account share bars, and full keyboard
/// control. The underlying engine is generic over a node payload `T`, so the
/// same model reskins for files, org charts, categories — any nested data.
///
/// Architecture: Clean Architecture per feature
///   data/        — datasources (the sample chart of accounts)
///   domain/      — entities (TreeNode, AccountData), usecases (TreeLogic) — pure Dart
///   presentation/— controllers (SuperTreeController = Model/state), widgets + pages (the View)
///
/// Shared, cross-feature code lives in `lib/src/core/`.
///
/// Import this single barrel to get everything:
///   `import 'package:super_tree/super_tree.dart';`
library super_tree;

// ── Core (theme tokens, shared widgets, utils) ──────────────────────────────
export 'src/core/core.dart';

// ── Features ────────────────────────────────────────────────────────────────
export 'src/features/super_tree/super_tree.dart';
