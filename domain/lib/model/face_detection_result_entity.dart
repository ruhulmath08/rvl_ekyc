/// Result of face detection on an image
class FaceDetectionResultEntity {
  final bool faceDetected;
  final int faceCount;
  final double? confidence;
  final FaceBounds? bounds;
  final String? errorMessage;

  /// ML Kit eye open probabilities (0.0 = closed, 1.0 = open)
  /// Used for liveness detection (blink, eyes open check)
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;

  FaceDetectionResultEntity({
    required this.faceDetected,
    required this.faceCount,
    this.confidence,
    this.bounds,
    this.errorMessage,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
  });

  /// Both eyes considered open if both probabilities > threshold (default 0.5)
  /// Returns null when eye data is unavailable (e.g. face at bad angle)
  bool? get eyesOpen {
    final left = leftEyeOpenProbability;
    final right = rightEyeOpenProbability;
    if (left == null || right == null) return null;
    const threshold = 0.5;
    return left > threshold && right > threshold;
  }

  FaceDetectionResultEntity.success({
    required this.confidence,
    required this.bounds,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
  }) : faceDetected = true,
       faceCount = 1,
       errorMessage = null;

  FaceDetectionResultEntity.noFace()
    : faceDetected = false,
      faceCount = 0,
      confidence = null,
      bounds = null,
      errorMessage = 'No face detected',
      leftEyeOpenProbability = null,
      rightEyeOpenProbability = null;

  FaceDetectionResultEntity.multipleFaces()
    : faceDetected = false,
      faceCount = 0,
      confidence = null,
      bounds = null,
      errorMessage = 'Multiple faces detected. Only one face is allowed.',
      leftEyeOpenProbability = null,
      rightEyeOpenProbability = null;

  FaceDetectionResultEntity.error(String message)
    : faceDetected = false,
      faceCount = 0,
      confidence = null,
      bounds = null,
      errorMessage = message,
      leftEyeOpenProbability = null,
      rightEyeOpenProbability = null;
}

/// Bounding box coordinates for detected face
class FaceBounds {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;

  FaceBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  }) : width = right - left,
       height = bottom - top;

  /// Check if face is centered in the image
  /// Returns true if face center is within centerThreshold% of image center
  bool isCentered(
    double imageWidth,
    double imageHeight, {
    double centerThreshold = 0.3,
  }) {
    final faceCenterX = left + width / 2;
    final faceCenterY = top + height / 2;
    final imageCenterX = imageWidth / 2;
    final imageCenterY = imageHeight / 2;

    final xOffset = (faceCenterX - imageCenterX).abs() / imageWidth;
    final yOffset = (faceCenterY - imageCenterY).abs() / imageHeight;

    return xOffset < centerThreshold && yOffset < centerThreshold;
  }
}
