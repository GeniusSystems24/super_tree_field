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

/// Interaction mode for a [SuperTree].
///
/// * [readable]  — navigate, search, expand/collapse, open leaves, right-click
///                 context menu. The tree is immutable.
/// * [editable]  — everything above plus inline rename, add child / sibling,
///                 delete subtree and drag-and-drop reordering.
enum SuperTreeMode { readable, editable }

class SuperTreeController<T> extends ChangeNotifier {
  SuperTreeController({
    required List<TreeNode<T>> roots,
    required this.searchText,
    int defaultExpandDepth = 1,
    String query = '',
    SuperTreeMode mode = SuperTreeMode.readable,
    this.onOpenLeaf,
    this.onTreeChanged,
    TreeNode<T> Function(String code)? newNodeBuilder,
  })  : _roots = roots,
        _query = query,
        _mode = mode,
        _newNodeBuilder = newNodeBuilder {
    _expanded = TreeLogic.groupCodes(roots, maxDepth: defaultExpandDepth).toSet();
  }

  /// Derives the searchable text for a node (code + names, role + dept, …).
  final SearchText<T> searchText;

  /// Called when a leaf is opened (Enter / click / tap). Selection is tracked
  /// regardless; this is the host's hook to open a ledger / file / profile.
  final void Function(TreeNode<T> node)? onOpenLeaf;

  /// Called after every structural edit (rename / add / delete / move) with the
  /// new roots — the host's hook to persist the mutated tree.
  final void Function(List<TreeNode<T>> roots)? onTreeChanged;

  /// Mints a fresh node for the "add" actions. Defaults to an untitled leaf.
  final TreeNode<T> Function(String code)? _newNodeBuilder;

  List<TreeNode<T>> _roots;
  late Set<String> _expanded;
  String _query;
  String? _focusId;
  String? _selected;
  SuperTreeMode _mode;
  String? _editingId;
  int _seq = 0;

  // ── reads ──
  List<TreeNode<T>> get roots => _roots;
  String get query => _query;
  String? get focusId => _focusId;
  String? get selected => _selected;

  /// The current interaction mode.
  SuperTreeMode get mode => _mode;
  bool get isEditable => _mode == SuperTreeMode.editable;

  /// The node currently being inline-renamed, or null.
  String? get editingId => _editingId;
  bool isEditing(String code) => _editingId == code;

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

  // ── mode ──
  void setMode(SuperTreeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    if (mode == SuperTreeMode.readable) _editingId = null;
    notifyListeners();
  }

  void toggleMode() =>
      setMode(_mode == SuperTreeMode.editable ? SuperTreeMode.readable : SuperTreeMode.editable);

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

  /// Expand [code] and every group within its subtree (readable-mode menu).
  void expandSubtree(String code) {
    final node = TreeLogic.findNode(_roots, code);
    if (node == null || !node.hasChildren) return;
    _expanded.add(code);
    _expanded.addAll(TreeLogic.groupCodes([node]));
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

  // ── editing (editable mode) ───────────────────────────────────────
  // Each mutation builds a NEW immutable forest via TreeLogic, swaps it in, and
  // notifies the host through [onTreeChanged].

  void _commit(List<TreeNode<T>> next) {
    _roots = next;
    notifyListeners();
    onTreeChanged?.call(next);
  }

  TreeNode<T> _mint() {
    final code = 'node-${DateTime.now().millisecondsSinceEpoch}-${_seq++}';
    return _newNodeBuilder?.call(code) ?? TreeNode<T>(code: code, name: 'New node');
  }

  // — inline rename —
  void beginRename(String code) {
    if (!isEditable) return;
    _editingId = code;
    _focusId = code;
    notifyListeners();
  }

  void cancelRename() {
    if (_editingId == null) return;
    _editingId = null;
    notifyListeners();
  }

  /// Commit new labels for [code]. A blank [name] is ignored (rename cancelled).
  void commitRename(String code, String name, {String? ar}) {
    final trimmed = name.trim();
    _editingId = null;
    if (trimmed.isEmpty) {
      notifyListeners();
      return;
    }
    _commit(TreeLogic.mapNode(_roots, code, (n) => n.renamed(trimmed, ar: ar)));
  }

  // — add —
  /// Append a fresh child under [parentCode], expand it, select + rename it.
  TreeNode<T> addChild(String parentCode) {
    final node = _mint();
    _expanded.add(parentCode);
    _commit(TreeLogic.insertChild(_roots, parentCode, node));
    _selectAndRename(node.code);
    return node;
  }

  /// Insert a fresh sibling before [code], then select + rename it.
  TreeNode<T> addSiblingBefore(String code) {
    final node = _mint();
    _commit(TreeLogic.insertSibling(_roots, code, node, after: false));
    _selectAndRename(node.code);
    return node;
  }

  /// Insert a fresh sibling after [code], then select + rename it.
  TreeNode<T> addSiblingAfter(String code) {
    final node = _mint();
    _commit(TreeLogic.insertSibling(_roots, code, node, after: true));
    _selectAndRename(node.code);
    return node;
  }

  void _selectAndRename(String code) {
    _focusId = code;
    _editingId = code;
    notifyListeners();
  }

  /// Append a fresh top-level node, then select + rename it.
  TreeNode<T> addRoot() {
    final node = _mint();
    _commit([..._roots, node]);
    _selectAndRename(node.code);
    return node;
  }

  // — delete —
  /// Delete [code] and its whole subtree. Focus moves to the parent if any.
  void deleteNode(String code) {
    final parent = TreeLogic.parentOf(_roots, code);
    if (_selected == code) _selected = null;
    if (_editingId == code) _editingId = null;
    if (_focusId == code) _focusId = parent?.code;
    _expanded.remove(code);
    _commit(TreeLogic.removeNode(_roots, code));
  }

  // — move (drag & drop) —
  /// Move [dragCode] relative to [targetCode] per [pos]. No-op for illegal
  /// drops (onto itself or into its own subtree). Opens the target on `inside`.
  void moveNode(String dragCode, String targetCode, DropPosition pos) {
    final next = TreeLogic.moveNode(_roots, dragCode, targetCode, pos);
    if (identical(next, _roots)) return; // illegal move — unchanged
    if (pos == DropPosition.inside) _expanded.add(targetCode);
    _commit(next);
  }

  /// Whether dropping [dragCode] onto [targetCode] is permitted.
  bool canDrop(String dragCode, String targetCode) =>
      dragCode != targetCode && !TreeLogic.isWithin(_roots, dragCode, targetCode);
}