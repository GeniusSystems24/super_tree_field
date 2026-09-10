// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SuperTreeLocalizationAr extends SuperTreeLocalization {
  SuperTreeLocalizationAr([String locale = 'ar']) : super(locale);

  @override
  String get hierarchy => 'التسلسل الهرمي';

  @override
  String get name => 'الاسم';

  @override
  String get items => 'عناصر';

  @override
  String get selected => 'المحدد';

  @override
  String visibleOfTotal(int visible, int total) {
    return '$visible من $total';
  }

  @override
  String get treeEmpty => 'هذه الشجرة فارغة';

  @override
  String noMatchesFor(String query) {
    return 'لا توجد نتائج لـ «$query»';
  }

  @override
  String get tryDifferentCodeOrName =>
      'جرّب رمزًا أو اسمًا مختلفًا، أو امسح عوامل التصفية.';

  @override
  String get clear => 'مسح';

  @override
  String selectedCount(int count) {
    return '$count محدد';
  }

  @override
  String itemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر محددة',
      two: 'عنصران محددان',
      one: 'عنصر واحد محدد',
      zero: 'لا توجد عناصر محددة',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'بحث…   ( / )';

  @override
  String get addNode => 'إضافة عقدة';

  @override
  String get keyboardShortcutsTooltip => 'اختصارات لوحة المفاتيح  ·  ؟';

  @override
  String get expandAll => 'توسيع الكل';

  @override
  String get collapse => 'طي';

  @override
  String get readMode => 'قراءة';

  @override
  String get editMode => 'تحرير';

  @override
  String get keyboardShortcuts => 'اختصارات لوحة المفاتيح';

  @override
  String get close => 'إغلاق';

  @override
  String get shortcutMoveBetweenRows => 'التنقل بين الصفوف';

  @override
  String get shortcutCollapseExpand =>
      'طي / انتقال للخارج · توسيع / انتقال للداخل';

  @override
  String get shortcutJumpFirstLast => 'الانتقال إلى أول / آخر صف';

  @override
  String get shortcutOpenToggle => 'فتح عنصر نهائي · تبديل حالة مجموعة';

  @override
  String get shortcutToggleCheckbox => 'تبديل خانة الاختيار (في وضع التحديد)';

  @override
  String get shortcutFocusSearch => 'نقل التركيز إلى حقل البحث';

  @override
  String get shortcutClearSearch => 'مسح البحث';

  @override
  String get shortcutExpandCollapseAll => 'توسيع الكل · طي الكل';

  @override
  String get shortcutRightClickKey => 'النقر بزر الفأرة الأيمن';

  @override
  String get shortcutOpenNodeMenu => 'فتح قائمة العقدة';

  @override
  String get shortcutCheatsheet => 'عرض قائمة الاختصارات';

  @override
  String get dismissMenu => 'إغلاق القائمة';

  @override
  String get expand => 'توسيع';

  @override
  String get open => 'فتح';

  @override
  String get expandSubtree => 'توسيع الشجرة الفرعية';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get add => 'إضافة';

  @override
  String get addChild => 'إضافة عنصر فرعي';

  @override
  String get addSiblingAbove => 'إضافة عنصر مماثل بالأعلى';

  @override
  String get addSiblingBelow => 'إضافة عنصر مماثل بالأسفل';

  @override
  String get delete => 'حذف';

  @override
  String get newNode => 'عقدة جديدة';
}
