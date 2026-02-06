import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/common/extension/context_ext.dart';
import 'package:hello_flutter/presentation/feature/auth/login/screen/login_ui_mobile_portrait.dart';
import 'package:hello_flutter/presentation/values/app_assets.dart';
import 'package:hello_flutter/presentation/values/dimens.dart';

class LoginUiMobileLandscape extends LoginUiMobilePortrait {
  const LoginUiMobileLandscape({required super.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => LoginUiMobileLandscapeState();
}

class LoginUiMobileLandscapeState extends LoginUiMobilePortraitState {
  @override
  Widget logoView(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.appLogo,
          width: Dimens.dimen_50,
          height: Dimens.dimen_50,
        ),
        SizedBox(width: Dimens.dimen_10),
        Text(
          context.localizations.app_name,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  @override
  Widget emailAndPasswordFields(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: emailField(context)),
        const SizedBox(width: 10.0),
        Expanded(child: passwordField(context)),
      ],
    );
  }
}
