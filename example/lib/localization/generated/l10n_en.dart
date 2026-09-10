// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SuperTreeExampleLocalizationEn extends SuperTreeExampleLocalization {
  SuperTreeExampleLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Super Tree';

  @override
  String get galleryEyebrow => 'SUPER TREE • GALLERY';

  @override
  String get galleryTitle => 'Component Demos';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get switchToArabic => 'العربية';

  @override
  String get switchToEnglish => 'English';

  @override
  String get accountTreeDemoTitle => 'Account Tree';

  @override
  String get accountTreeDemoSubtitle =>
      'Chart of accounts · KPIs · A = L + E · DR/CR · roll-up balances';

  @override
  String get fileExplorerTitle => 'File Explorer';

  @override
  String get fileExplorerDemoSubtitle =>
      'SuperTree<FileMeta> · folders + files · size / modified';

  @override
  String get orgChartTitle => 'Org Chart';

  @override
  String get orgChartDemoSubtitle =>
      'SuperTree<Person> · headcount roll-up · role + dept';

  @override
  String get permissionSettingsTitle => 'Permission Settings';

  @override
  String get permissionSettingsDemoSubtitle =>
      'SuperTree<Permission> · single + multi checkbox selection';

  @override
  String get productTreeTitle => 'Product Tree';

  @override
  String get productTreeDemoSubtitle =>
      'SuperTree<ProductData> · categories · SKU · price · stock';

  @override
  String get scrollConfigurationTitle => 'Scroll Configuration';

  @override
  String get scrollConfigurationDemoSubtitle =>
      'ScrollController · physics · restoration · bounded viewport';

  @override
  String get contextMenuDemoTitle => 'Tree Context Menus';

  @override
  String get contextMenuDemoSubtitle =>
      'Reusable · nested · per-node context-menu customization';

  @override
  String get accountingEyebrow => 'ACCOUNTING • CHART OF ACCOUNTS';

  @override
  String get accountTreeHeading => 'Account Tree';

  @override
  String get searchAccounts =>
      'Search by code, English or Arabic name…   ( / )';

  @override
  String get accountHierarchy => 'Chart of Accounts Hierarchy';

  @override
  String get accountHierarchyDescription =>
      '5 levels · click or use ↑↓ ← → · Enter opens a leaf · right-click to edit';

  @override
  String get accountColumn => 'Account';

  @override
  String get natureBalanceSar => 'Nature · Balance (SAR)';

  @override
  String get openedLedger => 'Opened ledger for account';

  @override
  String get editTreeHint =>
      'Drag the handle to move · right-click (or ⋮) to rename, add or delete · type filter is paused while editing';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get totalLiabilities => 'Total Liabilities';

  @override
  String get totalEquity => 'Total Equity';

  @override
  String get netIncome => 'Net Income';

  @override
  String get sarDebitBalance => 'SAR · debit balance';

  @override
  String get sarCreditBalance => 'SAR · credit balance';

  @override
  String get all => 'All';

  @override
  String get balanced => 'Balanced · A = L + E';

  @override
  String get outOfBalance => 'Out of balance';

  @override
  String get searchFiles => 'Search files…   ( / )';

  @override
  String get projectFiles => 'Project files';

  @override
  String get projectFilesDescription =>
      'TreeNode<FileMeta> · folders roll up a child count, files show size + modified';

  @override
  String get name => 'Name';

  @override
  String get sizeModified => 'Size · Modified';

  @override
  String get searchPeople => 'Search people…   ( / )';

  @override
  String get orgChart => 'Org chart';

  @override
  String get orgChartDescription =>
      'TreeNode<Person> · managers roll up a headcount, everyone shows role + dept';

  @override
  String get roleDept => 'Role · Dept';

  @override
  String get administrationPermissionsEyebrow =>
      'ADMINISTRATION • ROLES & PERMISSIONS';

  @override
  String get permissionSettingsHeading => 'Permission Settings';

  @override
  String get searchPermissions => 'Search permissions…   ( / )';

  @override
  String get roleSeniorAccountant => 'Role: Senior Accountant';

  @override
  String get permissionsMultiDescription =>
      'Check the permissions granted to this role · a module checks all its actions';

  @override
  String get permissionsSingleDescription =>
      'Single selection · one default action only (radio-like)';

  @override
  String get permissionColumn => 'Permission';

  @override
  String get scope => 'Scope';

  @override
  String get selectionMode => 'SELECTION MODE';

  @override
  String get multi => 'Multi';

  @override
  String get single => 'Single';

  @override
  String get searchProducts => 'Search products, SKU, or Arabic name…   ( / )';

  @override
  String get products => 'Products';

  @override
  String get productsDescription =>
      'Categories · bilingual names · SKU · unit · price · stock';

  @override
  String get product => 'Product';

  @override
  String get priceStock => 'Price · Stock';

  @override
  String get jumpToStart => 'Jump to start';

  @override
  String get jumpToEnd => 'Jump to end';

  @override
  String get reverse => 'Reverse';

  @override
  String get searchScrollableItems => 'Search scrollable items…   ( / )';

  @override
  String get boundedScrollingTree => 'Bounded scrolling tree';

  @override
  String get boundedScrollingDescription =>
      'controller owns hierarchy state · scrollController owns scroll position';

  @override
  String get item => 'Item';

  @override
  String get index => 'Index';

  @override
  String get standaloneMenu => 'Standalone menu';

  @override
  String get defaultReadOnlyMenu => 'Default read-only menu';

  @override
  String get defaultEditableMenu => 'Default editable menu';

  @override
  String get replaceItems => 'Replace items';

  @override
  String get extendDefaults => 'Extend defaults';

  @override
  String get filterDefaults => 'Filter defaults';

  @override
  String get nestedMenus => 'Nested menus';

  @override
  String get flexibleMenuPerNode => 'Flexible menu per node';

  @override
  String get styleCustomization => 'Style customization';

  @override
  String get disableContextMenus => 'Disable tree context menus';
}
