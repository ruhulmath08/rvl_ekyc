import 'package:domain/model/movie.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/common/extension/context_ext.dart';
import 'package:hello_flutter/presentation/common/widget/network_image_view.dart';
import 'package:hello_flutter/presentation/common/widget/rating_view.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/screen/movie_list_mobile_portrait.dart';
import 'package:hello_flutter/presentation/localization/extension/genre_localization_ext.dart';
import 'package:hello_flutter/presentation/values/dimens.dart';

class MovieListUiMobileLandscape extends MovieListUiMobilePortrait {
  const MovieListUiMobileLandscape({required super.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => MovieListUiMobileLandscapeState();
}

class MovieListUiMobileLandscapeState extends MovieListUiMobilePortraitState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: genreWiseMovieListHorizontal(),
    );
  }

  Widget genreWiseMovieListHorizontal() {
    return valueListenableBuilder(
      listenable: widget.viewModel.moviesGroupedByGenre,
      builder: (context, value) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: value.length,
          itemBuilder: (context, index) {
            final movie = value[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimens.dimen_8),
                  child: Text(
                    movie.genre.getLocalizedName(context.localizations),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  height: Dimens.dimen_250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movie.movies.length,
                    itemBuilder: (context, index) {
                      final movieModel = movie.movies[index];
                      return SizedBox(
                        width: Dimens.dimen_200,
                        child: _movieListItemView(movieModel: movieModel),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _movieListItemView({
    required Movie movieModel,
  }) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => widget.viewModel.onMovieItemClicked(movieModel),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: Dimens.dimen_1,
        margin: EdgeInsets.all(Dimens.dimen_8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NetworkImageView(
              url: movieModel.poster,
              height: Dimens.dimen_150,
              fit: BoxFit.cover,
            ),
            Text(
              movieModel.title,
              style: textTheme.titleMedium,
              maxLines: 1,
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.dimen_8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${movieModel.year}',
                    style: textTheme.labelMedium,
                    maxLines: 1,
                  ),
                  SizedBox(height: Dimens.dimen_2),
                  RatingView(
                    rating: movieModel.rating,
                    maxRating: 10,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
