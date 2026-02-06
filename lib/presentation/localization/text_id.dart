import 'package:hello_flutter/presentation/localization/generated/app_localizations.dart';

abstract class TextId {
  String getLocalizedText(AppLocalizations localizations);
}

class EmptyTextId extends TextId {
  @override
  String getLocalizedText(AppLocalizations localizations) {
    return "";
  }
}

class NetworkErrorMessageWithCodeAndMessageTextId extends TextId {
  int code;
  String message;

  NetworkErrorMessageWithCodeAndMessageTextId({
    required this.code,
    required this.message,
  });

  @override
  String getLocalizedText(AppLocalizations localizations) {
    return localizations.error__network_error_with_error_and_message(
      code,
      message,
    );
  }
}

class PleaseFillUpAllTheRequiredFieldsTextId extends TextId {
  @override
  String getLocalizedText(AppLocalizations localizations) {
    return localizations.error_please_fill_up_all_fields;
  }
}

class PleaseCheckYourInternetConnection extends TextId {
  @override
  String getLocalizedText(AppLocalizations localizations) {
    return localizations.error_massage__please_check_your_internet_connection;
  }
}
