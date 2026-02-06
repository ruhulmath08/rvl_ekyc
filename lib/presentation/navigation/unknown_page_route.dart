import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_route.dart';
import 'package:hello_flutter/presentation/navigation/route_path.dart';

class UnknownRoute extends BaseRoute {
  @override
  RoutePath routePath = RoutePath.unknown;

  UnknownRoute({required super.arguments});

  @override
  MaterialPageRoute toMaterialPageRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Error: Route not found'),
        ),
      ),
    );
  }
}
