// ============================================================
// features/super_tree/data/datasources/account_tree_data.dart
// ------------------------------------------------------------
// The flagship dataset: a five-level bilingual chart of accounts. Only leaves
// carry a `balance`; every group total rolls up from its children (see
// `TreeLogic.rollup`) so the books reconcile and Assets = Liabilities + Equity.
//
// A faithful port of the React `super-tree` TREE constant. This is sample data
// — replace `AccountTreeData.tree` with your own `List<TreeNode<AccountData>>`.
// ============================================================

import '../../domain/entities/account_data.dart';
import '../../domain/entities/tree_node.dart';

/// Static sample chart-of-accounts data for the flagship `AccountTree`.
abstract final class AccountTreeData {
  /// Group node (no balance — rolls up its children).
  static TreeNode<AccountData> _g(
    String code,
    String name,
    String ar,
    AccountType type,
    List<TreeNode<AccountData>> children,
  ) =>
      TreeNode<AccountData>(
        code: code,
        name: name,
        ar: ar,
        value: AccountData(type: type),
        children: children,
      );

  /// Leaf node carrying an explicit [bal]ance.
  static TreeNode<AccountData> _l(
    String code,
    String name,
    String ar,
    AccountType type,
    double bal,
  ) =>
      TreeNode<AccountData>(
        code: code,
        name: name,
        ar: ar,
        value: AccountData(type: type, balance: bal),
      );

