import 'package:flutter/material.dart';

Widget overflowScrollView({Widget? child}) {
  return LayoutBuilder(builder: ((context, constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
          maxWidth: constraints.maxWidth,
        ),
        child: child,
      ),
    );
  }));
}