import 'dart:ui' as ui;

import 'package:tarefas/l10n/app_localizations.dart';

class S {
  static AppLocalizations? _current;

  static AppLocalizations get current {
    return _current ?? lookupAppLocalizations(_fallbackLocale());
  }

  static void update(AppLocalizations l10n) => _current = l10n;

  static ui.Locale _fallbackLocale() {
    final device = ui.PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == device.languageCode,
    );
    return supported ? ui.Locale(device.languageCode) : const ui.Locale('en');
  }
}
