import 'package:domain/exceptions/base_exception.dart';

/// Base exception for eKYC operations
class EkycException extends BaseException {
  EkycException(super.message, {super.code});
}

/// Exception thrown when document capture fails
class DocumentCaptureException extends EkycException {
  DocumentCaptureException(super.message, {super.code});
}

/// Exception thrown when OCR fails
class OcrException extends EkycException {
  OcrException(super.message, {super.code});
}

/// Exception thrown when face detection fails
class FaceDetectionException extends EkycException {
  FaceDetectionException(super.message, {super.code});
}

/// Exception thrown when liveness detection fails
class LivenessException extends EkycException {
  LivenessException(super.message, {super.code});
}

/// Exception thrown when face matching fails
class FaceMatchException extends EkycException {
  FaceMatchException(super.message, {super.code});
}

/// Exception thrown when face embedding generation fails
class FaceEmbeddingException extends EkycException {
  FaceEmbeddingException(super.message, {super.code});
}
