import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:domain/model/face_embedding_entity.dart';
import 'package:domain/exceptions/ekyc_exception.dart';

/// Service for generating face embeddings using TFLite
/// Uses MobileFaceNet or similar model
class FaceEmbeddingService {
  static const String _modelPath = 'assets/models/mobilefacenet.tflite';
  static const int _inputSize = 112; // Standard input size for MobileFaceNet
  static const int _embeddingSize = 192; // Output embedding dimension

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _initializationFailed = false;
  String? _initializationError;

  /// Initialize TFLite interpreter (lazy initialization)
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_initializationFailed) {
      throw FaceEmbeddingException(
        _initializationError ?? 'TFLite model initialization failed',
      );
    }

    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isInitialized = true;
    } catch (e) {
      _initializationFailed = true;
      final errorMessage = e.toString();
      if (errorMessage.contains('Unable to load asset') || 
          errorMessage.contains('not found')) {
        _initializationError = 
          'TFLite model file not found at $_modelPath\n\n'
          'To fix this:\n'
          '1. Download MobileFaceNet TFLite model\n'
          '2. Place it at: assets/models/mobilefacenet.tflite\n'
          '3. Run: flutter pub get\n'
          '4. Rebuild the app\n\n'
          'See assets/models/README.md for more details.';
        throw FaceEmbeddingException(_initializationError!);
      }
      _initializationError = 
        'Failed to load TFLite model: ${e.toString()}\n'
        'Please ensure the model file exists at $_modelPath';
      throw FaceEmbeddingException(_initializationError!);
    }
  }

  /// Check if model is available
  bool get isModelAvailable => _isInitialized && _interpreter != null;

  /// Generate face embedding from face image
  /// Image should be cropped to contain only the face
  Future<FaceEmbeddingEntity> generateEmbedding(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_interpreter == null) {
      throw FaceEmbeddingException('TFLite interpreter not initialized');
    }

    try {
      // Decode and preprocess image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw FaceEmbeddingException('Failed to decode image');
      }

      // Resize to model input size
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to float32 array and normalize
      final input = _preprocessImage(resizedImage);

      // Prepare output buffer
      final output = List.filled(_embeddingSize, 0.0).reshape([1, _embeddingSize]);

      // Run inference
      _interpreter!.run(input, output);

      // Normalize embedding vector (L2 normalization)
      final embedding = _normalizeEmbedding(output[0]);

      return FaceEmbeddingEntity(vector: embedding);
    } catch (e) {
      throw FaceEmbeddingException('Failed to generate embedding: ${e.toString()}');
    }
  }

  /// Preprocess image for TFLite model
  /// Converts to float32 and normalizes to [-1, 1]
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(
          _inputSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // Normalize to [-1, 1]
        input[0][y][x][0] = (r / 127.5) - 1.0;
        input[0][y][x][1] = (g / 127.5) - 1.0;
        input[0][y][x][2] = (b / 127.5) - 1.0;
      }
    }

    return input;
  }

  /// Normalize embedding vector using L2 normalization
  List<double> _normalizeEmbedding(List<double> embedding) {
    double norm = 0.0;
    for (final value in embedding) {
      norm += value * value;
    }
    norm = norm > 0 ? norm : 1.0;
    norm = norm;

    return embedding.map((value) => value / norm).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
