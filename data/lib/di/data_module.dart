import 'package:data/remote/api_client/api_client.dart';
import 'package:data/remote/api_client/movie_api_client.dart';
import 'package:data/remote/api_service/movie_api_service.dart';
import 'package:data/remote/api_service/movie_api_service_impl.dart';
import 'package:data/repository/auth_repository_impl.dart';
import 'package:data/repository/location_repository_impl.dart';
import 'package:data/repository/movie_repository_impl.dart';
import 'package:data/repository/ekyc_repository_impl.dart';
import 'package:data/services/ml_kit/ocr_service.dart';
import 'package:data/services/ml_kit/face_detection_service.dart';
import 'package:data/services/tflite/face_embedding_service.dart';
import 'package:data/services/liveness/liveness_detection_service.dart';
import 'package:domain/di/di_module.dart';
import 'package:domain/repository/auth_repository.dart';
import 'package:domain/repository/location_repository.dart';
import 'package:domain/repository/movie_repository.dart';
import 'package:domain/repository/ekyc_repository.dart';

class DataModule {
  DataModule._internal();

  static final DataModule _instance = DataModule._internal();

  factory DataModule() => _instance;

  final DiModule _diModule = DiModule();

  Future<void> injectDependencies() async {
    await injectApiClient();
    await injectApiService();
    await injectLocalDataService();
    await injectEkycServices();
    await injectRepositories();
  }

  Future<void> removeDependencies() async {
    await removeApiClient();
    await removeApiService();
    await removeLocalDataService();
    await removeEkycServices();
    await removeRepositories();
  }

  Future<void> injectApiClient() async {
    await _diModule.registerSingleton<ApiClient>(MovieApiClient());
  }

  Future<void> removeApiClient() async {
    await _diModule.unregisterSingleton<ApiClient>();
  }

  Future<void> injectApiService() async {
    final apiClient = await _diModule.resolve<ApiClient>();
    await _diModule.registerSingleton<MovieApiService>(
      MovieApiServiceImpl(apiClient: apiClient),
    );
  }

  Future<void> removeApiService() async {
    await _diModule.unregisterSingleton<MovieApiService>();
  }

  Future<void> injectLocalDataService() async {
    //TODO: Implement local service injection
  }

  Future<void> removeLocalDataService() async {}

  Future<void> injectEkycServices() async {
    // Initialize ML Kit services
    await _diModule.registerSingleton<OcrService>(OcrService());
    await _diModule.registerSingleton<FaceDetectionService>(
      FaceDetectionService(),
    );
    await _diModule.registerSingleton<FaceEmbeddingService>(
      FaceEmbeddingService(),
    );

    // Note: Face embedding service initializes lazily when first used
    // This prevents app crash if model file is missing

    // Initialize liveness detection service
    final faceDetectionService = await _diModule.resolve<FaceDetectionService>();
    await _diModule.registerSingleton<LivenessDetectionService>(
      LivenessDetectionService(faceDetectionService: faceDetectionService),
    );
  }

  Future<void> removeEkycServices() async {
    try {
      final ocrService = await _diModule.resolve<OcrService>();
      ocrService.dispose();
    } catch (_) {}

    try {
      final faceDetectionService = await _diModule.resolve<FaceDetectionService>();
      faceDetectionService.dispose();
    } catch (_) {}

    try {
      final faceEmbeddingService = await _diModule.resolve<FaceEmbeddingService>();
      faceEmbeddingService.dispose();
    } catch (_) {}

    await _diModule.unregisterSingleton<OcrService>();
    await _diModule.unregisterSingleton<FaceDetectionService>();
    await _diModule.unregisterSingleton<FaceEmbeddingService>();
    await _diModule.unregisterSingleton<LivenessDetectionService>();
  }

  Future<void> injectRepositories() async {
    final movieApiService = await _diModule.resolve<MovieApiService>();
    await _diModule.registerSingleton<MovieRepository>(
      MovieRepositoryImpl(movieApiService: movieApiService),
    );

    await _diModule.registerSingleton<AuthRepository>(AuthRepositoryImpl());

    await _diModule
        .registerSingleton<LocationRepository>(LocationRepositoryImpl());

    // Inject eKYC repository
    final ocrService = await _diModule.resolve<OcrService>();
    final faceDetectionService = await _diModule.resolve<FaceDetectionService>();
    final faceEmbeddingService = await _diModule.resolve<FaceEmbeddingService>();
    final livenessDetectionService =
        await _diModule.resolve<LivenessDetectionService>();

    await _diModule.registerSingleton<EkycRepository>(
      EkycRepositoryImpl(
        ocrService: ocrService,
        faceDetectionService: faceDetectionService,
        faceEmbeddingService: faceEmbeddingService,
        livenessDetectionService: livenessDetectionService,
      ),
    );
  }

  Future<void> removeRepositories() async {
    await _diModule.unregisterSingleton<MovieRepository>();
    await _diModule.unregisterSingleton<EkycRepository>();
  }
}
