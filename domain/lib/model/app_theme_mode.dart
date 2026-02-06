enum AppThemeMode {
  system,
  light,
  dark;

  @override
  String toString() {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  factory AppThemeMode.fromString(String value) {
    switch (value) {
      case 'system':
        return AppThemeMode.system;
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        throw ArgumentError('Invalid AppThemeMode: $value');
    }
  }
}
