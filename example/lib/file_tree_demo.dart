// ============================================================
// example/lib/file_tree_demo.dart
// ------------------------------------------------------------
// EXAMPLE 2 — the same SuperTree engine reskinned for a file explorer.
// Proves the generic value type: TreeNode<FileMeta> { kind, size, modified }.
// Folders roll up a child count; files show size + modified. A port of the
// React `FileTreeLive` example.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';

/// A file's metadata payload.
class FileMeta {
  const FileMeta(this.kind, {this.size, this.modified});
  final String kind; // dir · code · img · doc
  final String? size;
  final String? modified;
}

TreeNode<FileMeta> _dir(String code, String name, List<TreeNode<FileMeta>> children) =>
    TreeNode<FileMeta>(code: code, name: name, value: const FileMeta('dir'), children: children);

TreeNode<FileMeta> _file(String code, String name, String kind, String size, String modified) =>
    TreeNode<FileMeta>(
        code: code, name: name, value: FileMeta(kind, size: size, modified: modified));

final List<TreeNode<FileMeta>> _fileTree = [
  _dir('lib', 'lib', [
    _dir('lib/ds', 'design_system', [
      _file('lib/ds/tree.dart', 'tree.dart', 'code', '33 KB', 'today'),
      _file('lib/ds/tree_controller.dart', 'tree_controller.dart', 'code', '14 KB', 'today'),
      _file('lib/ds/tree_models.dart', 'tree_models.dart', 'code', '8.8 KB', 'today'),
      _file('lib/ds/tree_theme.dart', 'tree_theme.dart', 'code', '5.5 KB', '2 d'),
    ]),
    _file('lib/barrel.dart', 'super_tree.dart', 'code', '0.8 KB', '2 d'),
  ]),
  _dir('example', 'example', [
    _dir('ex/lib', 'lib', [
      _file('ex/lib/tree_demo.dart', 'account_tree_demo.dart', 'code', '44 KB', 'today'),
      _file('ex/lib/data.dart', 'account_tree_data.dart', 'code', '9.8 KB', 'today'),
      _file('ex/lib/main.dart', 'main.dart', 'code', '21 KB', '1 h'),
    ]),
  ]),
  _dir('docs', 'docs', [
    _file('docs/tree.html', 'components-tree.html', 'doc', '24 KB', 'today'),
    _file('docs/logo', 'logo-mark.png', 'img', '12 KB', '4 d'),
  ]),
  _file('readme', 'README.md', 'doc', '18 KB', '1 h'),
];

class FileTreeDemo extends StatefulWidget {
  const FileTreeDemo({super.key});

  @override
  State<FileTreeDemo> createState() => _FileTreeDemoState();
}

class _FileTreeDemoState extends State<FileTreeDemo> {
  late final SuperTreeController<FileMeta> _controller = SuperTreeController<FileMeta>(
    roots: _fileTree,
    defaultExpandDepth: 0,
    searchText: (n) => n.name,
    newNodeBuilder: (code) => TreeNode<FileMeta>(
        code: code, name: 'new_folder', value: const FileMeta('dir')),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static (IconData, Color) _icon(BuildContext context, FileMeta m, bool open) {
    switch (m.kind) {
      case 'dir':
        return (open ? Icons.folder_open : Icons.folder, SuperTokens.accent);
      case 'code':
        return (Icons.code, SuperTokens.success);
      case 'img':
        return (Icons.image_outlined, SuperTokens.warning);
      default:
        return (Icons.description_outlined, context.superTheme.fg3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: t.fg2),
        title: Text('File Explorer', style: SuperText.heading.copyWith(color: t.fg1)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SuperTree<FileMeta>(
                controller: _controller,
                accent: SuperTokens.accent,
                title: 'Project files',
                subtitle:
                    'TreeNode<FileMeta> · folders roll up a child count, files show size + modified',
                titleIcon: Icons.folder_open,
                nameColumnLabel: 'Name',
                trailingColumnLabel: 'Size · Modified',
                placeholder: 'Search files…   ( / )',
                samples: const ['tree', '.dart', 'docs', 'README'],
                unit: 'files',
                showArabic: false,
                enableEditing: true,
                leadingBuilder: (context, node, info) {
                  final (icon, color) = _icon(context, node.value!, info.open);
                  return Icon(icon, size: 15, color: color);
                },
                trailingBuilder: (context, node, info) {
                  final m = node.value!;
                  if (m.kind == 'dir') return null;
                  final t = context.superTheme;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.size ?? '',
                          style: SuperText.mono.copyWith(fontSize: 11.5, color: t.fg2)),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 46,
                        child: Text(m.modified ?? '',
                            textAlign: TextAlign.end,
                            style: SuperText.caption.copyWith(fontSize: 11, color: t.fg4)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
