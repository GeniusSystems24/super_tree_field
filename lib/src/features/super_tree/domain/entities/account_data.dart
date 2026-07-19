// ============================================================
// features/super_tree/domain/entities/account_data.dart
// ------------------------------------------------------------
// The domain payload for the flagship chart-of-accounts tree: an account's
// [AccountType] (which drives its color, debit/credit nature and grouping) and
// its leaf [balance]. Group totals roll up from leaves — see `TreeLogic.total`
// — so only leaves carry an explicit balance.
// ============================================================

import 'package:flutter/widgets.dart' show Color, immutable;


/// The five account natures of a double-entry chart of accounts.
enum AccountType {
  asset('Asset', 'الأصول', Color(0xFF4A7CFF), AccountNature.debit),
  liability('Liability', 'الخصوم', Color(0xFFF97316), AccountNature.credit),
  equity('Equity', 'حقوق الملكية', Color(0xFF1DB88A), AccountNature.credit),
  income('Income', 'الإيرادات', Color(0xFF38BDF8), AccountNature.credit),
  expense('Expense', 'المصروفات', Color(0xFFEF4444), AccountNature.debit);

  const AccountType(this.label, this.ar, this.color, this.nature);

  /// English label as shown in filter chips and KPI cards.
  final String label;

  /// Arabic label.
  final String ar;

  /// The dot / accent color for this type.
  final Color color;

  /// Whether this account is debit- or credit-natured.
  final AccountNature nature;

  /// Stable ordering used by the type filter and KPI grid.
  static const List<AccountType> ordered = [
    asset,
    liability,
    equity,
    income,
    expense,
  ];
}

/// Debit (DR) or credit (CR) — the side a `NaturePill` displays.
enum AccountNature {
  debit('DR'),
  credit('CR');

  const AccountNature(this.code);

  /// The two-letter pill code (`DR` / `CR`).
  final String code;
}

/// One account's payload: its [type] and (for leaves) its [balance].
@immutable
class AccountData {
  const AccountData({required this.type, this.balance = 0});

  final AccountType type;

  /// The leaf balance in SAR. Group nodes leave this at 0 and roll up instead.
  final double balance;
}
