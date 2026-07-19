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

/// Sentinel so [TreeNode.copyWith] can distinguish "omitted" from "set to null"
/// for the nullable [ar] / [value] / [children] fields.
const Object _unset = Object();

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
  TreeNode<T> withChildren(List<TreeNode<T>>? next) =>
      TreeNode<T>(code: code, name: name, ar: ar, value: value, children: next);

  /// A copy with selected fields overridden. Omitted args are left untouched;
  /// pass `null` explicitly to clear a nullable field. Used by the edit ops.
  TreeNode<T> copyWith({
    String? code,
    String? name,
    Object? ar = _unset,
    Object? value = _unset,
    Object? children = _unset,
  }) => TreeNode<T>(
    code: code ?? this.code,
    name: name ?? this.name,
    ar: identical(ar, _unset) ? this.ar : ar as String?,
    value: identical(value, _unset) ? this.value : value as T?,
    children: identical(children, _unset)
        ? this.children
        : children as List<TreeNode<T>>?,
  );

  /// A copy with new labels — the inline-rename path. Passing `null` for [ar]
  /// leaves the Arabic label unchanged; pass an empty string to clear it.
  TreeNode<T> renamed(String name, {String? ar}) =>
      copyWith(name: name, ar: ar ?? this.ar);

  @override
  bool operator ==(Object other) => other is TreeNode<T> && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
