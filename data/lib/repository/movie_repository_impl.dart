import 'package:data/mapper/genre_mapper.dart';
import 'package:data/mapper/movie_details_mapper.dart';
import 'package:data/mapper/movie_mapper.dart';
import 'package:data/remote/api_service/movie_api_service.dart';
import 'package:domain/model/genre.dart';
import 'package:domain/model/movie.dart';
import 'package:domain/model/movie_details.dart';
import 'package:domain/model/movie_list_by_category.dart';
import 'package:domain/repository/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieApiService movieApiService;

  MovieRepositoryImpl({required this.movieApiService});

  @override
  Future<List<Movie>?> getMovieList() async {
    final movieListResponse = await movieApiService.getMovies();
    return movieListResponse.data?.movies
        ?.map((e) => MovieMapper.mapResponseToDomain(e))
        .toList();
  }

  @override
  Future<List<Movie>> searchMovies({required String query}) async {
    final searchMoviesResponse =
        await movieApiService.searchMovies(query: query);
    return searchMoviesResponse.data?.movies
            ?.map((e) => MovieMapper.mapResponseToDomain(e))
            .toList() ??
        [];
  }

  @override
  Future<List<Movie>?> getMovieListByGenre({required Genre genre}) async {
    final movieListByGenreResponse = await movieApiService.getMoviesByGenre(
        genre: GenreMapper.mapDomainToRequest(genre));
    return movieListByGenreResponse.data?.movies
        ?.map((e) => MovieMapper.mapResponseToDomain(e))
        .toList();
  }

  @override
  Future<MovieDetails?> getMovieDetails({required String movieId}) async {
    final movieDetailsResponse =
        await movieApiService.getMovieDetails(movieId: movieId);
    if (movieDetailsResponse.data?.movie != null) {
      return MovieDetailsMapper.mapResponseToDomain(
        movieDetailsResponse.data!.movie!,
      );
    }
    return null;
  }

  @override
  Future<List<MovieListByGenre>> getMoviesGroupedByGenre() async {
    List<MovieListByGenre> allGenreMovies = [];
    List<Genre> genres = [
      Genre.action,
      Genre.adventure,
      Genre.animation,
      Genre.sciFi,
      Genre.thriller,
    ];

    List<Future<List<Movie>?>> futures = [
      for (var genre in genres) getMovieListByGenre(genre: genre)
    ];

    List<List<Movie>?> movies = await Future.wait(futures);

    for (int i = 0; i < genres.length; i++) {
      if (movies[i] == null || movies[i]!.isEmpty) {
        continue;
      }
      allGenreMovies.add(
        MovieListByGenre(
          genre: genres[i],
          movies: movies[i]!,
        ),
      );
    }
    return allGenreMovies;
  }
}
