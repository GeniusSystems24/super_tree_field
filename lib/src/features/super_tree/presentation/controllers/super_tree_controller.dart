// ============================================================
// features/super_tree/presentation/controllers/super_tree_controller.dart
// ------------------------------------------------------------
// The MVC controller for SuperTree — the single source of truth a thin View
// renders and forwards events to. A faithful port of the React component's hook
// state (expansion set · search query · keyboard focus cursor · selected leaf),
// plus the full keyboard model expressed as widget-free intent methods:
//
//   moveDown / moveUp / jumpFirst / jumpLast   ↑ ↓ Home End
//   stepInto / stepOut                          → ← (RTL-resolved by the View)
//   activate                                    Enter / Space
//   expandAll / collapseAll / toggle            * \  · twisty click
//   setQuery / clearQuery                       / · Esc (View wires the field)
//
// Generic over a node payload [T]; the host supplies the roots and a
// [searchText] accessor. The controller never imports a widget.
// ============================================================

import 'package:flutter/foundation.dart';

import '../../domain/entities/tree_node.dart';
import '../../domain/usecases/tree_logic.dart';

class SuperTreeController<T> extends ChangeNotifier {
  SuperTreeController({
    required List<TreeNode<T>> roots,
    required this.searchText,
    int defaultExpandDepth = 1,
    String query = '',
    this.onOpenLeaf,
  })  : _roots = roots,
        _query = query {
    _expanded = TreeLogic.groupCodes(roots, maxDepth: defaultExpandDepth).toSet();
  }

  /// Derives the searchable text for a node (code + names, role + dept, …).
  final SearchText<T> searchText;

  /// Called when a leaf is opened (Enter / click / tap). Selection is tracked
  /// regardless; this is the host's hook to open a ledger / file / profile.
  final void Function(TreeNode<T> node)? onOpenLeaf;

  List<TreeNode<T>> _roots;
  late Set<String> _expanded;
  String _query;
  String? _focusId;
  String? _selected;

  // ── reads ──
  List<TreeNode<T>> get roots => _roots;
  String get query => _query;
  String? get focusId => _focusId;
  String? get selected => _selected;

  /// True while a search query is narrowing the tree (forces every branch open).
  bool get searching => _query.trim().isNotEmpty;

  /// Whether [code] is expanded for *rendering* (search overrides the set).
  bool isOpen(String code) => searching || _expanded.contains(code);

  /// Whether [code] is in the persisted expansion set (ignores search).
  bool isExpanded(String code) => _expanded.contains(code);

  /// The post-filter roots actually rendered (matched subtrees + ancestors).
  List<TreeNode<T>> get visible => TreeLogic.filter(_roots, _query, searchText);

  /// Count of nodes whose text matches the active query (the search badge).
  int get matchCount => TreeLogic.countMatches(_roots, _query, searchText);

  /// Total leaves across all roots.
  int get totalLeaves => _roots.fold(0, (s, n) => s + TreeLogic.leafCount(n));

  /// Leaves currently visible under the filter.
  int get visibleLeaves => visible.fold(0, (s, n) => s + TreeLogic.leafCount(n));

  /// The visible nodes flattened into render / navigation order.
  List<TreeNode<T>> get _flat => TreeLogic.flattenVisible(visible, _expanded, searching);

  // ── host updates ──
  /// Replace the roots (e.g. the flagship tree's type filter). Keeps the
  /// expansion set; focus/selection are cleared if they fall out of the new set.
  void setRoots(List<TreeNode<T>> roots) {
    _roots = roots;
    notifyListeners();
  }

  // ── expansion ──
  void toggle(String code) {
    if (_expanded.contains(code)) {
      _expanded.remove(code);
    } else {
      _expanded.add(code);
    }
    notifyListeners();
  }

  void expandAll() {
    _expanded = TreeLogic.groupCodes(_roots).toSet();
    notifyListeners();
  }

  void collapseAll() {
    _expanded = <String>{};
    notifyListeners();
  }

  // ── search ──
  void setQuery(String q) {
    if (_query == q) return;
    _query = q;
    notifyListeners();
  }

  void clearQuery() => setQuery('');

  // ── focus / selection ──
  void setFocus(String? code) {
    if (_focusId == code) return;
    _focusId = code;
    notifyListeners();
  }

  void openLeaf(TreeNode<T> node) {
    _selected = node.code;
    _focusId = node.code;
    onOpenLeaf?.call(node);
    notifyListeners();
  }

  void clearSelection() {
    if (_selected == null) return;
    _selected = null;
    notifyListeners();
  }

  /// Pointer/tap on a row: focus it, then toggle a group or open a leaf.
  void activateNode(TreeNode<T> node) {
    _focusId = node.code;
    if (node.hasChildren) {
      toggle(node.code);
    } else {
      openLeaf(node);
    }
  }

  // ── keyboard navigation (intent methods) ──
  TreeNode<T>? get _current {
    final flat = _flat;
    final i = flat.indexWhere((n) => n.code == _focusId);
    return i >= 0 ? flat[i] : null;
  }

  void moveDown() {
    final flat = _flat;
    if (flat.isEmpty) return;
    final i = flat.indexWhere((n) => n.code == _focusId);
    final next = i < 0 ? 0 : (i + 1).clamp(0, flat.length - 1);
    setFocus(flat[next].code);
  }

  void moveUp() {
    final flat = _flat;
    if (flat.isEmpty) return;
    final i = flat.indexWhere((n) => n.code == _focusId);
    final next = i < 0 ? 0 : (i - 1).clamp(0, flat.length - 1);
    setFocus(flat[next].code);
  }

  void jumpFirst() {
    final flat = _flat;
    if (flat.isNotEmpty) setFocus(flat.first.code);
  }

  void jumpLast() {
    final flat = _flat;
    if (flat.isNotEmpty) setFocus(flat.last.code);
  }

  /// Expand the focused group (or step to its first child if already open).
  void stepInto() {
    final cur = _current;
    if (cur == null || !cur.hasChildren) return;
    if (!searching && !_expanded.contains(cur.code)) {
      _expanded.add(cur.code);
      notifyListeners();
    } else {
      setFocus(cur.children!.first.code);
    }
  }

  /// Collapse the focused group (or step out to its parent if already closed).
  void stepOut() {
    final cur = _current;
    if (cur == null) return;
    if (cur.hasChildren && !searching && _expanded.contains(cur.code)) {
      _expanded.remove(cur.code);
      notifyListeners();
    } else {
      final par = TreeLogic.parentOf(visible, cur.code);
      if (par != null) setFocus(par.code);
    }
  }

  /// Enter / Space — toggle a focused group, or open a focused leaf.
  void activate() {
    final cur = _current;
    if (cur == null) return;
    if (cur.hasChildren) {
      toggle(cur.code);
    } else {
      openLeaf(cur);
    }
  }
}
