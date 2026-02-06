import 'package:domain/model/genre.dart';

class MovieDetails {
  final String title;
  final String fullDescription;
  final String imageUrl;
  final double rating;
  final List<Genre> genres;
  final int releaseYear;

  MovieDetails({
    required this.title,
    required this.fullDescription,
    required this.imageUrl,
    required this.rating,
    required this.genres,
    required this.releaseYear,
  });
}