  /// The five root accounts, each a five-level subtree.
  static List<TreeNode<AccountData>> get tree {
    const a = AccountType.asset;
    const l = AccountType.liability;
    const e = AccountType.equity;
    const i = AccountType.income;
    const x = AccountType.expense;
    return [
      _g('1000', 'Assets', 'الأصول', a, [
        _g('1100', 'Current Assets', 'الأصول المتداولة', a, [
          _g('1110', 'Cash & Cash Equivalents', 'النقد وما في حكمه', a, [
            _g('1111', 'Bank Accounts', 'الحسابات البنكية', a, [
              _l('1111-01', 'Al Rajhi Bank — Main', 'مصرف الراجحي — الرئيسي', a, 186420),
              _l('1111-02', 'NCB — Riyadh Branch', 'الأهلي — فرع الرياض', a, 92300),
              _l('1111-03', 'Riyad Bank — USD', 'بنك الرياض — دولار', a, 41250),
            ]),
            _g('1112', 'Cash on Hand', 'النقد في الصندوق', a, [
              _l('1112-01', 'Main Cash Box', 'الصندوق الرئيسي', a, 18500),
              _l('1112-02', 'Petty Cash', 'المصروفات النثرية', a, 3200),
            ]),
          ]),
          _g('1120', 'Trade Receivables', 'الذمم المدينة', a, [
            _g('1121', 'Local Customers', 'عملاء محليون', a, [
              _l('1121-01', 'Retail Customers', 'عملاء التجزئة', a, 64800),
              _l('1121-02', 'Wholesale Customers', 'عملاء الجملة', a, 88600),
            ]),
            _g('1122', 'Export Customers', 'عملاء التصدير', a, [
              _l('1122-01', 'GCC Customers', 'عملاء دول الخليج', a, 37400),
            ]),
          ]),
          _g('1130', 'Inventory', 'المخزون', a, [
            _g('1131', 'Finished Goods', 'بضائع تامة الصنع', a, [
              _l('1131-01', 'Warehouse A', 'المستودع أ', a, 124000),
              _l('1131-02', 'Warehouse B', 'المستودع ب', a, 76500),
            ]),
            _g('1132', 'Raw Materials', 'المواد الخام', a, [
              _l('1132-01', 'Steel & Metals', 'الحديد والمعادن', a, 54200),
            ]),
          ]),
        ]),
        _g('1500', 'Non-Current Assets', 'الأصول غير المتداولة', a, [
          _g('1510', 'Property & Equipment', 'الممتلكات والمعدات', a, [
            _g('1511', 'Machinery', 'الآلات', a, [
              _l('1511-01', 'Production Line 1', 'خط الإنتاج 1', a, 210000),
              _l('1511-02', 'Production Line 2', 'خط الإنتاج 2', a, 145000),
            ]),
            _g('1512', 'Vehicles', 'المركبات', a, [
              _l('1512-01', 'Delivery Fleet', 'أسطول التوصيل', a, 88000),
              _l('1512-02', 'Company Cars', 'سيارات الشركة', a, 52000),
            ]),
          ]),
          _g('1520', 'Intangible Assets', 'الأصول غير الملموسة', a, [
            _g('1521', 'Software Licenses', 'تراخيص البرمجيات', a, [
              _l('1521-01', 'ERP License', 'رخصة نظام تخطيط الموارد', a, 36000),
            ]),
          ]),
        ]),
      ]),
      _g('2000', 'Liabilities', 'الخصوم', l, [
        _g('2100', 'Current Liabilities', 'الخصوم المتداولة', l, [
          _g('2110', 'Trade Payables', 'الذمم الدائنة', l, [
            _g('2111', 'Local Suppliers', 'موردون محليون', l, [
              _l('2111-01', 'Material Suppliers', 'موردو المواد', l, 92400),
              _l('2111-02', 'Service Providers', 'مزودو الخدمات', l, 38600),
            ]),
            _g('2112', 'Foreign Suppliers', 'موردون أجانب', l, [
              _l('2112-01', 'Asia Imports', 'واردات آسيا', l, 64200),
            ]),
          ]),
          _g('2120', 'Accrued Expenses', 'المصروفات المستحقة', l, [
            _g('2121', 'Payroll Accruals', 'مستحقات الرواتب', l, [
              _l('2121-01', 'Salaries Payable', 'رواتب مستحقة', l, 48500),
              _l('2121-02', 'End of Service', 'مكافأة نهاية الخدمة', l, 31200),
            ]),
            _g('2122', 'Tax Accruals', 'المستحقات الضريبية', l, [
              _l('2122-01', 'VAT Payable', 'ضريبة القيمة المضافة', l, 27800),
            ]),
          ]),
        ]),
        _g('2500', 'Non-Current Liabilities', 'الخصوم غير المتداولة', l, [
          _g('2510', 'Long-Term Loans', 'القروض طويلة الأجل', l, [
            _g('2511', 'Bank Loans', 'القروض البنكية', l, [
              _l('2511-01', 'Equipment Loan', 'قرض المعدات', l, 180000),
              _l('2511-02', 'Expansion Loan', 'قرض التوسعة', l, 120000),
            ]),
          ]),
        ]),
      ]),
      _g('3000', 'Equity', 'حقوق الملكية', e, [
        _g('3100', 'Paid-In Capital', 'رأس المال المدفوع', e, [
          _g('3110', 'Share Capital', 'رأس مال الأسهم', e, [
            _g('3111', 'Founders', 'المؤسسون', e, [
              _l('3111-01', 'Founder A', 'المؤسس أ', e, 300000),
              _l('3111-02', 'Founder B', 'المؤسس ب', e, 200000),
            ]),
          ]),
        ]),
        _g('3200', 'Retained Earnings', 'الأرباح المحتجزة', e, [
          _g('3210', 'Prior Years', 'سنوات سابقة', e, [
            _g('3211', 'Accumulated', 'المتراكمة', e, [
              _l('3211-01', 'Accumulated Profit', 'أرباح متراكمة', e, 154470),
            ]),
          ]),
          _g('3220', 'Current Year', 'السنة الحالية', e, [
            _g('3221', 'Net Income', 'صافي الدخل', e, [
              _l('3221-01', 'YTD Profit', 'ربح حتى تاريخه', e, 61000),
            ]),
          ]),
        ]),
      ]),
      _g('4000', 'Income', 'الإيرادات', i, [
        _g('4100', 'Operating Revenue', 'إيرادات التشغيل', i, [
          _g('4110', 'Product Sales', 'مبيعات المنتجات', i, [
            _g('4111', 'Domestic Sales', 'المبيعات المحلية', i, [
              _l('4111-01', 'Retail Sales', 'مبيعات التجزئة', i, 642000),
              _l('4111-02', 'Wholesale Sales', 'مبيعات الجملة', i, 388000),
            ]),
            _g('4112', 'Export Sales', 'مبيعات التصدير', i, [
              _l('4112-01', 'GCC Exports', 'صادرات دول الخليج', i, 214000),
            ]),
          ]),
          _g('4120', 'Service Revenue', 'إيرادات الخدمات', i, [
            _g('4121', 'Maintenance Contracts', 'عقود الصيانة', i, [
              _l('4121-01', 'Annual Contracts', 'عقود سنوية', i, 96000),
            ]),
          ]),
        ]),
      ]),
      _g('5000', 'Expenses', 'المصروفات', x, [
        _g('5100', 'Cost of Goods Sold', 'تكلفة البضاعة المباعة', x, [
          _g('5110', 'Direct Materials', 'المواد المباشرة', x, [
            _g('5111', 'Raw Material Cost', 'تكلفة المواد الخام', x, [
              _l('5111-01', 'Steel Purchases', 'مشتريات الحديد', x, 318000),
            ]),
          ]),
          _g('5120', 'Direct Labor', 'العمالة المباشرة', x, [
            _g('5121', 'Factory Wages', 'أجور المصنع', x, [
              _l('5121-01', 'Production Staff', 'موظفو الإنتاج', x, 142000),
            ]),
          ]),
        ]),
        _g('5500', 'Operating Expenses', 'المصروفات التشغيلية', x, [
          _g('5510', 'Administrative', 'إدارية', x, [
            _g('5511', 'Salaries & Benefits', 'الرواتب والمزايا', x, [
              _l('5511-01', 'Admin Salaries', 'رواتب إدارية', x, 188000),
            ]),
            _g('5512', 'Rent & Utilities', 'الإيجار والمرافق', x, [
              _l('5512-01', 'Office Rent', 'إيجار المكتب', x, 72000),
            ]),
          ]),
        ]),
      ]),
    ];
  }
}
