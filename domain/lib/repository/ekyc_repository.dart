import 'package:domain/model/captured_image_entity.dart';
import 'package:domain/model/document_info_entity.dart';
import 'package:domain/model/document_side.dart';
import 'package:domain/model/face_detection_result_entity.dart';
import 'package:domain/model/face_embedding_entity.dart';
import 'package:domain/model/liveness_result_entity.dart';
import 'package:domain/model/verification_result_entity.dart';

/// Repository interface for eKYC operations
/// All operations are performed on-device, no network calls
abstract class EkycRepository {
  /// Extract text from document image using OCR
  /// Can extract from both front and back sides of Bangladeshi NID
  Future<DocumentInfoEntity> extractDocumentText(
    CapturedImageEntity image, {
    DocumentSide? side,
  });

  /// Detect and extract face from document image
  Future<FaceDetectionResultEntity> detectDocumentFace(CapturedImageEntity image);

  /// Detect face from selfie image
  Future<FaceDetectionResultEntity> detectSelfieFace(CapturedImageEntity image);

  /// Perform active liveness detection on selfie
  /// Returns result with checks for blink, head turn, etc.
  Future<LivenessResultEntity> performLivenessDetection(
    CapturedImageEntity selfieImage,
    List<LivenessCheckType> requiredChecks,
  );

  /// Generate face embedding from face image
  Future<FaceEmbeddingEntity> generateFaceEmbedding(CapturedImageEntity faceImage);

  /// Match two face embeddings using cosine similarity
  /// Returns similarity score between 0 and 1 (1 = identical)
  Future<double> matchFaces(
    FaceEmbeddingEntity embedding1,
    FaceEmbeddingEntity embedding2,
  );

  /// Perform complete eKYC verification
  /// Returns VerificationResult with all checks
  Future<VerificationResultEntity> performVerification({
    required CapturedImageEntity documentImage,
    required CapturedImageEntity selfieImage,
  });

  /// Clean up resources (delete temporary images, clear cache)
  Future<void> cleanup();
}
