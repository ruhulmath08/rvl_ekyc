import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_route.dart';
import 'package:hello_flutter/presentation/feature/settings/route/settings_argument.dart';
import 'package:hello_flutter/presentation/feature/settings/settings_adaptive_ui.dart';
import 'package:hello_flutter/presentation/navigation/route_path.dart';

class SettingsRoute extends BaseRoute<SettingsArgument> {
  @override
  RoutePath routePath = RoutePath.setting;

  SettingsRoute({required super.arguments});

  @override
  MaterialPageRoute toMaterialPageRoute() {
    return MaterialPageRoute(
      builder: (_) => SettingsAdaptiveUi(argument: super.arguments),
    );
  }
}
