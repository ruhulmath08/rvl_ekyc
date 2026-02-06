import 'package:domain/model/genre.dart';

class GenreMapper {
  static Genre mapResponseToDomain(String genreString) {
    switch (genreString) {
      case 'Action':
        return Genre.action;
      case 'Adventure':
        return Genre.adventure;
      case 'Animation':
        return Genre.animation;
      case 'Biography':
        return Genre.biography;
      case 'Comedy':
        return Genre.comedy;
      case 'Crime':
        return Genre.crime;
      case 'Drama':
        return Genre.drama;
      case 'Family':
        return Genre.family;
      case 'Fantasy':
        return Genre.fantasy;
      case 'History':
        return Genre.history;
      case 'Horror':
        return Genre.horror;
      case 'Music':
        return Genre.music;
      case 'Mystery':
        return Genre.mystery;
      case 'Romance':
        return Genre.romance;
      case 'Sci-Fi':
        return Genre.sciFi;
      case 'Sport':
        return Genre.sport;
      case 'Thriller':
        return Genre.thriller;
      case 'War':
        return Genre.war;
      case 'Western':
        return Genre.western;
      default:
        return Genre.action;
    }
  }

  static String mapDomainToRequest(Genre genre) {
    switch (genre) {
      case Genre.action:
        return 'Action';
      case Genre.adventure:
        return 'Adventure';
      case Genre.animation:
        return 'Animation';
      case Genre.biography:
        return 'Biography';
      case Genre.comedy:
        return 'Comedy';
      case Genre.crime:
        return 'Crime';
      case Genre.drama:
        return 'Drama';
      case Genre.family:
        return 'Family';
      case Genre.fantasy:
        return 'Fantasy';
      case Genre.history:
        return 'History';
      case Genre.horror:
        return 'Horror';
      case Genre.music:
        return 'Music';
      case Genre.mystery:
        return 'Mystery';
      case Genre.romance:
        return 'Romance';
      case Genre.sciFi:
        return 'Sci-Fi';
      case Genre.sport:
        return 'Sport';
      case Genre.thriller:
        return 'Thriller';
      case Genre.war:
        return 'War';
      case Genre.western:
        return 'Western';
    }
  }
}
