import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello_flutter/presentation/values/dimens.dart';

class AppTextTheme extends TextTheme {
  final TextStyle _commonTextStyle = GoogleFonts.inter();

  @override
  TextStyle? get displayLarge => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_57,
      );

  @override
  TextStyle? get displayMedium => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_45,
      );

  @override
  TextStyle? get displaySmall => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_44,
      );

  @override
  TextStyle? get headlineLarge => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_32,
      );

  @override
  TextStyle? get headlineMedium => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_28,
      );

  @override
  TextStyle? get headlineSmall => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_24,
        fontWeight: FontWeight.w600,
      );

  @override
  TextStyle? get titleLarge => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_22,
        fontWeight: FontWeight.w600,
      );

  @override
  TextStyle? get titleMedium => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_16,
        fontWeight: FontWeight.w600,
      );

  @override
  TextStyle? get titleSmall => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_14,
      );

  @override
  TextStyle? get labelLarge => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_16,
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle? get labelMedium => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_12,
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle? get labelSmall => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_11,
      );

  @override
  TextStyle? get bodyLarge => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_16,
      );

  @override
  TextStyle? get bodyMedium => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_14,
        fontWeight: FontWeight.w400,
      );

  @override
  TextStyle? get bodySmall => _commonTextStyle.copyWith(
        fontSize: Dimens.dimen_12,
      );
}
