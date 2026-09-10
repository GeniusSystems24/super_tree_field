import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SuperTreeExampleLocalization
/// returned by `SuperTreeExampleLocalization.of(context)`.
///
/// Applications need to include `SuperTreeExampleLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SuperTreeExampleLocalization.localizationsDelegates,
///   supportedLocales: SuperTreeExampleLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SuperTreeExampleLocalization.supportedLocales
/// property.
abstract class SuperTreeExampleLocalization {
  SuperTreeExampleLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SuperTreeExampleLocalization of(BuildContext context) {
    return Localizations.of<SuperTreeExampleLocalization>(
      context,
      SuperTreeExampleLocalization,
    )!;
  }

  static const LocalizationsDelegate<SuperTreeExampleLocalization> delegate =
      _SuperTreeExampleLocalizationDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Tree'**
  String get appTitle;

  /// No description provided for @galleryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SUPER TREE • GALLERY'**
  String get galleryEyebrow;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Component Demos'**
  String get galleryTitle;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchToArabic;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get switchToEnglish;

  /// No description provided for @accountTreeDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Tree'**
  String get accountTreeDemoTitle;

  /// No description provided for @accountTreeDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chart of accounts · KPIs · A = L + E · DR/CR · roll-up balances'**
  String get accountTreeDemoSubtitle;

  /// No description provided for @fileExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'File Explorer'**
  String get fileExplorerTitle;

  /// No description provided for @fileExplorerDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SuperTree<FileMeta> · folders + files · size / modified'**
  String get fileExplorerDemoSubtitle;

  /// No description provided for @orgChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Org Chart'**
  String get orgChartTitle;

  /// No description provided for @orgChartDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SuperTree<Person> · headcount roll-up · role + dept'**
  String get orgChartDemoSubtitle;

  /// No description provided for @permissionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Settings'**
  String get permissionSettingsTitle;

  /// No description provided for @permissionSettingsDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SuperTree<Permission> · single + multi checkbox selection'**
  String get permissionSettingsDemoSubtitle;

  /// No description provided for @productTreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Tree'**
  String get productTreeTitle;

  /// No description provided for @productTreeDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SuperTree<ProductData> · categories · SKU · price · stock'**
  String get productTreeDemoSubtitle;

  /// No description provided for @scrollConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Scroll Configuration'**
  String get scrollConfigurationTitle;

  /// No description provided for @scrollConfigurationDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ScrollController · physics · restoration · bounded viewport'**
  String get scrollConfigurationDemoSubtitle;

  /// No description provided for @contextMenuDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Tree Context Menus'**
  String get contextMenuDemoTitle;

  /// No description provided for @contextMenuDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reusable · nested · per-node context-menu customization'**
  String get contextMenuDemoSubtitle;

  /// No description provided for @accountingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNTING • CHART OF ACCOUNTS'**
  String get accountingEyebrow;

  /// No description provided for @accountTreeHeading.
  ///
  /// In en, this message translates to:
  /// **'Account Tree'**
  String get accountTreeHeading;

  /// No description provided for @searchAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search by code, English or Arabic name…   ( / )'**
  String get searchAccounts;

  /// No description provided for @accountHierarchy.
  ///
  /// In en, this message translates to:
  /// **'Chart of Accounts Hierarchy'**
  String get accountHierarchy;

  /// No description provided for @accountHierarchyDescription.
  ///
  /// In en, this message translates to:
  /// **'5 levels · click or use ↑↓ ← → · Enter opens a leaf · right-click to edit'**
  String get accountHierarchyDescription;

  /// No description provided for @accountColumn.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountColumn;

  /// No description provided for @natureBalanceSar.
  ///
  /// In en, this message translates to:
  /// **'Nature · Balance (SAR)'**
  String get natureBalanceSar;

  /// No description provided for @openedLedger.
  ///
  /// In en, this message translates to:
  /// **'Opened ledger for account'**
  String get openedLedger;

  /// No description provided for @editTreeHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to move · right-click (or ⋮) to rename, add or delete · type filter is paused while editing'**
  String get editTreeHint;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @totalLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Total Liabilities'**
  String get totalLiabilities;

  /// No description provided for @totalEquity.
  ///
  /// In en, this message translates to:
  /// **'Total Equity'**
  String get totalEquity;

  /// No description provided for @netIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get netIncome;

  /// No description provided for @sarDebitBalance.
  ///
  /// In en, this message translates to:
  /// **'SAR · debit balance'**
  String get sarDebitBalance;

  /// No description provided for @sarCreditBalance.
  ///
  /// In en, this message translates to:
  /// **'SAR · credit balance'**
  String get sarCreditBalance;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced · A = L + E'**
  String get balanced;

  /// No description provided for @outOfBalance.
  ///
  /// In en, this message translates to:
  /// **'Out of balance'**
  String get outOfBalance;

  /// No description provided for @searchFiles.
  ///
  /// In en, this message translates to:
  /// **'Search files…   ( / )'**
  String get searchFiles;

  /// No description provided for @projectFiles.
  ///
  /// In en, this message translates to:
  /// **'Project files'**
  String get projectFiles;

  /// No description provided for @projectFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'TreeNode<FileMeta> · folders roll up a child count, files show size + modified'**
  String get projectFilesDescription;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @sizeModified.
  ///
  /// In en, this message translates to:
  /// **'Size · Modified'**
  String get sizeModified;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people…   ( / )'**
  String get searchPeople;

