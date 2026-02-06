import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_adaptive_ui.dart';
import 'package:hello_flutter/presentation/feature/auth/login/binding/login_binding.dart';
import 'package:hello_flutter/presentation/feature/auth/login/login_view_model.dart';
import 'package:hello_flutter/presentation/feature/auth/login/route/login_argument.dart';
import 'package:hello_flutter/presentation/feature/auth/login/route/login_route.dart';
import 'package:hello_flutter/presentation/feature/auth/login/screen/login_ui_mobile_landscape.dart';
import 'package:hello_flutter/presentation/feature/auth/login/screen/login_ui_mobile_portrait.dart';

class LoginAdaptiveUi extends BaseAdaptiveUi<LoginArgument, LoginRoute> {
  const LoginAdaptiveUi({super.key});

  @override
  State<StatefulWidget> createState() => LoginAdaptiveUiState();
}

class LoginAdaptiveUiState extends BaseAdaptiveUiState<LoginArgument,
    LoginRoute, LoginAdaptiveUi, LoginViewModel, LoginBinding> {
  @override
  LoginBinding binding = LoginBinding();

  @override
  StatefulWidget mobilePortraitContents(BuildContext context) {
    return LoginUiMobilePortrait(viewModel: viewModel);
  }

  @override
  StatefulWidget mobileLandscapeContents(BuildContext context) {
    return LoginUiMobileLandscape(viewModel: viewModel);
  }
}
