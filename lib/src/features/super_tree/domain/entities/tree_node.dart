// ============================================================
// features/super_tree/domain/entities/tree_node.dart
// ------------------------------------------------------------
// The generic hierarchy node — a faithful port of the React tool's tree model.
// Every node carries a stable [code] (unique id + keyboard cursor key), an
// English [name], an optional Arabic [ar] label rendered RTL beneath it, an
// optional typed [value] payload (AccountData / FileMeta / Person …), and
// optional [children]. A node with no children is a leaf. Pure data — no
// Flutter widgets here.
// ============================================================

import 'package:flutter/foundation.dart';

/// One node in a [TreeNode] hierarchy, generic over a domain payload [T].
///
/// ```dart
/// const TreeNode<AccountData>(
///   code: '1111-01',
///   name: 'Al Rajhi Bank — Main',
///   ar: 'مصرف الراجحي — الرئيسي',
///   value: AccountData(type: AccountType.asset, balance: 186420),
/// );
/// ```
@immutable
class TreeNode<T> {
  const TreeNode({
    required this.code,
    required this.name,
    this.ar,
    this.value,
    this.children,
  });

  /// Stable unique id. Doubles as the keyboard-navigation cursor key and the
  /// expand/collapse key, so it must be unique across the whole tree.
  final String code;

  /// Primary (English / LTR) label.
  final String name;

  /// Optional secondary Arabic label, rendered RTL beneath / beside [name].
  final String? ar;

  /// Optional typed domain payload carried by this node.
  final T? value;

  /// Child nodes. `null` or empty ⇒ this is a leaf.
  final List<TreeNode<T>>? children;

  /// True when this node has at least one child (a group / branch).
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// True when this node is a leaf (no children).
  bool get isLeaf => !hasChildren;

  /// A copy with [children] replaced — used by the search filter to prune
  /// branches while preserving the rest of the node.
  TreeNode<T> withChildren(List<TreeNode<T>>? next) => TreeNode<T>(
        code: code,
        name: name,
        ar: ar,
        value: value,
        children: next,
      );

  @override
  bool operator ==(Object other) => other is TreeNode<T> && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
