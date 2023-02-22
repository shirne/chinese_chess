import 'package:chinese_chess/l10n/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';

extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
