import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// =================================================================
// OROMO (om) LOCALIZATIONS
// =================================================================

class OromoMaterialLocalizations extends DefaultMaterialLocalizations {
  const OromoMaterialLocalizations();

  @override
  String get backButtonTooltip => 'Deebi\'i';

  @override
  String get cancelButtonLabel => 'Haqi';

  @override
  String get closeButtonLabel => 'Cufi';

  @override
  String get continueButtonLabel => 'Itti fufi';

  @override
  String get copyButtonLabel => 'Mallattoo baasi';

  @override
  String get cutButtonLabel => 'Muressi';

  @override
  String get deleteButtonTooltip => 'Haalli hir\'isu';

  @override
  String get pasteButtonLabel => 'Kuus';

  @override
  String get selectAllButtonLabel => 'Hunda filadhu';

  @override
  String get searchFieldLabel => 'Barbaadi';

  @override
  String get okButtonLabel => 'Tole';

  @override
  String get licensesPageTitle => 'Hayyama';
}

class OromoCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const OromoCupertinoLocalizations();

  @override
  String get alertDialogLabel => 'Dhimma bilisummaa';

  @override
  String get anteMeridiemAbbreviation => 'WD';

  @override
  String get postMeridiemAbbreviation => 'WB';

  @override
  String get todayLabel => 'Har\'a';

  @override
  String get copyButtonLabel => 'Mallattoo baasi';

  @override
  String get cutButtonLabel => 'Muressi';

  @override
  String get pasteButtonLabel => 'Kuus';

  @override
  String get selectAllButtonLabel => 'Hunda filadhu';

  @override
  String get modalBarrierDismissLabel => 'Dhiisi';
}

class OromoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const OromoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const OromoMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(OromoMaterialLocalizationsDelegate old) => false;
}

class OromoCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const OromoCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const OromoCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(OromoCupertinoLocalizationsDelegate old) => false;
}

// =================================================================
// SOMALI (so) LOCALIZATIONS
// =================================================================

class SomaliMaterialLocalizations extends DefaultMaterialLocalizations {
  const SomaliMaterialLocalizations();

  @override
  String get backButtonTooltip => 'Dib u noqo';

  @override
  String get cancelButtonLabel => 'Jooji';

  @override
  String get closeButtonLabel => 'Xir';

  @override
  String get continueButtonLabel => 'Sii wad';

  @override
  String get copyButtonLabel => 'Koobi';

  @override
  String get cutButtonLabel => 'Jar';

  @override
  String get deleteButtonTooltip => 'Tirtir';

  @override
  String get pasteButtonLabel => 'Dheji';

  @override
  String get selectAllButtonLabel => 'Dooro Dhammaan';

  @override
  String get searchFieldLabel => 'Raadi';

  @override
  String get okButtonLabel => 'HAYE';
}

class SomaliCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const SomaliCupertinoLocalizations();

  @override
  String get todayLabel => 'Maanta';

  @override
  String get copyButtonLabel => 'Koobi';

  @override
  String get cutButtonLabel => 'Jar';

  @override
  String get pasteButtonLabel => 'Dheji';

  @override
  String get selectAllButtonLabel => 'Dooro Dhammaan';

  @override
  String get modalBarrierDismissLabel => 'Iska tuur';
}

class SomaliMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SomaliMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const SomaliMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(SomaliMaterialLocalizationsDelegate old) => false;
}

class SomaliCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SomaliCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const SomaliCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(SomaliCupertinoLocalizationsDelegate old) => false;
}

// =================================================================
// TIGRINYA (ti) LOCALIZATIONS
// =================================================================

class TigrinyaMaterialLocalizations extends DefaultMaterialLocalizations {
  const TigrinyaMaterialLocalizations();

  @override
  String get backButtonTooltip => 'ተመለስ';

  @override
  String get cancelButtonLabel => 'ስረዝ';

  @override
  String get closeButtonLabel => 'ዕጸው';

  @override
  String get continueButtonLabel => 'ቀጽል';

  @override
  String get copyButtonLabel => 'ቅዳሕ';

  @override
  String get cutButtonLabel => 'ቁረጽ';

  @override
  String get deleteButtonTooltip => 'ሰርዝ';

  @override
  String get pasteButtonLabel => 'ለጥፍ';

  @override
  String get selectAllButtonLabel => 'ኩሉ ምረጽ';

  @override
  String get searchFieldLabel => 'ድለ';

  @override
  String get okButtonLabel => 'ሕራይ';
}

class TigrinyaCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const TigrinyaCupertinoLocalizations();

  @override
  String get todayLabel => 'ሎሚ';

  @override
  String get copyButtonLabel => 'ቅዳሕ';

  @override
  String get cutButtonLabel => 'ቁረጽ';

  @override
  String get pasteButtonLabel => 'ለጥፍ';

  @override
  String get selectAllButtonLabel => 'ኩሉ ምረጽ';

  @override
  String get modalBarrierDismissLabel => 'ኣወግድ';
}

class TigrinyaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const TigrinyaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const TigrinyaMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(TigrinyaMaterialLocalizationsDelegate old) => false;
}

class TigrinyaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const TigrinyaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const TigrinyaCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(TigrinyaCupertinoLocalizationsDelegate old) => false;
}
