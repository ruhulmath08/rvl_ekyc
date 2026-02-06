import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_adaptive_ui.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/binding/movie_list_binding.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/movie_list_view_model.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/route/movie_list_argument.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/route/movie_list_route.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/screen/movie_list_mobile_landscape.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/screen/movie_list_mobile_portrait.dart';

class MovieListAdaptiveUi
    extends BaseAdaptiveUi<MovieListArgument, MovieListRoute> {
  const MovieListAdaptiveUi({super.key});

  @override
  State<StatefulWidget> createState() => MovieListAdaptiveUiState();
}

class MovieListAdaptiveUiState extends BaseAdaptiveUiState<MovieListArgument,
    MovieListRoute, MovieListAdaptiveUi, MovieListViewModel, MovieListBinding> {
  @override
  MovieListBinding binding = MovieListBinding();

  @override
  StatefulWidget mobilePortraitContents(BuildContext context) {
    return MovieListUiMobilePortrait(viewModel: viewModel);
  }

  @override
  StatefulWidget mobileLandscapeContents(BuildContext context) {
    return MovieListUiMobileLandscape(viewModel: viewModel);
  }
}
