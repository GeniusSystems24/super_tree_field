// ============================================================
// features/super_tree_field/super_tree.dart
// ------------------------------------------------------------
// Public barrel for the SuperTree feature.
//
// A recursive, generic hierarchy component. The flagship instance is
// `AccountTree` — a five-level bilingual chart of accounts with roll-up
// balances, KPI summary, a live A = L + E balance badge, type filters, a
// recursive ancestor-preserving search, full keyboard control and a DR/CR
// nature column. The engine (`SuperTree<T>` + `SuperTreeController<T>` +
// `TreeLogic`) is generic over any node payload — reskin it for files, org
// charts, categories, or any nested data.
// ============================================================

// Domain — entities
export 'domain/entities/tree_node.dart';
export 'domain/entities/account_data.dart';

// Domain — usecases
export 'domain/usecases/tree_logic.dart';

// Data — sample datasource
export 'data/datasources/account_tree_data.dart';

// Presentation — controller (the Model)
export 'presentation/controllers/super_tree_controller.dart';

// Presentation — widgets (the View)
export 'presentation/widgets/highlight_text.dart';
export 'presentation/widgets/nature_pill.dart';
export 'presentation/widgets/kpi_card.dart';
export 'presentation/widgets/shortcuts_help.dart';
export 'presentation/widgets/tree_context_menu.dart';
export 'presentation/widgets/tree_row.dart';
export 'presentation/widgets/super_tree.dart';
export 'presentation/widgets/account_tree.dart';

// Presentation — pages
export 'presentation/pages/super_tree_demo.dart';
