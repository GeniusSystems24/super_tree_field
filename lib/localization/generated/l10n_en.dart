// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SuperTreeLocalizationEn extends SuperTreeLocalization {
  SuperTreeLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get hierarchy => 'Hierarchy';

  @override
  String get name => 'Name';

  @override
  String get items => 'items';

  @override
  String get selected => 'Selected';

  @override
  String visibleOfTotal(int visible, int total) {
    return '$visible of $total';
  }

  @override
  String get treeEmpty => 'This tree is empty';

  @override
  String noMatchesFor(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get tryDifferentCodeOrName =>
      'Try a different code or name, or clear the filters.';

  @override
  String get clear => 'Clear';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String itemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items selected',
      one: '1 item selected',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search…   ( / )';

  @override
  String get addNode => 'Add node';

  @override
  String get keyboardShortcutsTooltip => 'Keyboard shortcuts  ·  ?';

  @override
  String get expandAll => 'Expand all';

  @override
  String get collapse => 'Collapse';

  @override
  String get readMode => 'Read';

  @override
  String get editMode => 'Edit';

  @override
  String get keyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get close => 'Close';

  @override
  String get shortcutMoveBetweenRows => 'Move between rows';

  @override
  String get shortcutCollapseExpand => 'Collapse / step out · expand / step in';

  @override
  String get shortcutJumpFirstLast => 'Jump to first / last row';

  @override
  String get shortcutOpenToggle => 'Open a leaf · toggle a group';

  @override
  String get shortcutToggleCheckbox =>
      'Toggle the checkbox (in selection mode)';

  @override
  String get shortcutFocusSearch => 'Focus the search field';

  @override
  String get shortcutClearSearch => 'Clear the search';

  @override
  String get shortcutExpandCollapseAll => 'Expand all · collapse all';

  @override
  String get shortcutRightClickKey => 'Right-click';

  @override
  String get shortcutOpenNodeMenu => 'Open the node menu';

  @override
  String get shortcutCheatsheet => 'This cheatsheet';

  @override
  String get dismissMenu => 'Dismiss menu';

  @override
  String get expand => 'Expand';

  @override
  String get open => 'Open';

  @override
  String get expandSubtree => 'Expand subtree';

  @override
  String get rename => 'Rename';

  @override
  String get add => 'Add';

  @override
  String get addChild => 'Add child';

  @override
  String get addSiblingAbove => 'Add sibling above';

  @override
  String get addSiblingBelow => 'Add sibling below';

  @override
  String get delete => 'Delete';

  @override
  String get newNode => 'New node';
}
