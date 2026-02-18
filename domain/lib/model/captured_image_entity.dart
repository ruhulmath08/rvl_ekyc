import 'dart:typed_data';

/// Represents a captured image with metadata
class CapturedImageEntity {
  final Uint8List bytes;
  final int width;
  final int height;
  final ImageSource source;
  final DateTime timestamp;

  CapturedImageEntity({
    required this.bytes,
    required this.width,
    required this.height,
    required this.source,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum ImageSource {
  document,
  selfie,
}
