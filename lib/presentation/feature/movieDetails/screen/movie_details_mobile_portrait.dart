import 'package:flutter/material.dart';
import 'package:domain/model/genre.dart';
import 'package:domain/model/movie_details.dart';
import 'package:hello_flutter/presentation/base/base_ui_state.dart';
import 'package:hello_flutter/presentation/common/widget/network_image_view.dart';
import 'package:hello_flutter/presentation/common/widget/rating_view.dart';
import 'package:hello_flutter/presentation/feature/movieDetails/movie_details_view_model.dart';
import 'package:hello_flutter/presentation/values/dimens.dart';

class MovieDetailsUiMobilePortrait extends StatefulWidget {
  final MovieDetailsViewModel viewModel;

  const MovieDetailsUiMobilePortrait({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => MovieDetailsUiMobilePortraitState();
}

class MovieDetailsUiMobilePortraitState
    extends BaseUiState<MovieDetailsUiMobilePortrait> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: valueListenableBuilder(
        listenable: widget.viewModel.movie,
        builder: (context, value) {
          return value != null
              ? _movieDetailsView(movieDetailsModel: value)
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _movieDetailsView({
    required MovieDetails movieDetailsModel,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMoviePoster(movieDetailsModel.imageUrl),
          _buildMovieInfo(movieDetailsModel)
        ],
      ),
    );
  }

  Widget _buildMoviePoster(String imageUrl) {
    return NetworkImageView(
      url: imageUrl,
      height: Dimens.dimen_250,
      fit: BoxFit.cover,
    );
  }

  Widget _buildMovieInfo(MovieDetails movieDetailsModel) {
    return Padding(
      padding: EdgeInsets.all(Dimens.dimen_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title of the movie
          Text(
            movieDetailsModel.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Dimens.dimen_8),

          // Release year
          Text(
            'Release Year: ${movieDetailsModel.releaseYear}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          SizedBox(height: Dimens.dimen_8),

          // Rating
          RatingView(rating: movieDetailsModel.rating, maxRating: 10),

          SizedBox(height: Dimens.dimen_8),

          //Genre
          _buildGenres(movieDetailsModel.genres),

          SizedBox(height: Dimens.dimen_8),

          // Full description
          Text(
            movieDetailsModel.fullDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildGenres(List<Genre> genres) {
    return Wrap(
      children: genres
          .map((e) => Padding(
                padding: EdgeInsets.only(right: Dimens.dimen_4),
                child: Chip(
                  label: Text(e.toString().split('.').last),
                ),
              ))
          .toList(),
    );
  }
}
