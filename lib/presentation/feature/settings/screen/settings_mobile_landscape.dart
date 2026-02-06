import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/settings/screen/settings_mobile_portrait.dart';
import 'package:hello_flutter/presentation/feature/settings/screen/widgets/language_settings.dart';
import 'package:hello_flutter/presentation/feature/settings/screen/widgets/theme_settings.dart';

class SettingsMobileLandscape extends SettingsMobilePortrait {
  const SettingsMobileLandscape({required super.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => SettingsMobileLandscapeState();
}

class SettingsMobileLandscapeState extends SettingsMobilePortraitState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ThemeSettings(viewModel: widget.viewModel),
            LanguageSettings(viewModel: widget.viewModel),
          ],
        ),
      ),
    );
  }
}
