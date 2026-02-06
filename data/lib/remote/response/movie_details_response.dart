// To parse this JSON data, do
//
//     final movieDetailsResponse = movieDetailsResponseFromJson(jsonString);

import 'dart:convert';

MovieDetailsResponse movieDetailsResponseFromJson(String str) => MovieDetailsResponse.fromJson(json.decode(str));

String movieDetailsResponseToJson(MovieDetailsResponse data) => json.encode(data.toJson());

class MovieDetailsResponse {
  String? status;
  String? statusMessage;
  Data? data;
  Meta? meta;

  MovieDetailsResponse({
    this.status,
    this.statusMessage,
    this.data,
    this.meta,
  });

  factory MovieDetailsResponse.fromJson(Map<String, dynamic> json) => MovieDetailsResponse(
    status: json["status"],
    statusMessage: json["status_message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    meta: json["@meta"] == null ? null : Meta.fromJson(json["@meta"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "status_message": statusMessage,
    "data": data?.toJson(),
    "@meta": meta?.toJson(),
  };
}

class Data {
  Movie? movie;

  Data({
    this.movie,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    movie: json["movie"] == null ? null : Movie.fromJson(json["movie"]),
  );

  Map<String, dynamic> toJson() => {
    "movie": movie?.toJson(),
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
  num? rating;
  int? runtime;
  List<String>? genres;
  int? likeCount;
  String? descriptionIntro;
  String? descriptionFull;
  String? ytTrailerCode;
  String? language;
  String? mpaRating;
  String? backgroundImage;
  String? backgroundImageOriginal;
  String? smallCoverImage;
  String? mediumCoverImage;
  String? largeCoverImage;
  List<Torrent>? torrents;
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
    this.likeCount,
    this.descriptionIntro,
    this.descriptionFull,
    this.ytTrailerCode,
    this.language,
    this.mpaRating,
    this.backgroundImage,
    this.backgroundImageOriginal,
    this.smallCoverImage,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.torrents,
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
    rating: json["rating"],
    runtime: json["runtime"],
    genres: json["genres"] == null ? [] : List<String>.from(json["genres"]!.map((x) => x)),
    likeCount: json["like_count"],
    descriptionIntro: json["description_intro"],
    descriptionFull: json["description_full"],
    ytTrailerCode: json["yt_trailer_code"],
    language: json["language"],
    mpaRating: json["mpa_rating"],
    backgroundImage: json["background_image"],
    backgroundImageOriginal: json["background_image_original"],
    smallCoverImage: json["small_cover_image"],
    mediumCoverImage: json["medium_cover_image"],
    largeCoverImage: json["large_cover_image"],
    torrents: json["torrents"] == null ? [] : List<Torrent>.from(json["torrents"]!.map((x) => Torrent.fromJson(x))),
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
    "like_count": likeCount,
    "description_intro": descriptionIntro,
    "description_full": descriptionFull,
    "yt_trailer_code": ytTrailerCode,
    "language": language,
    "mpa_rating": mpaRating,
    "background_image": backgroundImage,
    "background_image_original": backgroundImageOriginal,
    "small_cover_image": smallCoverImage,
    "medium_cover_image": mediumCoverImage,
    "large_cover_image": largeCoverImage,
    "torrents": torrents == null ? [] : List<dynamic>.from(torrents!.map((x) => x.toJson())),
    "date_uploaded": dateUploaded?.toIso8601String(),
    "date_uploaded_unix": dateUploadedUnix,
  };
}

class Torrent {
  String? url;
  String? hash;
  String? quality;
  String? type;
  String? isRepack;
  String? videoCodec;
  String? bitDepth;
  String? audioChannels;
  int? seeds;
  int? peers;
  String? size;
  int? sizeBytes;
  DateTime? dateUploaded;
  int? dateUploadedUnix;

  Torrent({
    this.url,
    this.hash,
    this.quality,
    this.type,
    this.isRepack,
    this.videoCodec,
    this.bitDepth,
    this.audioChannels,
    this.seeds,
    this.peers,
    this.size,
    this.sizeBytes,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) => Torrent(
    url: json["url"],
    hash: json["hash"],
    quality: json["quality"],
    type: json["type"],
    isRepack: json["is_repack"],
    videoCodec: json["video_codec"],
    bitDepth: json["bit_depth"],
    audioChannels: json["audio_channels"],
    seeds: json["seeds"],
    peers: json["peers"],
    size: json["size"],
    sizeBytes: json["size_bytes"],
    dateUploaded: json["date_uploaded"] == null ? null : DateTime.parse(json["date_uploaded"]),
    dateUploadedUnix: json["date_uploaded_unix"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "hash": hash,
    "quality": quality,
    "type": type,
    "is_repack": isRepack,
    "video_codec": videoCodec,
    "bit_depth": bitDepth,
    "audio_channels": audioChannels,
    "seeds": seeds,
    "peers": peers,
    "size": size,
    "size_bytes": sizeBytes,
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
