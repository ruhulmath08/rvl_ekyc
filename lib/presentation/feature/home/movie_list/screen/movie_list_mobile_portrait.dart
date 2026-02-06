import 'package:domain/model/movie.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_ui_state.dart';
import 'package:hello_flutter/presentation/common/extension/context_ext.dart';
import 'package:hello_flutter/presentation/common/widget/network_image_view.dart';
import 'package:hello_flutter/presentation/common/widget/rating_view.dart';
import 'package:hello_flutter/presentation/feature/home/movie_list/movie_list_view_model.dart';
import 'package:hello_flutter/presentation/localization/extension/genre_localization_ext.dart';
import 'package:hello_flutter/presentation/values/dimens.dart';

class MovieListUiMobilePortrait extends StatefulWidget {
  final MovieListViewModel viewModel;

  const MovieListUiMobilePortrait({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => MovieListUiMobilePortraitState();
}

class MovieListUiMobilePortraitState
    extends BaseUiState<MovieListUiMobilePortrait> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: genreWiseMovieExpandableList(),
    );
  }

  Widget genreWiseMovieExpandableList() {
    return valueListenableBuilder(
      listenable: widget.viewModel.moviesGroupedByGenre,
      builder: (context, value) {
        return ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            final movieListByGenre = value[index];
            return ExpansionTile(
              title: Text(
                movieListByGenre.genre.getLocalizedName(context.localizations),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: index == 0,
              shape: Border.all(color: Colors.transparent),
              children: movieListByGenre.movies
                  .map((e) => _movieListItemView(movieModel: e))
                  .toList(),
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
    return Card(
      elevation: Dimens.dimen_1,
      margin: EdgeInsets.all(Dimens.dimen_8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          vertical: Dimens.dimen_8,
          horizontal: Dimens.dimen_16,
        ),
        leading: NetworkImageView(
          url: movieModel.poster,
          width: Dimens.dimen_50,
          fit: BoxFit.fitHeight,
        ),
        title: Text(
          movieModel.title,
          style: textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${movieModel.year}',
                  style: textTheme.labelMedium,
                ),
                SizedBox(height: Dimens.dimen_2),
                RatingView(
                  rating: movieModel.rating,
                  maxRating: 10,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            const Spacer(),
            IconButton(
                onPressed: () {
                  widget.viewModel.onClickedFavorite(movieModel);
                },
                icon: Icon(movieModel.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border))
          ],
        ),
        onTap: () {
          widget.viewModel.onMovieItemClicked(movieModel);
        },
      ),
    );
  }
}
