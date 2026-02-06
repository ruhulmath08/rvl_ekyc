import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/movieDetails/screen/movie_details_mobile_portrait.dart';

class MovieDetailsUiMobileLandscape extends MovieDetailsUiMobilePortrait {
  const MovieDetailsUiMobileLandscape({required super.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => MovieDetailsUiMobileLandscapeState();
}

class MovieDetailsUiMobileLandscapeState
    extends MovieDetailsUiMobilePortraitState {}
