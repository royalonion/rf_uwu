import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale("hu_hu") +
      {
        "en_en": {
          "next": "Next",
          "remaining min": "%d min(s)",
          "remaining sec": "%d sec(s)",
          "break": "Break",
          "go to room": "Go to room %s.",
          "go ground floor": "Go to the ground floor.",
          "go up floor": "Go upstairs, to floor %d.",
          "go down floor": "Go downstaris, to floor %d.",
          "stay": "Stay in this room.",
          "first_lesson_1": "Your first lesson will be ",
          "first_lesson_2": " in room ",
          "first_lesson_3": ", at ",
          "first_lesson_4": ".",
          // segmented countdown
          "h": "hour(s)",
          "m": "min(s)",
          "s": "sec(s)",
          // v5
          "first_lesson_soon": "Your first lesson starts soon!",
          "go_home": "You've no more lessons today",
        },
        "hu_hu": {
          "next": "Következő",
          "remaining min": "%d perc",
          "remaining sec": "%d másodperc",
          "break": "Szünet",
          "go to room": "Menj a(z) %s terembe.",
          "go ground floor": "Menj a földszintre.",
          "go up floor": "Menj fel a(z) %d. emeletre.",
          "go down floor": "Menj le a(z) %d. emeletre.",
          "stay": "Maradj ebben a teremben.",
          "first_lesson_1": "Az első órád ",
          "first_lesson_2": " lesz, a ",
          "first_lesson_3": " teremben, ",
          "first_lesson_4": "-kor.",
          // segmented countdown
          "h": "óra",
          "m": "perc",
          "s": "másodperc",
          // v5
          "first_lesson_soon": "Hamarosan kezdődik az első órád!",
          "go_home": "Ma már nincs több órád",
        },
        "de_de": {
          "next": "Nächste",
          "remaining min": "%d Minute(n)",
          "remaining sec": "%d Sekunde(n)",
          "break": "Pause",
          "go to room": "Geh in den Raum %s.",
          "go ground floor": "Geh dir Treppe hinunter.",
          "go up floor": "Geh in die %d. Stock hinauf.",
          "go down floor": "Geh runter in den %d. Stock.",
          "stay": "Im Zimmer bleiben.",
          "first_lesson_1": "Ihre erste Stunde ist ",
          "first_lesson_2": ", in Raum ",
          "first_lesson_3": ", um ",
          "first_lesson_4": " Uhr.",
          // segmented countdown
          "h": "Stunden",
          "m": "Minute",
          "s": "Sekunde",
          // v5
          "first_lesson_soon": "Ihre erste Unterrichtsstunde beginnt bald!",
          "go_home": "Sie haben heute keinen Unterricht mehr",
        },
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
  String version(Object modifier) => localizeVersion(modifier, this, _t);
}
