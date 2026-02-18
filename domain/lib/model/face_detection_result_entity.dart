/// Result of face detection on an image
class FaceDetectionResultEntity {
  final bool faceDetected;
  final int faceCount;
  final double? confidence;
  final FaceBounds? bounds;
  final String? errorMessage;

  FaceDetectionResultEntity({
    required this.faceDetected,
    required this.faceCount,
    this.confidence,
    this.bounds,
    this.errorMessage,
  });

  FaceDetectionResultEntity.success({
    required this.confidence,
    required this.bounds,
  }) : faceDetected = true,
       faceCount = 1,
       errorMessage = null;

  FaceDetectionResultEntity.noFace()
    : faceDetected = false,
      faceCount = 0,
      confidence = null,
      bounds = null,
      errorMessage = 'No face detected';

  FaceDetectionResultEntity.multipleFaces()
    : faceDetected = false,
      faceCount = 0,
      confidence = null,
      bounds = null,
      errorMessage = 'Multiple faces detected. Only one face is allowed.';

  FaceDetectionResultEntity.error(String message)
    : faceDetected = false,
      faceCount = 0,
      confidence = null,
      bounds = null,
      errorMessage = message;
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
