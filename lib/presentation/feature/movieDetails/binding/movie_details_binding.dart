import 'package:domain/repository/movie_repository.dart';
import 'package:hello_flutter/presentation/base/base_binding.dart';
import 'package:hello_flutter/presentation/feature/movieDetails/movie_details_view_model.dart';

class MovieDetailsBinding extends BaseBinding {
  @override
  Future<void> addDependencies() async {
    MovieRepository movieRepository = await diModule.resolve<MovieRepository>();
    return diModule.registerInstance(
      MovieDetailsViewModel(movieRepository: movieRepository),
    );
  }

  @override
  Future<void> removeDependencies() async {
    return diModule.unregister<MovieDetailsViewModel>();
  }
}
