import 'package:domain/model/app_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/theme/dark_app_theme.dart';
import 'package:hello_flutter/presentation/theme/light_app_theme.dart';

extension AppThemeModeExtension on AppThemeMode {
  ThemeData get themeData {
    switch (this) {
      case AppThemeMode.system:
        return LightAppTheme().getThemeData();
      case AppThemeMode.light:
        return LightAppTheme().getThemeData();
      case AppThemeMode.dark:
        return DarkAppTheme().getThemeData();
    }
  }

  ThemeMode get materialThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
