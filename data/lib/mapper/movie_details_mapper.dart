import 'package:data/mapper/genre_mapper.dart';
import 'package:data/remote/response/movie_details_response.dart' as response;
import 'package:domain/model/movie_details.dart';

class MovieDetailsMapper {
  static MovieDetails mapResponseToDomain(response.Movie movieDetails) {
    return MovieDetails(
      title: movieDetails.title ?? '',
      fullDescription: movieDetails.descriptionFull ?? '',
      imageUrl: movieDetails.backgroundImageOriginal ?? '',
      rating: movieDetails.rating?.toDouble() ?? 0.0,
      genres: movieDetails.genres
              ?.map((e) => GenreMapper.mapResponseToDomain(e))
              .toList() ??
          [],
      releaseYear: movieDetails.year ?? 0,
    );
  }
}
