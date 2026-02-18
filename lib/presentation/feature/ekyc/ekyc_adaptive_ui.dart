import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_adaptive_ui.dart';
import 'package:hello_flutter/presentation/feature/ekyc/binding/ekyc_binding.dart';
import 'package:hello_flutter/presentation/feature/ekyc/route/ekyc_argument.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';
import 'package:hello_flutter/presentation/feature/ekyc/route/ekyc_route.dart';
import 'package:hello_flutter/presentation/feature/ekyc/screen/ekyc_mobile_portrait.dart';
import 'package:hello_flutter/presentation/feature/ekyc/screen/ekyc_mobile_landscape.dart';

class EkycAdaptiveUi extends BaseAdaptiveUi<EkycArgument, EkycRoute> {
  const EkycAdaptiveUi({super.argument, super.key});

  @override
  State<StatefulWidget> createState() => EkycAdaptiveUiState();
}

class EkycAdaptiveUiState extends BaseAdaptiveUiState<EkycArgument, EkycRoute, EkycAdaptiveUi, EkycViewModel, EkycBinding> {
  @override
  EkycBinding binding = EkycBinding();

  @override
  StatefulWidget mobilePortraitContents(BuildContext context) {
    return EkycMobilePortrait(viewModel: viewModel);
  }

  @override
  StatefulWidget mobileLandscapeContents(BuildContext context) {
    return EkycMobileLandscape(viewModel: viewModel);
  }
}
