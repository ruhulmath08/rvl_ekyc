import 'package:domain/model/genre.dart';
import 'package:hello_flutter/presentation/localization/generated/app_localizations.dart';

extension GenreLocalizationExt on Genre {
  String getLocalizedName(AppLocalizations localizations) {
    switch (this) {
      case Genre.action:
        return localizations.genre__action;
      case Genre.adventure:
        return localizations.genre__adventure;
      case Genre.animation:
        return localizations.genre__animation;
      case Genre.sciFi:
        return localizations.genre__sci_fi;
      case Genre.thriller:
        return localizations.genre__thriller;
      default:
        return '';
    }
  }
}
