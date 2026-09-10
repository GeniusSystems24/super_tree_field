import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SuperTreeLocalization
/// returned by `SuperTreeLocalization.of(context)`.
///
/// Applications need to include `SuperTreeLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SuperTreeLocalization.localizationsDelegates,
///   supportedLocales: SuperTreeLocalization.supportedLocales,
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
/// be consistent with the languages listed in the SuperTreeLocalization.supportedLocales
/// property.
abstract class SuperTreeLocalization {
  SuperTreeLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SuperTreeLocalization of(BuildContext context) {
    return Localizations.of<SuperTreeLocalization>(
      context,
      SuperTreeLocalization,
    )!;
  }

  static const LocalizationsDelegate<SuperTreeLocalization> delegate =
      _SuperTreeLocalizationDelegate();

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

  /// No description provided for @hierarchy.
  ///
  /// In en, this message translates to:
  /// **'Hierarchy'**
  String get hierarchy;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @visibleOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{visible} of {total}'**
  String visibleOfTotal(int visible, int total);

  /// No description provided for @treeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This tree is empty'**
  String get treeEmpty;

  /// No description provided for @noMatchesFor.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String noMatchesFor(String query);

  /// No description provided for @tryDifferentCodeOrName.
  ///
  /// In en, this message translates to:
  /// **'Try a different code or name, or clear the filters.'**
  String get tryDifferentCodeOrName;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item selected} other{{count} items selected}}'**
  String itemsSelected(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…   ( / )'**
  String get searchHint;

  /// No description provided for @addNode.
  ///
  /// In en, this message translates to:
  /// **'Add node'**
  String get addNode;

  /// No description provided for @keyboardShortcutsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts  ·  ?'**
  String get keyboardShortcutsTooltip;

  /// No description provided for @expandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get expandAll;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @readMode.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readMode;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editMode;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get keyboardShortcuts;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @shortcutMoveBetweenRows.
  ///
  /// In en, this message translates to:
  /// **'Move between rows'**
  String get shortcutMoveBetweenRows;

  /// No description provided for @shortcutCollapseExpand.
  ///
  /// In en, this message translates to:
  /// **'Collapse / step out · expand / step in'**
  String get shortcutCollapseExpand;

  /// No description provided for @shortcutJumpFirstLast.
  ///
  /// In en, this message translates to:
  /// **'Jump to first / last row'**
  String get shortcutJumpFirstLast;

  /// No description provided for @shortcutOpenToggle.
  ///
  /// In en, this message translates to:
  /// **'Open a leaf · toggle a group'**
  String get shortcutOpenToggle;

  /// No description provided for @shortcutToggleCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Toggle the checkbox (in selection mode)'**
  String get shortcutToggleCheckbox;

  /// No description provided for @shortcutFocusSearch.
  ///
  /// In en, this message translates to:
  /// **'Focus the search field'**
  String get shortcutFocusSearch;

  /// No description provided for @shortcutClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get shortcutClearSearch;

  /// No description provided for @shortcutExpandCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all · collapse all'**
  String get shortcutExpandCollapseAll;

  /// No description provided for @shortcutRightClickKey.
  ///
  /// In en, this message translates to:
  /// **'Right-click'**
  String get shortcutRightClickKey;

  /// No description provided for @shortcutOpenNodeMenu.
  ///
  /// In en, this message translates to:
  /// **'Open the node menu'**
  String get shortcutOpenNodeMenu;

  /// No description provided for @shortcutCheatsheet.
  ///
  /// In en, this message translates to:
  /// **'This cheatsheet'**
  String get shortcutCheatsheet;

  /// No description provided for @dismissMenu.
  ///
  /// In en, this message translates to:
  /// **'Dismiss menu'**
  String get dismissMenu;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @expandSubtree.
  ///
  /// In en, this message translates to:
  /// **'Expand subtree'**
  String get expandSubtree;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get addChild;

  /// No description provided for @addSiblingAbove.
  ///
  /// In en, this message translates to:
  /// **'Add sibling above'**
  String get addSiblingAbove;

  /// No description provided for @addSiblingBelow.
  ///
  /// In en, this message translates to:
  /// **'Add sibling below'**
  String get addSiblingBelow;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newNode.
  ///
  /// In en, this message translates to:
  /// **'New node'**
  String get newNode;
}

class _SuperTreeLocalizationDelegate
    extends LocalizationsDelegate<SuperTreeLocalization> {
  const _SuperTreeLocalizationDelegate();

  @override
  Future<SuperTreeLocalization> load(Locale locale) {
    return SynchronousFuture<SuperTreeLocalization>(
      lookupSuperTreeLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SuperTreeLocalizationDelegate old) => false;
}

SuperTreeLocalization lookupSuperTreeLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SuperTreeLocalizationAr();
    case 'en':
      return SuperTreeLocalizationEn();
  }

  throw FlutterError(
    'SuperTreeLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
