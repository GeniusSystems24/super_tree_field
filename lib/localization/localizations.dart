import 'package:flutter/widgets.dart';

import 'generated/l10n.dart';
import 'generated/l10n_en.dart';

export 'generated/l10n.dart';

/// English fallback used when no [SuperTreeLocalization] is available
/// from the current widget tree.
final SuperTreeLocalization superTreeEnglishLocalizationFallback =
    SuperTreeLocalizationEn();

/// Provides convenient access to SuperTree localized strings from a
/// [BuildContext].
extension SuperTreeLocalizationBuildContext on BuildContext {
  /// Returns the active [SuperTreeLocalization] for this context.
  ///
  /// Falls back to [superTreeEnglishLocalizationFallback] when the
  /// package localization delegate is not installed above this context.
  SuperTreeLocalization get superTreeLocalization =>
      Localizations.of<SuperTreeLocalization>(this, SuperTreeLocalization) ??
      superTreeEnglishLocalizationFallback;
}
