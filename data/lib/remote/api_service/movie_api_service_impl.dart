import 'package:data/remote/api_client/api_client.dart';
import 'package:data/remote/api_service/movie_api_service.dart';
import 'package:data/remote/response/movie_details_response.dart';
import 'package:data/remote/response/movie_list_response.dart';

class MovieApiServiceImpl implements MovieApiService {
  ApiClient apiClient;

  MovieApiServiceImpl({required this.apiClient});

  @override
  Future<MovieListResponse> getMovies() async {
    final response = await apiClient.get("/list_movies.json");
    return MovieListResponse.fromJson(response);
  }

  @override
  Future<MovieListResponse> searchMovies({required String query}) async {
    final response = await apiClient.get(
      "/list_movies.json",
      queryParameters: {"query_term": query},
    );
    return MovieListResponse.fromJson(response);
  }

  @override
  Future<MovieListResponse> getMoviesByGenre({required String genre}) async {
    final response = await apiClient.get(
      "/list_movies.json",
      queryParameters: {
        "genre": genre,
        "limit": "5",
      },
    );
    return MovieListResponse.fromJson(response);
  }

  @override
  Future<MovieDetailsResponse> getMovieDetails(
      {required String movieId}) async {
    final response = await apiClient.get(
      "/movie_details.json",
      queryParameters: {"movie_id": movieId},
    );
    return MovieDetailsResponse.fromJson(response);
  }
}
