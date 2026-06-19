// ============================================================
// features/super_tree_field/domain/usecases/tree_logic.dart
// ------------------------------------------------------------
// Pure, widget-free algorithms for any [TreeNode] hierarchy — a 1:1 port of the
// React engine atoms (flattenVisible / parentOf / filterTree / countMatches /
// leafCount / groupCodes) plus a generic numeric roll-up. The controller and
// the keyboard model call these; they never touch Flutter.
// ============================================================

import '../entities/tree_node.dart';

/// Where a dragged node should land relative to a target during a move /
/// insert. [before] / [after] make it a sibling; [inside] makes it the last
/// child of the target group.
enum DropPosition { before, inside, after }

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

  /// Every leaf code under [node] (just `[node.code]` when it is itself a
  /// leaf). The selection model uses leaves as the source of truth, deriving
  /// each group's tristate from them.
  static List<String> leafCodes<T>(TreeNode<T> node) {
    final out = <String>[];
    void walk(TreeNode<T> n) {
      if (n.hasChildren) {
        n.children!.forEach(walk);
      } else {
        out.add(n.code);
      }
    }

    walk(node);
    return out;
  }

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

  // ── editing (pure tree transforms — each returns a NEW forest) ───────────

  /// Finds the node with [code] anywhere in the forest, or null.
  static TreeNode<T>? findNode<T>(List<TreeNode<T>> nodes, String code) {
    for (final n in nodes) {
      if (n.code == code) return n;
      if (n.hasChildren) {
        final hit = findNode(n.children!, code);
        if (hit != null) return hit;
      }
    }
    return null;
  }

  /// True when [code] is [ancestorCode] itself or lives within its subtree.
  /// Used to forbid dropping a node into its own descendants.
  static bool isWithin<T>(List<TreeNode<T>> nodes, String ancestorCode, String code) {
    if (ancestorCode == code) return true;
    final anc = findNode(nodes, ancestorCode);
    if (anc == null || !anc.hasChildren) return false;
    return findNode(anc.children!, code) != null;
  }

  /// Returns a new forest with the node matching [code] passed through [f].
  static List<TreeNode<T>> mapNode<T>(
    List<TreeNode<T>> nodes,
    String code,
    TreeNode<T> Function(TreeNode<T> node) f,
  ) {
    return [
      for (final n in nodes)
        if (n.code == code)
          f(n)
        else if (n.hasChildren)
          n.withChildren(mapNode(n.children!, code, f))
        else
          n,
    ];
  }

  /// Returns a new forest with the node matching [code] (and its subtree)
  /// removed.
  static List<TreeNode<T>> removeNode<T>(List<TreeNode<T>> nodes, String code) {
    final out = <TreeNode<T>>[];
    for (final n in nodes) {
      if (n.code == code) continue;
      out.add(n.hasChildren ? n.withChildren(removeNode(n.children!, code)) : n);
    }
    return out;
  }

  /// Returns a new forest with [child] appended to (or inserted at [index] of)
  /// the children of [parentCode]. A leaf becomes a group.
  static List<TreeNode<T>> insertChild<T>(
    List<TreeNode<T>> nodes,
    String parentCode,
    TreeNode<T> child, {
    int? index,
  }) {
    return mapNode(nodes, parentCode, (parent) {
      final kids = [...?parent.children];
      final at = (index ?? kids.length).clamp(0, kids.length);
      kids.insert(at, child);
      return parent.withChildren(kids);
    });
  }

  /// Returns a new forest with [node] inserted as a sibling [after] (or before)
  /// [targetCode], at whatever depth the target lives.
  static List<TreeNode<T>> insertSibling<T>(
    List<TreeNode<T>> nodes,
    String targetCode,
    TreeNode<T> node, {
    required bool after,
  }) {
    final i = nodes.indexWhere((n) => n.code == targetCode);
    if (i >= 0) {
      final out = [...nodes];
      out.insert(after ? i + 1 : i, node);
      return out;
    }
    return [
      for (final n in nodes)
        n.hasChildren ? n.withChildren(insertSibling(n.children!, targetCode, node, after: after)) : n,
    ];
  }

  /// Moves [dragCode] to sit relative to [targetCode] per [pos]. Returns the
  /// original forest unchanged when the move is illegal (onto itself, or into
  /// its own subtree).
  static List<TreeNode<T>> moveNode<T>(
    List<TreeNode<T>> nodes,
    String dragCode,
    String targetCode,
    DropPosition pos,
  ) {
    if (dragCode == targetCode) return nodes;
    if (isWithin(nodes, dragCode, targetCode)) return nodes; // can't drop into own subtree
    final moving = findNode(nodes, dragCode);
    if (moving == null) return nodes;
    final pruned = removeNode(nodes, dragCode);
    switch (pos) {
      case DropPosition.inside:
        return insertChild(pruned, targetCode, moving);
      case DropPosition.before:
        return insertSibling(pruned, targetCode, moving, after: false);
      case DropPosition.after:
        return insertSibling(pruned, targetCode, moving, after: true);
    }
  }
}
