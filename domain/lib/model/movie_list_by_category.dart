import 'package:domain/model/genre.dart';
import 'package:domain/model/movie.dart';

class MovieListByGenre {
  final Genre genre;
  final List<Movie> movies;

  MovieListByGenre({
    required this.genre,
    required this.movies,
  });
}
