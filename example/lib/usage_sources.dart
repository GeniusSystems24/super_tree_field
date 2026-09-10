// ignore_for_file: public_member_api_docs

/// Centralized Dart snippets rendered beside the SuperTree live examples.
///
/// These snippets intentionally focus on the public package API rather than
/// duplicating the full implementation of each example screen.
abstract final class ExampleUsageSources {
  static const String accountTree = r'''
final controller = SuperTreeController<AccountData>(
  roots: accountRoots,
  defaultExpandDepth: 1,
  searchText: (node) =>
      '${node.code} ${node.name} ${node.ar ?? ''}',
);

Column(
  children: [
    SuperTreeControls<AccountData>(
      controller: controller,
      controlsController: controlsController,
      enableEditing: true,
    ),
    const SizedBox(height: 12),
    SuperTree<AccountData>(
      controller: controller,
      leadingBuilder: (context, node, info) {
        return AccountNatureIcon(node: node, open: info.open);
      },
      trailingBuilder: (context, node, info) {
        return AccountBalanceCell(node: node);
      },
    ),
  ],
);
''';

  static const String fileTree = r'''
final controller = SuperTreeController<FileMeta>(
  roots: fileRoots,
  searchText: (node) => node.name,
);

SuperTree<FileMeta>(
  controller: controller,
  leadingBuilder: (context, node, info) {
    final meta = node.value!;
    return Icon(
      meta.kind == 'dir'
          ? (info.open ? Icons.folder_open : Icons.folder)
          : Icons.description_outlined,
    );
  },
  trailingBuilder: (context, node, info) {
    final meta = node.value!;
    return meta.kind == 'dir'
        ? null
        : Text('${meta.size} · ${meta.modified}');
  },
);
''';

  static const String orgTree = r'''
final controller = SuperTreeController<Person>(
  roots: organizationRoots,
  searchText: (node) =>
      '${node.name} ${node.value?.role ?? ''}',
);

SuperTree<Person>(
  controller: controller,
  leadingBuilder: (context, node, info) {
    return const Icon(Icons.person_outline);
  },
  trailingBuilder: (context, node, info) {
    final person = node.value!;
    return Text('${person.role} · ${person.department}');
  },
);
''';

  static const String permissionTree = r'''
final controller = SuperTreeController<Permission>(
  roots: permissionRoots,
  selectionMode: SuperTreeSelectionMode.multi,
);

SuperTree<Permission>(
  controller: controller,
  leadingBuilder: (context, node, info) {
    return Checkbox(
      value: info.checked,
      tristate: true,
      onChanged: (_) => controller.toggleChecked(node.code),
    );
  },
);
''';

  static const String productTree = r'''
final controller = SuperTreeController<ProductData>(
  roots: productRoots,
  searchText: (node) =>
      '${node.code} ${node.name} ${node.ar ?? ''}',
);

SuperTree<ProductData>(
  controller: controller,
  leadingBuilder: (context, node, info) {
    return Icon(
      node.hasChildren
          ? Icons.category_outlined
          : Icons.inventory_2_outlined,
    );
  },
  trailingBuilder: (context, node, info) {
    final product = node.value;
    if (product == null) return null;
    return Text('${product.price} · ${product.stock}');
  },
);
''';

  static const String scrollConfiguration = r'''
final treeScrollController = ScrollController();

SuperTree<ItemData>(
  controller: controller,
  scrollController: treeScrollController,
  primary: false,
  shrinkWrap: false,
  physics: const ClampingScrollPhysics(),
  restorationId: 'tree-scroll-position',
);

controller.setFocus(targetNode.code);
''';

  static const String contextMenus = r'''
SuperTree<FileInfo>(
  controller: controller,
  contextMenuConfigBuilder: (menu) {
    final node = menu.node;

    if (node.code == 'protected') {
      return const TreeContextMenuConfig.disabled();
    }

    if (node.hasChildren) {
      return TreeContextMenuConfig(
        style: const TreeContextMenuStyle(width: 300),
        items: [
          ...menu.baseItems,
          TreeContextMenuItem(
            id: 'tools',
            label: 'Folder tools',
            children: [
              TreeContextMenuItem(
                id: 'inspect',
                label: 'Inspect',
                onTap: () => inspectNode(node),
              ),
            ],
          ),
        ],
      );
    }

    return const TreeContextMenuConfig();
  },
);
''';
}
