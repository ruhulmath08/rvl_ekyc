// To parse this JSON data, do
//
//     final movieListResponse = movieListResponseFromJson(jsonString);

import 'dart:convert';

MovieListResponse movieListResponseFromJson(String str) => MovieListResponse.fromJson(json.decode(str));

String movieListResponseToJson(MovieListResponse data) => json.encode(data.toJson());

class MovieListResponse {
  String? statusMessage;
  Data? data;
  Meta? meta;

  MovieListResponse({
    this.statusMessage,
    this.data,
    this.meta,
  });

  factory MovieListResponse.fromJson(Map<String, dynamic> json) => MovieListResponse(
    statusMessage: json["status_message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    meta: json["@meta"] == null ? null : Meta.fromJson(json["@meta"]),
  );

  Map<String, dynamic> toJson() => {
    "status_message": statusMessage,
    "data": data?.toJson(),
    "@meta": meta?.toJson(),
  };
}

class Data {
  int? movieCount;
  int? limit;
  int? pageNumber;
  List<Movie>? movies;

  Data({
    this.movieCount,
    this.limit,
    this.pageNumber,
    this.movies,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    movieCount: json["movie_count"],
    limit: json["limit"],
    pageNumber: json["page_number"],
    movies: json["movies"] == null ? [] : List<Movie>.from(json["movies"]!.map((x) => Movie.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "movie_count": movieCount,
    "limit": limit,
    "page_number": pageNumber,
    "movies": movies == null ? [] : List<dynamic>.from(movies!.map((x) => x.toJson())),
  };
}

class Movie {
  int? id;
  String? url;
  String? imdbCode;
  String? title;
  String? titleEnglish;
  String? titleLong;
  String? slug;
  int? year;
  double? rating;
  int? runtime;
  List<String>? genres;
  String? summary;
  String? descriptionFull;
  String? synopsis;
  String? ytTrailerCode;
  String? language;
  String? backgroundImage;
  String? backgroundImageOriginal;
  String? smallCoverImage;
  String? mediumCoverImage;
  String? largeCoverImage;
  DateTime? dateUploaded;
  int? dateUploadedUnix;

  Movie({
    this.id,
    this.url,
    this.imdbCode,
    this.title,
    this.titleEnglish,
    this.titleLong,
    this.slug,
    this.year,
    this.rating,
    this.runtime,
    this.genres,
    this.summary,
    this.descriptionFull,
    this.synopsis,
    this.ytTrailerCode,
    this.language,
    this.backgroundImage,
    this.backgroundImageOriginal,
    this.smallCoverImage,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    id: json["id"],
    url: json["url"],
    imdbCode: json["imdb_code"],
    title: json["title"],
    titleEnglish: json["title_english"],
    titleLong: json["title_long"],
    slug: json["slug"],
    year: json["year"],
    rating: json["rating"]?.toDouble(),
    runtime: json["runtime"],
    genres: json["genres"] == null ? [] : List<String>.from(json["genres"]!.map((x) => x)),
    summary: json["summary"],
    descriptionFull: json["description_full"],
    synopsis: json["synopsis"],
    ytTrailerCode: json["yt_trailer_code"],
    language: json["language"],
    backgroundImage: json["background_image"],
    backgroundImageOriginal: json["background_image_original"],
    smallCoverImage: json["small_cover_image"],
    mediumCoverImage: json["medium_cover_image"],
    largeCoverImage: json["large_cover_image"],
    dateUploaded: json["date_uploaded"] == null ? null : DateTime.parse(json["date_uploaded"]),
    dateUploadedUnix: json["date_uploaded_unix"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "imdb_code": imdbCode,
    "title": title,
    "title_english": titleEnglish,
    "title_long": titleLong,
    "slug": slug,
    "year": year,
    "rating": rating,
    "runtime": runtime,
    "genres": genres == null ? [] : List<dynamic>.from(genres!.map((x) => x)),
    "summary": summary,
    "description_full": descriptionFull,
    "synopsis": synopsis,
    "yt_trailer_code": ytTrailerCode,
    "language": language,
    "background_image": backgroundImage,
    "background_image_original": backgroundImageOriginal,
    "small_cover_image": smallCoverImage,
    "medium_cover_image": mediumCoverImage,
    "large_cover_image": largeCoverImage,
    "date_uploaded": dateUploaded?.toIso8601String(),
    "date_uploaded_unix": dateUploadedUnix,
  };
}
class Meta {
  int? serverTime;
  String? serverTimezone;
  int? apiVersion;
  String? executionTime;

  Meta({
    this.serverTime,
    this.serverTimezone,
    this.apiVersion,
    this.executionTime,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    serverTime: json["server_time"],
    serverTimezone: json["server_timezone"],
    apiVersion: json["api_version"],
    executionTime: json["execution_time"],
  );

  Map<String, dynamic> toJson() => {
    "server_time": serverTime,
    "server_timezone": serverTimezone,
    "api_version": apiVersion,
    "execution_time": executionTime,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
