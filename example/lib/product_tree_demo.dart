// ============================================================
// example/lib/product_tree_demo.dart
// ------------------------------------------------------------
// EXAMPLE 5 — product catalog hierarchy. Categories group product leaves while
// each product carries SKU, unit, price, and stock metadata. The demo uses the
// same SuperTree<ProductData> engine with bilingual labels and editable rows.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_tree_field/super_tree.dart';
import 'responsive_example_layout.dart';

/// Metadata attached to a product-catalog node.
@immutable
class ProductData {
  /// Creates product metadata.
  const ProductData({
    required this.isCategory,
    this.sku,
    this.unit,
    this.price,
    this.stock = 0,
  });

  /// Creates metadata for a category node.
  const ProductData.category()
    : isCategory = true,
      sku = null,
      unit = null,
      price = null,
      stock = 0;

  /// Creates metadata for a product leaf.
  const ProductData.product({
    required String this.sku,
    required String this.unit,
    required double this.price,
    required this.stock,
  }) : isCategory = false;

  /// Whether this node represents a product category.
  final bool isCategory;

  /// Stock-keeping unit for a product leaf.
  final String? sku;

  /// Selling or inventory unit, such as `pc` or `box`.
  final String? unit;

  /// Unit selling price for a product leaf.
  final double? price;

  /// Current on-hand quantity for a product leaf.
  final int stock;
}

TreeNode<ProductData> _category(
  String code,
  String name,
  String ar,
  List<TreeNode<ProductData>> children,
) => TreeNode<ProductData>(
  code: code,
  name: name,
  ar: ar,
  value: const ProductData.category(),
  children: children,
);

TreeNode<ProductData> _product(
  String code,
  String name,
  String ar, {
  required String sku,
  required String unit,
  required double price,
  required int stock,
}) => TreeNode<ProductData>(
  code: code,
  name: name,
  ar: ar,
  value: ProductData.product(sku: sku, unit: unit, price: price, stock: stock),
);

final List<TreeNode<ProductData>> _productTree = [
  _category('ELEC', 'Electronics', 'الإلكترونيات', [
    _category('ELEC-MOB', 'Mobile devices', 'الأجهزة المحمولة', [
      _product(
        'P-1001',
        'Business smartphone',
        'هاتف أعمال ذكي',
        sku: 'MOB-1001',
        unit: 'pc',
        price: 3299,
        stock: 18,
      ),
      _product(
        'P-1002',
        'Rugged handheld terminal',
        'جهاز محمول صناعي',
        sku: 'MOB-1002',
        unit: 'pc',
        price: 1890,
        stock: 7,
      ),
    ]),
    _category('ELEC-ACC', 'Accessories', 'الملحقات', [
      _product(
        'P-1101',
        'USB-C charging kit',
        'طقم شحن USB-C',
        sku: 'ACC-1101',
        unit: 'set',
        price: 149,
        stock: 42,
      ),
      _product(
        'P-1102',
        'Wireless barcode scanner',
        'قارئ باركود لاسلكي',
        sku: 'ACC-1102',
        unit: 'pc',
        price: 620,
        stock: 14,
      ),
    ]),
  ]),
  _category('OFFICE', 'Office supplies', 'المستلزمات المكتبية', [
    _category('OFFICE-PAPER', 'Paper products', 'المنتجات الورقية', [
      _product(
        'P-2001',
        'A4 copy paper',
        'ورق تصوير A4',
        sku: 'PAP-2001',
        unit: 'box',
        price: 118,
        stock: 63,
      ),
      _product(
        'P-2002',
        'Thermal receipt rolls',
        'لفات إيصالات حرارية',
        sku: 'PAP-2002',
        unit: 'pack',
        price: 74,
        stock: 31,
      ),
    ]),
    _category('OFFICE-PRINT', 'Printing', 'الطباعة', [
      _product(
        'P-2101',
        'Black toner cartridge',
        'خرطوشة حبر أسود',
        sku: 'PRN-2101',
        unit: 'pc',
        price: 385,
        stock: 9,
      ),
    ]),
  ]),
  _category('WAREHOUSE', 'Warehouse supplies', 'مستلزمات المستودع', [
    _product(
      'P-3001',
      'Shipping labels 100×150',
      'ملصقات شحن 100×150',
      sku: 'WHS-3001',
      unit: 'roll',
      price: 52,
      stock: 80,
    ),
    _product(
      'P-3002',
      'Packing tape 48 mm',
      'شريط تغليف 48 مم',
      sku: 'WHS-3002',
      unit: 'box',
      price: 96,
      stock: 24,
    ),
  ]),
];

