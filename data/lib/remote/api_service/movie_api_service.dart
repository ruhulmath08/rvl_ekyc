import 'package:data/remote/response/movie_details_response.dart';
import 'package:data/remote/response/movie_list_response.dart';

abstract class MovieApiService {
  Future<MovieListResponse> getMovies();

  Future<MovieListResponse> searchMovies({required String query});

  Future<MovieListResponse> getMoviesByGenre({required String genre});

  Future<MovieDetailsResponse> getMovieDetails({required String movieId});
}
