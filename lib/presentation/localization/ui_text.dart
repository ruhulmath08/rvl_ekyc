import 'package:hello_flutter/presentation/localization/generated/app_localizations.dart';
import 'package:hello_flutter/presentation/localization/text_id.dart';

abstract class UiText {
  TextId get textId;

  String extract({AppLocalizations? localizations});
}

class DynamicUiText extends UiText {
  @override
  final TextId textId;
  final String fallbackText;

  DynamicUiText({
    required this.textId,
    required this.fallbackText,
  });

  @override
  String extract({AppLocalizations? localizations}) {
    if (localizations != null) {
      return textId.getLocalizedText(localizations);
    } else {
      return fallbackText;
    }
  }
}

class FixedUiText extends UiText {
  final String text;

  FixedUiText({required this.text});

  @override
  TextId get textId => EmptyTextId();

  @override
  String extract({AppLocalizations? localizations}) => text;
}
