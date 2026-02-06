import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_route.dart';
import 'package:hello_flutter/presentation/feature/home/home_adaptive_ui.dart';
import 'package:hello_flutter/presentation/feature/home/route/home_argument.dart';
import 'package:hello_flutter/presentation/navigation/route_path.dart';

class HomeRoute extends BaseRoute<HomeArgument> {
  @override
  RoutePath routePath = RoutePath.home;

  HomeRoute({required HomeArgument arguments}) : super(arguments: arguments);

  @override
  MaterialPageRoute toMaterialPageRoute() {
    return MaterialPageRoute(
      builder: (_) => HomeAdaptiveUi(argument: arguments as HomeArgument),
    );
  }
}