/// Demonstrates [SuperTree] with a bilingual product catalog.
class ProductTreeDemo extends StatefulWidget {
  /// Creates the product-tree demonstration page.
  const ProductTreeDemo({super.key});

  @override
  State<ProductTreeDemo> createState() => _ProductTreeDemoState();
}

class _ProductTreeDemoState extends State<ProductTreeDemo> {
  final SuperTreeControlsController _controls = SuperTreeControlsController();
  late final SuperTreeController<ProductData>
  _controller = SuperTreeController<ProductData>(
    roots: _productTree,
    defaultExpandDepth: 1,
    searchText: (node) {
      final product = node.value;
      return [
        node.code,
        node.name,
        node.ar ?? '',
        product?.sku ?? '',
        product?.unit ?? '',
      ].join(' ');
    },
    newNodeBuilder: (code) => TreeNode<ProductData>(
      code: code,
      name: 'New product',
      ar: 'منتج جديد',
      value: const ProductData.product(
        sku: 'NEW',
        unit: 'pc',
        price: 0,
        stock: 0,
      ),
    ),
    onOpenLeaf: (node) {
      // The host application can navigate to its product-details route here.
    },
  );

  @override
  void dispose() {
    _controls.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final colorScheme = SuperMaterialThemeData.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.fg2),
        title: Text(
          'Product Tree',
          style: context.superTextTheme.heading.copyWith(color: theme.fg1),
        ),
      ),
      body: ResponsiveExampleLayout(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
          SuperTreeControls<ProductData>(
                    controller: _controller,
                    controlsController: _controls,
                    placeholder: 'Search products, SKU, or Arabic name…   ( / )',
                    samples: const ['MOB', 'paper', 'مستودع', 'ACC-1102'],
                    accent: colorScheme.primary,
                    enableEditing: true,
                  ),
          SizedBox(height: context.superTheme.spacing.space4),
          SuperTree<ProductData>(
                                controller: _controller,
                      onSearchRequested: _controls.requestSearchFocus,
                      onShortcutsRequested: () => showShortcutsHelp(context),
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                accent: colorScheme.primary,
                                title: 'Products',
                                subtitle:
                                    'Categories · bilingual names · SKU · unit · price · stock',
                                titleIcon: Icons.inventory_2_outlined,
                                nameColumnLabel: 'Product',
                                trailingColumnLabel: 'Price · Stock',
                                unit: 'products',
                                showArabic: true,
                                showLeafCount: true,
                                leadingBuilder: (context, node, info) {
                                  final product = node.value;
                                  final isCategory = product?.isCategory ?? node.hasChildren;
                                  return Icon(
                                    isCategory
                                        ? (info.open
                                              ? Icons.folder_open_outlined
                                              : Icons.folder_outlined)
                                        : Icons.inventory_2_outlined,
                                    size: 16,
                                    color: isCategory ? colorScheme.primary : theme.fg3,
                                  );
                                },
                                trailingBuilder: (context, node, info) {
                                  final product = node.value;
                                  if (product == null || product.isCategory) return null;
          
                                  final lowStock = product.stock <= 10;
                                  final stockColor = lowStock
                                      ? SuperThemeData.of(context).tokens.warning
                                      : SuperThemeData.of(context).tokens.success;
          
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${product.price!.toStringAsFixed(2)} SAR',
                                        style: context.superTextTheme.mono.copyWith(
                                          fontSize: 11.5,
                                          color: theme.fg2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        height: 20,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: stockColor.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: stockColor.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Text(
                                          '${product.stock} ${product.unit}',
                                          style: context.superTextTheme.pill.copyWith(
                                            fontSize: 10,
                                            color: stockColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
          ],
        ),
      ),
    );
  }
}
