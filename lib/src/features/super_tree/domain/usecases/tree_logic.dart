// ============================================================
// features/super_tree/domain/usecases/tree_logic.dart
// ------------------------------------------------------------
// Pure, widget-free algorithms for any [TreeNode] hierarchy — a 1:1 port of the
// React engine atoms (flattenVisible / parentOf / filterTree / countMatches /
// leafCount / groupCodes) plus a generic numeric roll-up. The controller and
// the keyboard model call these; they never touch Flutter.
// ============================================================

import '../entities/tree_node.dart';

/// Derives the searchable haystack for a node (e.g. `'${n.code} ${n.name}'`).
typedef SearchText<T> = String Function(TreeNode<T> node);

/// Reads a leaf's numeric metric for a [rollup] (e.g. an account balance).
typedef LeafValue<T> = double Function(TreeNode<T> node);

/// Stateless tree algorithms. Never instantiated.
abstract final class TreeLogic {
  /// Total number of leaves under [node] (1 for a leaf itself).
  static int leafCount<T>(TreeNode<T> node) => node.hasChildren
      ? node.children!.fold(0, (s, c) => s + leafCount(c))
      : 1;

  /// Sums [node] over its leaves via [leafValue]; groups roll up their children
  /// so every figure reconciles with no double-counting.
  static double rollup<T>(TreeNode<T> node, LeafValue<T> leafValue) =>
      node.hasChildren
          ? node.children!.fold(0.0, (s, c) => s + rollup(c, leafValue))
          : leafValue(node);

  /// The codes of every group node at depth ≤ [maxDepth] (default: all groups).
  /// Used to seed / drive expand-all and the default expansion depth.
  static List<String> groupCodes<T>(
    List<TreeNode<T>> nodes, {
    int maxDepth = 1 << 30,
    int depth = 0,
  }) {
    final out = <String>[];
    void walk(List<TreeNode<T>> ns, int d) {
      for (final n in ns) {
        if (n.hasChildren) {
          if (d <= maxDepth) out.add(n.code);
          walk(n.children!, d + 1);
        }
      }
    }

    walk(nodes, depth);
    return out;
  }

  /// Recursive search filter: keeps a node if it (or any descendant) matches
  /// [query] under [searchText]. A matched node keeps its whole subtree; an
  /// unmatched group is kept (pruned to matching children) so ancestors of a
  /// match stay visible.
  static List<TreeNode<T>> filter<T>(
    List<TreeNode<T>> nodes,
    String query,
    SearchText<T> searchText,
  ) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return nodes;

    TreeNode<T>? walk(TreeNode<T> n) {
      final self = searchText(n).toLowerCase().contains(needle);
      if (self) return n; // keep the whole subtree under a match
      if (n.hasChildren) {
        final kids = n.children!.map(walk).whereType<TreeNode<T>>().toList();
        if (kids.isNotEmpty) return n.withChildren(kids);
      }
      return null;
    }

    return nodes.map(walk).whereType<TreeNode<T>>().toList();
  }

  /// Counts every node whose [searchText] contains [query] (the match badge).
  static int countMatches<T>(
    List<TreeNode<T>> nodes,
    String query,
    SearchText<T> searchText,
  ) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return 0;
    var n = 0;
    void walk(TreeNode<T> node) {
      if (searchText(node).toLowerCase().contains(needle)) n++;
      node.children?.forEach(walk);
    }

    nodes.forEach(walk);
    return n;
  }

  /// Flattens the currently-*visible* nodes (respecting [expanded] and the
  /// search override [searching]) into render / keyboard-navigation order.
  static List<TreeNode<T>> flattenVisible<T>(
    List<TreeNode<T>> nodes,
    Set<String> expanded,
    bool searching,
  ) {
    final out = <TreeNode<T>>[];
    void walk(List<TreeNode<T>> ns) {
      for (final n in ns) {
        out.add(n);
        final open = searching || expanded.contains(n.code);
        if (n.hasChildren && open) walk(n.children!);
      }
    }

    walk(nodes);
    return out;
  }

  /// The parent of the node with [code], or null when it is a root / absent.
  static TreeNode<T>? parentOf<T>(List<TreeNode<T>> nodes, String code, [TreeNode<T>? parent]) {
    for (final n in nodes) {
      if (n.code == code) return parent;
      if (n.hasChildren) {
        final hit = parentOf(n.children!, code, n);
        if (hit != null) return hit;
        if (n.children!.any((c) => c.code == code)) return n;
      }
    }
    return null;
  }
}
