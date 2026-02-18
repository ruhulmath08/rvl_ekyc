import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_route.dart';
import 'package:hello_flutter/presentation/navigation/route_path.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_adaptive_ui.dart';
import 'package:hello_flutter/presentation/feature/ekyc/route/ekyc_argument.dart';

class EkycRoute extends BaseRoute<EkycArgument> {
  @override
  RoutePath routePath = RoutePath.ekyc;

  EkycRoute({required super.arguments});

  @override
  MaterialPageRoute toMaterialPageRoute() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routePath.name),
      builder: (_) => EkycAdaptiveUi(
        argument: arguments,
      ),
    );
  }
}
