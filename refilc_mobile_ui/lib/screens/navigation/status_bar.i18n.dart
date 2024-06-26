import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale("hu_hu") +
      {
        "en_en": {
          "Syncing data": "Syncing data...",
          "KRETA Maintenance": "KRETA Maintenance",
          "KRETA API error": "KRETA API Error",
          "No connection": "No connection",
        },
        "hu_hu": {
          "Syncing data": "Adatok frissítése...",
          "KRETA Maintenance": "KRÉTA Karbantartás",
          "KRETA API error": "KRÉTA API Hiba",
          "No connection": "Nincs kapcsolat",
        },
        "de_de": {
          "Syncing data": "Daten aktualisieren...",
          "KRETA Maintenance": "KRETA Wartung",
          "KRETA API error": "KRETA API Fehler",
          "No connection": "Keine Verbindung",
        },
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
  String version(Object modifier) => localizeVersion(modifier, this, _t);
}
