import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/ekyc/screen/ekyc_mobile_portrait.dart';

class EkycMobileLandscape extends EkycMobilePortrait {
  const EkycMobileLandscape({required super.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => EkycMobileLandscapeState();
}

class EkycMobileLandscapeState extends EkycMobilePortraitState {}
