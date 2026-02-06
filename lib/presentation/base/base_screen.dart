import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_viewmodel.dart';

abstract class BaseScreen<V extends BaseViewModel> extends StatelessWidget {
  abstract final V viewModel;

  const BaseScreen({super.key});
}
