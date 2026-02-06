enum AppLanguage {
  en,
  ja;

  @override
  String toString() {
    switch (this) {
      case AppLanguage.en:
        return 'en';
      case AppLanguage.ja:
        return 'ja';
    }
  }

  factory AppLanguage.fromString(String value) {
    switch (value) {
      case 'en':
        return AppLanguage.en;
      case 'jp':
        return AppLanguage.ja;
      default:
        return AppLanguage.en;
    }
  }
}
