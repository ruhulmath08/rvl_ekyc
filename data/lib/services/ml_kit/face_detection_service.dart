import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:domain/model/face_detection_result_entity.dart';
import 'package:domain/exceptions/ekyc_exception.dart';
import 'package:path_provider/path_provider.dart';

/// Service for face detection using Google ML Kit
class FaceDetectionService {
  final FaceDetector _faceDetector;

  FaceDetectionService()
    : _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: false,
          minFaceSize: 0.05,
          // Minimum face size (5% of image) - more lenient for document photos
          performanceMode: FaceDetectorMode
              .accurate, // Use accurate mode for better detection
        ),
      );

  /// Detect faces in image
  /// Supports both file-based (JPEG) and native YUV format (NV21)
  /// Auto-detects format: if bytes size matches NV21 (width*height*1.5), uses NV21, otherwise JPEG
  Future<FaceDetectionResultEntity> detectFaces(
    Uint8List imageBytes,
    int imageWidth,
    int imageHeight, {
    InputImageFormat imageFormat = InputImageFormat.nv21,
  }) async {
    // Auto-detect NV21 format: NV21 size = width * height * 1.5
    // Only use NV21 if explicitly requested AND size matches exactly
    final expectedNv21Size = (imageWidth * imageHeight * 1.5).round();
    final actualSize = imageBytes.length;
    final isLikelyNv21 =
        imageFormat == InputImageFormat.nv21 && actualSize == expectedNv21Size;

    // Debug logging
    print(
      'FaceDetectionService: Format=$imageFormat, ExpectedNV21=$expectedNv21Size, Actual=$actualSize, IsNV21=$isLikelyNv21',
    );

    // If format is NV21 and size matches exactly, use native bytes support (faster for camera streams)
    // For JPEG images (documents), always use file-based approach
    if (isLikelyNv21) {
      try {
        final inputImage = InputImage.fromBytes(
          bytes: imageBytes,
          metadata: InputImageMetadata(
            size: Size(imageWidth.toDouble(), imageHeight.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow:
                imageWidth, // For NV21, Y plane bytes per row (no padding in our conversion)
          ),
        );

        final faces = await _faceDetector.processImage(inputImage);

        if (faces.isEmpty) {
          // Log for debugging - might be conversion issue or no face present
          return FaceDetectionResultEntity.noFace();
        }

        if (faces.length > 1) {
          return FaceDetectionResultEntity.multipleFaces();
        }

        final face = faces.first;
        final bounds = FaceBounds(
          left: face.boundingBox.left,
          top: face.boundingBox.top,
          right: face.boundingBox.right,
          bottom: face.boundingBox.bottom,
        );

        // Calculate confidence (ML Kit doesn't provide direct confidence, use bounding box size as proxy)
        final faceArea = bounds.width * bounds.height;
        final imageArea = imageWidth * imageHeight;
        final confidence = (faceArea / imageArea).clamp(0.0, 1.0);

        return FaceDetectionResultEntity.success(
          confidence: confidence,
          bounds: bounds,
          leftEyeOpenProbability: face.leftEyeOpenProbability,
          rightEyeOpenProbability: face.rightEyeOpenProbability,
        );
      } catch (e) {
        // Log the error and fallback to file-based approach
        // This handles cases where imageBytes might be JPEG instead of NV21
        // or if NV21 conversion/metadata is incorrect
        print(
          'FaceDetectionService: NV21 format failed, falling back to JPEG: $e',
        );
        // Fall through to file-based approach
      }
    }

    // Fallback: Use file-based approach for JPEG images
    File? tempFile;
    try {
      // Validate image bytes before processing
      if (imageBytes.isEmpty) {
        print('FaceDetectionService: Empty image bytes provided');
        return FaceDetectionResultEntity.error('Empty image data');
      }

      // Save image to temporary file for better ML Kit compatibility
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/face_detection_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(imageBytes);

      // Verify file was written correctly
      if (!await tempFile.exists() || await tempFile.length() == 0) {
        print('FaceDetectionService: Failed to write temporary file');
        return FaceDetectionResultEntity.error('Failed to process image file');
      }

      // Use file-based InputImage (more reliable than bytes)
      final inputImage = InputImage.fromFilePath(tempFile.path);

      print(
        'FaceDetectionService: Processing image file: ${tempFile.path}, Size: ${imageWidth}x${imageHeight}',
      );
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        // Log for debugging
        print(
          'FaceDetectionService: No faces detected in image. Image size: ${imageWidth}x${imageHeight}, Bytes: ${imageBytes.length}, File size: ${await tempFile.length()}',
        );
        return FaceDetectionResultEntity.noFace();
      }

      if (faces.length > 1) {
        // Log for debugging
        print('FaceDetectionService: Multiple faces detected: ${faces.length}');
        return FaceDetectionResultEntity.multipleFaces();
      }

      final face = faces.first;
      final bounds = FaceBounds(
        left: face.boundingBox.left,
        top: face.boundingBox.top,
        right: face.boundingBox.right,
        bottom: face.boundingBox.bottom,
      );

      // Calculate confidence (ML Kit doesn't provide direct confidence, use bounding box size as proxy)
      final faceArea = bounds.width * bounds.height;
      final imageArea = imageWidth * imageHeight;
      final confidence = (faceArea / imageArea).clamp(0.0, 1.0);

      print(
        'FaceDetectionService: Face detected successfully. Bounds: ${bounds.left}, ${bounds.top}, ${bounds.right}, ${bounds.bottom}, Confidence: $confidence',
      );
      return FaceDetectionResultEntity.success(
        confidence: confidence,
        bounds: bounds,
        leftEyeOpenProbability: face.leftEyeOpenProbability,
        rightEyeOpenProbability: face.rightEyeOpenProbability,
      );
    } catch (e, stackTrace) {
      print(
        'FaceDetectionService: Exception during face detection: $e\n$stackTrace',
      );
      throw FaceDetectionException('Failed to detect faces: ${e.toString()}');
    } finally {
      // Clean up temporary file
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }

  /// Check if eyes are open
  /// Uses face landmarks to determine eye state
  Future<bool> areEyesOpen(
    Uint8List imageBytes,
    int imageWidth,
    int imageHeight, {
    InputImageFormat imageFormat = InputImageFormat.nv21,
  }) async {
    File? tempFile;
    try {
      // Save image to temporary file
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/eyes_check_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return false;
      }

      final face = faces.first;

      // Check if left and right eye landmarks are available
      final leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
      final rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;

      // Eyes are considered open if both probabilities are > 0.5
      return leftEyeOpenProbability > 0.5 && rightEyeOpenProbability > 0.5;
    } catch (e) {
      return false;
    } finally {
      // Clean up temporary file
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }

  /// Get head pose (for liveness detection)
  /// Returns approximate head turn angle
  Future<double?> getHeadPose(
    Uint8List imageBytes,
    int imageWidth,
    int imageHeight, {
    InputImageFormat imageFormat = InputImageFormat.nv21,
  }) async {
    File? tempFile;
    try {
      // Save image to temporary file
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/head_pose_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return null;
      }

      final face = faces.first;

      // Try to use head rotation angle if available (more accurate)
      // ML Kit provides headEulerAngleY for left/right rotation
      if (face.headEulerAngleY != null) {
        // headEulerAngleY: negative = left turn, positive = right turn, 0 = centered
        // Normalize to -1 to 1 range (assuming max rotation is ~45 degrees)
        final angleY = face.headEulerAngleY!;
        final normalizedAngle = (angleY / 45.0).clamp(-1.0, 1.0);
        return normalizedAngle;
      }

      // Fallback: Use face bounding box position relative to image center as proxy
      final faceCenterX = face.boundingBox.left + face.boundingBox.width / 2;
      final imageCenterX = imageWidth / 2;
      final offset = faceCenterX - imageCenterX;
      final normalizedOffset = offset / imageWidth;

      // Return angle estimate (-1 to 1, where 0 is centered)
      return normalizedOffset;
    } catch (e) {
      return null;
    } finally {
      // Clean up temporary file
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
