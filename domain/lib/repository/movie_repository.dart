import 'package:domain/model/genre.dart';
import 'package:domain/model/movie.dart';
import 'package:domain/model/movie_details.dart';
import 'package:domain/model/movie_list_by_category.dart';

abstract class MovieRepository {
  Future<List<Movie>?> getMovieList();

  Future<List<Movie>> searchMovies({required String query});

  Future<List<Movie>?> getMovieListByGenre({required Genre genre});

  Future<MovieDetails?> getMovieDetails({required String movieId});

  Future<List<MovieListByGenre>> getMoviesGroupedByGenre();
}