  /// No description provided for @orgChart.
  ///
  /// In en, this message translates to:
  /// **'Org chart'**
  String get orgChart;

  /// No description provided for @orgChartDescription.
  ///
  /// In en, this message translates to:
  /// **'TreeNode<Person> · managers roll up a headcount, everyone shows role + dept'**
  String get orgChartDescription;

  /// No description provided for @roleDept.
  ///
  /// In en, this message translates to:
  /// **'Role · Dept'**
  String get roleDept;

  /// No description provided for @administrationPermissionsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ADMINISTRATION • ROLES & PERMISSIONS'**
  String get administrationPermissionsEyebrow;

  /// No description provided for @permissionSettingsHeading.
  ///
  /// In en, this message translates to:
  /// **'Permission Settings'**
  String get permissionSettingsHeading;

  /// No description provided for @searchPermissions.
  ///
  /// In en, this message translates to:
  /// **'Search permissions…   ( / )'**
  String get searchPermissions;

  /// No description provided for @roleSeniorAccountant.
  ///
  /// In en, this message translates to:
  /// **'Role: Senior Accountant'**
  String get roleSeniorAccountant;

  /// No description provided for @permissionsMultiDescription.
  ///
  /// In en, this message translates to:
  /// **'Check the permissions granted to this role · a module checks all its actions'**
  String get permissionsMultiDescription;

  /// No description provided for @permissionsSingleDescription.
  ///
  /// In en, this message translates to:
  /// **'Single selection · one default action only (radio-like)'**
  String get permissionsSingleDescription;

  /// No description provided for @permissionColumn.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permissionColumn;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @selectionMode.
  ///
  /// In en, this message translates to:
  /// **'SELECTION MODE'**
  String get selectionMode;

  /// No description provided for @multi.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get multi;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products, SKU, or Arabic name…   ( / )'**
  String get searchProducts;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @productsDescription.
  ///
  /// In en, this message translates to:
  /// **'Categories · bilingual names · SKU · unit · price · stock'**
  String get productsDescription;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @priceStock.
  ///
  /// In en, this message translates to:
  /// **'Price · Stock'**
  String get priceStock;

  /// No description provided for @jumpToStart.
  ///
  /// In en, this message translates to:
  /// **'Jump to start'**
  String get jumpToStart;

  /// No description provided for @jumpToEnd.
  ///
  /// In en, this message translates to:
  /// **'Jump to end'**
  String get jumpToEnd;

  /// No description provided for @reverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get reverse;

  /// No description provided for @searchScrollableItems.
  ///
  /// In en, this message translates to:
  /// **'Search scrollable items…   ( / )'**
  String get searchScrollableItems;

  /// No description provided for @boundedScrollingTree.
  ///
  /// In en, this message translates to:
  /// **'Bounded scrolling tree'**
  String get boundedScrollingTree;

  /// No description provided for @boundedScrollingDescription.
  ///
  /// In en, this message translates to:
  /// **'controller owns hierarchy state · scrollController owns scroll position'**
  String get boundedScrollingDescription;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @standaloneMenu.
  ///
  /// In en, this message translates to:
  /// **'Standalone menu'**
  String get standaloneMenu;

  /// No description provided for @defaultReadOnlyMenu.
  ///
  /// In en, this message translates to:
  /// **'Default read-only menu'**
  String get defaultReadOnlyMenu;

  /// No description provided for @defaultEditableMenu.
  ///
  /// In en, this message translates to:
  /// **'Default editable menu'**
  String get defaultEditableMenu;

  /// No description provided for @replaceItems.
  ///
  /// In en, this message translates to:
  /// **'Replace items'**
  String get replaceItems;

  /// No description provided for @extendDefaults.
  ///
  /// In en, this message translates to:
  /// **'Extend defaults'**
  String get extendDefaults;

  /// No description provided for @filterDefaults.
  ///
  /// In en, this message translates to:
  /// **'Filter defaults'**
  String get filterDefaults;

  /// No description provided for @nestedMenus.
  ///
  /// In en, this message translates to:
  /// **'Nested menus'**
  String get nestedMenus;

  /// No description provided for @flexibleMenuPerNode.
  ///
  /// In en, this message translates to:
  /// **'Flexible menu per node'**
  String get flexibleMenuPerNode;

  /// No description provided for @styleCustomization.
  ///
  /// In en, this message translates to:
  /// **'Style customization'**
  String get styleCustomization;

  /// No description provided for @disableContextMenus.
  ///
  /// In en, this message translates to:
  /// **'Disable tree context menus'**
  String get disableContextMenus;
}

class _SuperTreeExampleLocalizationDelegate
    extends LocalizationsDelegate<SuperTreeExampleLocalization> {
  const _SuperTreeExampleLocalizationDelegate();

  @override
  Future<SuperTreeExampleLocalization> load(Locale locale) {
    return SynchronousFuture<SuperTreeExampleLocalization>(
      lookupSuperTreeExampleLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SuperTreeExampleLocalizationDelegate old) => false;
}

SuperTreeExampleLocalization lookupSuperTreeExampleLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SuperTreeExampleLocalizationAr();
    case 'en':
      return SuperTreeExampleLocalizationEn();
  }

  throw FlutterError(
    'SuperTreeExampleLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
