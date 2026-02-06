class Movie {
  final String movieId;
  final String title;
  final int year;
  final double rating;
  final String poster;
  final bool isFavorite;

  Movie({
    required this.movieId,
    required this.title,
    required this.year,
    required this.rating,
    required this.poster,
    this.isFavorite = false,
  });
  
  Movie copyWith({
    String? movieId,
    String? title,
    int? year,
    double? rating,
    String? poster,
    bool? isFavorite,
  }) {
    return Movie(
      movieId: movieId ?? this.movieId,
      title: title ?? this.title,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      poster: poster ?? this.poster,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
