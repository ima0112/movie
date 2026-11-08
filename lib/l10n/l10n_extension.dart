import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// `context.l10n` — CLAUDE.md rule 15: every piece of user-visible text
/// comes from [AppLocalizations]. Shorthand for
/// `AppLocalizations.of(context)` — already non-nullable, since
/// `l10n.yaml`'s own `nullable-getter: false` applies to this generated
/// `of` too, not just the message getters themselves.
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
