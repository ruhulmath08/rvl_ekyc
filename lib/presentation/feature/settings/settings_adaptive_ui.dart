import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_adaptive_ui.dart';
import 'package:hello_flutter/presentation/feature/settings/binding/settings_binding.dart';
import 'package:hello_flutter/presentation/feature/settings/route/settings_argument.dart';
import 'package:hello_flutter/presentation/feature/settings/route/settings_route.dart';
import 'package:hello_flutter/presentation/feature/settings/screen/settings_mobile_landscape.dart';
import 'package:hello_flutter/presentation/feature/settings/screen/settings_mobile_portrait.dart';
import 'package:hello_flutter/presentation/feature/settings/settings_view_model.dart';

class SettingsAdaptiveUi
    extends BaseAdaptiveUi<SettingsArgument, SettingsRoute> {
  const SettingsAdaptiveUi({super.argument, super.key});

  @override
  State<StatefulWidget> createState() => SettingsAdaptiveUiState();
}

class SettingsAdaptiveUiState extends BaseAdaptiveUiState<SettingsArgument,
    SettingsRoute, SettingsAdaptiveUi, SettingsViewModel, SettingsBinding> {
  @override
  SettingsBinding binding = SettingsBinding();

  @override
  StatefulWidget mobilePortraitContents(BuildContext context) {
    return SettingsMobilePortrait(viewModel: viewModel);
  }

  @override
  StatefulWidget mobileLandscapeContents(BuildContext context) {
    return SettingsMobileLandscape(viewModel: viewModel);
  }
}
