import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ 1. IMPORT THIS

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  static const String _selectedLocaleKey = 'selected_locale';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_selectedLocaleKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      _locale = Locale(languageCode);
      // We don't need to initialize here because main() already did it for us.
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    // First, check if we are actually changing the locale
    if (_locale?.languageCode == locale.languageCode) return;

    _locale = locale;

    // ✅ 2. ADD THIS LINE
    // This is the crucial step. When the user picks a new language,
    // we immediately load the date formatting rules for it.
    await initializeDateFormatting(locale.languageCode, null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocaleKey, locale.languageCode);

    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedLocaleKey);
    notifyListeners();
  }
}
