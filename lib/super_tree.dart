// ============================================================
// features/super_tree_field/super_tree.dart
// ------------------------------------------------------------
// Public barrel for the SuperTree feature.
//
// A recursive, generic hierarchy component. `SuperTree<T>`,
// `SuperTreeController<T>`, and `TreeLogic` are generic over any node
// payload. Domain-specific compositions belong to host applications or
// `example/lib/`, not to the package API.
// ============================================================

/// Super Tree — a GeniusLink design-system Flutter package providing
/// **SuperTree**, a recursive, generic, keyboard-first hierarchy component.
///
/// The underlying engine is generic over a node payload `T`, so the same
/// model can render files, organization charts, product catalogs, menus,
/// categories, and other nested data. Domain-specific compositions stay
/// outside the package API.

/// Architecture: Clean Architecture per feature
///   domain/      — generic TreeNode entity + TreeLogic usecases
///   presentation/— SuperTreeController state + generic tree widgets and controls
///
/// Product-specific payloads and sample data live under `example/lib/`.
///
/// Shared, cross-feature code lives in `lib/src/core/`.
///
/// Import this single barrel to get everything:
///   `import 'package:super_tree_field/super_tree.dart';`
library super_tree_field;

// ── Core (theme tokens, shared widgets, utils) ──────────────────────────────
export 'src/core/core.dart';

// Domain — generic entities
export 'src/features/super_tree/domain/entities/tree_node.dart';
// Domain — usecases
export 'src/features/super_tree/domain/usecases/tree_logic.dart';

// Presentation — controller (the Model)
export 'src/features/super_tree/presentation/controllers/super_tree_controller.dart';

// Presentation — widgets (the View)
export 'src/features/super_tree/presentation/widgets/highlight_text.dart';
export 'src/features/super_tree/presentation/widgets/shortcuts_help.dart';
export 'src/features/super_tree/presentation/widgets/tree_context_menu.dart';
export 'src/features/super_tree/presentation/widgets/tree_row.dart';
export 'src/features/super_tree/presentation/widgets/super_tree.dart';
export 'src/features/super_tree/presentation/widgets/super_tree_controls.dart';
