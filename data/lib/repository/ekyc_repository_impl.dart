import 'dart:typed_data';
import 'package:data/services/tflite/face_embedding_service.dart';
import 'package:domain/model/captured_image_entity.dart';
import 'package:domain/model/document_info_entity.dart';
import 'package:domain/model/document_side.dart';
import 'package:domain/model/face_detection_result_entity.dart';
import 'package:domain/model/face_embedding_entity.dart';
import 'package:domain/model/liveness_result_entity.dart';
import 'package:domain/model/verification_result_entity.dart';
import 'package:domain/repository/ekyc_repository.dart';
import 'package:data/services/ml_kit/ocr_service.dart';
import 'package:data/services/ml_kit/face_detection_service.dart';
import 'package:data/services/liveness/liveness_detection_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as mlkit;
import 'package:image/image.dart' as img;

/// Implementation of EkycRepository
/// All operations are performed on-device
class EkycRepositoryImpl implements EkycRepository {
  final OcrService _ocrService;
  final FaceDetectionService _faceDetectionService;
  final FaceEmbeddingService _faceEmbeddingService;
  final LivenessDetectionService _livenessDetectionService;

  EkycRepositoryImpl({
    required OcrService ocrService,
    required FaceDetectionService faceDetectionService,
    required FaceEmbeddingService faceEmbeddingService,
    required LivenessDetectionService livenessDetectionService,
  }) : _ocrService = ocrService,
       _faceDetectionService = faceDetectionService,
       _faceEmbeddingService = faceEmbeddingService,
       _livenessDetectionService = livenessDetectionService;

  @override
  Future<DocumentInfoEntity> extractDocumentText(
    CapturedImageEntity image, {
    DocumentSide? side,
  }) async {
    return await _ocrService.extractText(
      image.bytes,
      image.width,
      image.height,
      side: side,
    );
  }

  @override
  Future<FaceDetectionResultEntity> detectDocumentFace(
    CapturedImageEntity image,
  ) async {
    // Document images are JPEG files from camera.takePicture()
    // Explicitly use a format that will force file-based approach (not NV21)
    // Using yuv420 ensures it won't match NV21 size check and will use file-based processing
    return await _faceDetectionService.detectFaces(
      image.bytes,
      image.width,
      image.height,
      imageFormat: mlkit.InputImageFormat.yuv420, // Force file-based approach for JPEG documents
    );
  }

  @override
  Future<FaceDetectionResultEntity> detectSelfieFace(
    CapturedImageEntity image,
  ) async {
    // For selfie detection, try NV21 format first (for real-time camera streams)
    // The service will auto-detect and fallback to JPEG if needed
    return await _faceDetectionService.detectFaces(
      image.bytes,
      image.width,
      image.height,
      imageFormat: mlkit.InputImageFormat.nv21, // Explicitly specify NV21 for camera streams
    );
  }

  @override
  Future<LivenessResultEntity> performLivenessDetection(
    CapturedImageEntity selfieImage,
    List<LivenessCheckType> requiredChecks,
  ) async {
    return await _livenessDetectionService.performLivenessDetection(
      selfieImage,
      requiredChecks,
    );
  }

  @override
  Future<FaceEmbeddingEntity> generateFaceEmbedding(
    CapturedImageEntity faceImage,
  ) async {
    // Crop face from image if needed
    final croppedImage = await _cropFaceFromImage(faceImage);
    return await _faceEmbeddingService.generateEmbedding(croppedImage.bytes);
  }

  @override
  Future<double> matchFaces(
    FaceEmbeddingEntity embedding1,
    FaceEmbeddingEntity embedding2,
  ) async {
    // Use cosine similarity for matching
    return embedding1.cosineSimilarity(embedding2);
  }

  @override
  Future<VerificationResultEntity> performVerification({
    required CapturedImageEntity documentImage,
    required CapturedImageEntity selfieImage,
  }) async {
    try {
      // Step 1: Extract document info
      final documentInfo = await extractDocumentText(documentImage);
      if (!documentInfo.isValid) {
        return VerificationResultEntity.failure(
          reason: 'Failed to extract document information',
        );
      }

      // Step 2: Detect face in document
      final documentFaceResult = await detectDocumentFace(documentImage);
      if (!documentFaceResult.faceDetected ||
          documentFaceResult.faceCount != 1) {
        return VerificationResultEntity.failure(
          reason: 'No face or multiple faces detected in document',
          documentInfo: documentInfo,
        );
      }

      // Step 3: Detect face in selfie
      final selfieFaceResult = await detectSelfieFace(selfieImage);
      if (!selfieFaceResult.faceDetected || selfieFaceResult.faceCount != 1) {
        return VerificationResultEntity.failure(
          reason: 'No face or multiple faces detected in selfie',
          documentInfo: documentInfo,
        );
      }

      // Step 4: Perform liveness detection
      const requiredChecks = [
        LivenessCheckType.blink,
        LivenessCheckType.headTurnLeft,
        LivenessCheckType.headTurnRight,
      ];

      final livenessResult = await performLivenessDetection(
        selfieImage,
        requiredChecks,
      );

      if (!livenessResult.passed) {
        return VerificationResultEntity.failure(
          reason: 'Liveness detection failed: ${livenessResult.failureReason}',
          documentInfo: documentInfo,
          livenessResult: livenessResult,
        );
      }

      // Step 5: Generate face embeddings
      final documentFaceImage = await _cropFaceFromImageWithBounds(
        documentImage,
        documentFaceResult.bounds!,
      );
      final selfieFaceImage = await _cropFaceFromImageWithBounds(
        selfieImage,
        selfieFaceResult.bounds!,
      );

      final documentEmbedding = await generateFaceEmbedding(documentFaceImage);
      final selfieEmbedding = await generateFaceEmbedding(selfieFaceImage);

      // Step 6: Match faces
      final similarity = await matchFaces(documentEmbedding, selfieEmbedding);

      // Step 7: Final decision (threshold: 0.65)
      const faceMatchThreshold = 0.65;
      if (similarity < faceMatchThreshold) {
        return VerificationResultEntity.failure(
          reason:
              'Face match failed. Similarity: ${similarity.toStringAsFixed(2)}, Required: $faceMatchThreshold',
          documentInfo: documentInfo,
          livenessResult: livenessResult,
          faceMatchScore: similarity,
        );
      }

      // Success!
      return VerificationResultEntity.success(
        documentInfo: documentInfo,
        livenessResult: livenessResult,
        faceMatchScore: similarity,
      );
    } catch (e) {
      return VerificationResultEntity.failure(
        reason: 'Verification error: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cleanup() async {
    // Clean up resources
    _ocrService.dispose();
    _faceDetectionService.dispose();
    _faceEmbeddingService.dispose();
  }

  /// Crop face from image using detected bounds
  Future<CapturedImageEntity> _cropFaceFromImage(
    CapturedImageEntity image,
  ) async {
    final detectionResult = await _faceDetectionService.detectFaces(
      image.bytes,
      image.width,
      image.height,
    );

    if (!detectionResult.faceDetected || detectionResult.bounds == null) {
      // Return original image if face not detected
      return image;
    }

    return await _cropFaceFromImageWithBounds(image, detectionResult.bounds!);
  }

  /// Crop face from image using provided bounds
  Future<CapturedImageEntity> _cropFaceFromImageWithBounds(
    CapturedImageEntity image,
    FaceBounds bounds,
  ) async {
    final decodedImage = img.decodeImage(image.bytes);
    if (decodedImage == null) {
      return image;
    }

    // Add padding around face (20% on each side)
    final paddingX = bounds.width * 0.2;
    final paddingY = bounds.height * 0.2;

    final cropX = (bounds.left - paddingX)
        .clamp(0.0, image.width.toDouble())
        .toInt();
    final cropY = (bounds.top - paddingY)
        .clamp(0.0, image.height.toDouble())
        .toInt();
    final cropWidth = ((bounds.right + paddingX) - cropX)
        .clamp(0.0, (image.width - cropX).toDouble())
        .toInt();
    final cropHeight = ((bounds.bottom + paddingY) - cropY)
        .clamp(0.0, (image.height - cropY).toDouble())
        .toInt();

    final croppedImage = img.copyCrop(
      decodedImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    final croppedBytes = Uint8List.fromList(img.encodePng(croppedImage));

    return CapturedImageEntity(
      bytes: croppedBytes,
      width: cropWidth,
      height: cropHeight,
      source: image.source,
    );
  }
}
